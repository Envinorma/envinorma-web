# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class InstallationsManager
  def self.seed(validate, installations_file, classements_file, aps_file)
    # Validate files objects
    validate_from_files(installations_file, classements_file, aps_file) if validate

    # Insert from files
    upsert_from_files(installations_file, classements_file, aps_file)
  end

  def self.seed_aps(aps_file)
    # Seeds only AP, without modifying installations and prescriptions
    fake_installation = create_fake_installation_for_validation
    operate_from_file(aps_file, 5000, AP, 'validation', nil)
    fake_installation.destroy if fake_installation.present?
    upsert_aps(aps_file, load_s3ic_id_to_envinorma_id)
  end

  def self.validate_from_files(installations_file, classements_file, aps_file)
    Rails.logger.info 'STARTING VALIDATION OF FILES'
    fake_installation = create_fake_installation_for_validation
    operate_from_file(installations_file, 1000, Installation, 'validation', {})
    operate_from_file(classements_file, 5000, Classement, 'validation', nil)
    operate_from_file(aps_file, 5000, AP, 'validation', nil)
    fake_installation.destroy if fake_installation.present?
    Rails.logger.info 'VALIDATION OF FILES DONE'
  end

  def self.create_fake_installation_for_validation
    # We create a fake installation to which all APs and classements will be attached.
    # It enables validation and the fake installation is removed juste after.
    return Installation.create!(id: 1, s3ic_id: '0000.00000', name: 'test') if Installation.where(id: 1).first.nil?

    nil
  end

  def self.upsert_from_files(installations_file, classements_file, aps_file)
    delete_classements

    upsert_installations(installations_file)
    s3ic_id_to_envinorma_id = load_s3ic_id_to_envinorma_id

    operate_from_file(classements_file, 5000, Classement, 'upsertion', s3ic_id_to_envinorma_id)

    upsert_aps(aps_file, s3ic_id_to_envinorma_id)
  end

  def self.delete_classements
    Rails.logger.info 'Deleting existing classements (except those of duplicated and fictive installations)...'
    installation_ids = Installation.where_not_fictive_nor_duplicated.pluck(:id)
    nb_classements = Classement.where(installation_id: installation_ids).delete_all
    Rails.logger.info "...deleted #{nb_classements} classements. #{Classement.count} classements left in db."
    ActiveRecord::Base.connection.reset_pk_sequence!(Classement.table_name)
  end

  def self.upsert_installations(installations_file)
    s3ic_id_to_delete = Installation.pluck(:s3ic_id) - CsvUtils.read_column(installations_file, 's3ic_id')
    delete_installations_and_associated_objects(s3ic_id_to_delete)
    operate_from_file(installations_file, 1000, Installation, 'upsertion', nil)
  end

  def self.upsert_aps(aps_file, s3ic_id_to_envinorma_id)
    georisques_ids_to_delete = AP.pluck(:georisques_id) - CsvUtils.read_column(aps_file, 'georisques_id')
    AP.delete_from_georisques_ids(georisques_ids_to_delete)
    operate_from_file(aps_file, 5000, AP, 'upsertion', s3ic_id_to_envinorma_id)
  end

  def self.delete_installations_and_associated_objects(s3ic_ids_to_delete)
    Rails.logger.info("Deleting #{s3ic_ids_to_delete.count} installations and corresponding "\
                      'AP and prescriptions...')

    ids = Installation.where(s3ic_id: s3ic_ids_to_delete).where_not_fictive_nor_duplicated.pluck(:id)
    nb_prescriptions = Prescription.where(installation_id: ids).delete_all
    nb_aps = AP.where(installation_id: ids).delete_all
    nb_installations = Installation.where(id: ids).delete_all

    Rails.logger.info("...deleted #{nb_aps} APs, #{nb_prescriptions} prescriptions and"\
                      " #{nb_installations} installations.")
  end

  def self.operate_from_file(seed_file, batch_size, model, operation, s3ic_id_to_envinorma_id)
    Rails.logger.info "#{Time.zone.now} #{operation} of #{model}s..."
    batch_generator, nb_batches = prepare_batches(seed_file, batch_size)
    batchwise_operation(batch_generator, model, nb_batches, operation, s3ic_id_to_envinorma_id)
    Rails.logger.info "...done. #{model.count} #{model}s are in db."
  end

  def self.prepare_batches(seed_file, batch_size)
    nb_lines = `wc -l #{seed_file}`.to_i - 1 # count lines without overflowing memory
    nb_batches = (nb_lines.to_f / batch_size).ceil
    Rails.logger.info "#{nb_batches} batches of size #{batch_size} to process (#{nb_lines} elements)"
    batch_generator = CSV.foreach(seed_file, headers: true).each_slice(batch_size)
    [batch_generator, nb_batches]
  end

  def self.batchwise_operation(batches, model, nb_batches, operation, s3ic_id_to_envinorma_id)
    # We avoid actually building batches in order to avoid memory overflow
    previous_mapping = fetch_previous_mapping(model, operation)
    batches.each_with_index do |raw_batch, batch_index|
      Rails.logger.info "...handling batch #{batch_index + 1}/#{nb_batches}"
      hash_batch = build_hash_batch(model, raw_batch, s3ic_id_to_envinorma_id, previous_mapping)
      case operation
      when 'validation'
        BatchOperations.validate_batch(model, hash_batch)
      when 'upsertion'
        BatchOperations.upsert_batch(model, hash_batch)
      else
        raise "Unknown operation #{operation}"
      end
      GC.start if batch_index % 10 == 9 # Force garbage collection every 10 batches for RAM limitations
    end
  end

  def self.fetch_previous_mapping(model, operation)
    # Previous mapping is only used for upsertion to update objects that previously existed.
    # It enables to avoid suppressing existing installations and APs and their associated objects.
    # Classement having no ids (and not being tied to any objects) are recreated from scratch.
    return {} if operation == 'validation'

    return {} if model == Classement

    return load_s3ic_id_to_envinorma_id if model == Installation

    return AP.pluck(:georisques_id, :id).to_h if model == AP

    nil
  end

  def self.build_hash_batch(model, raw_batch, s3ic_id_to_envinorma_id, previous_mapping)
    raw_batch.map { |raw| build_hash(model, raw, s3ic_id_to_envinorma_id, previous_mapping) }
  end

  def self.build_hash(model, raw, s3ic_id_to_envinorma_id, previous_mapping)
    hash = model.create_hash_from_csv_row(raw)
    installation_id = associated_installation_id(model, raw, s3ic_id_to_envinorma_id)
    hash[:installation_id] = installation_id if installation_id
    id_in_db = find_id_in_db(model, raw, previous_mapping)
    hash[:id] = id_in_db if id_in_db
    hash
  end

  def self.associated_installation_id(model, raw, s3ic_id_to_envinorma_id)
    return if model == Installation

    return 1 if s3ic_id_to_envinorma_id.nil?

    s3ic_id = raw[model == AP ? 'installation_s3ic_id' : 's3ic_id']

    raise "s3ic_id #{s3ic_id} not found" unless s3ic_id_to_envinorma_id.key?(s3ic_id)

    s3ic_id_to_envinorma_id[s3ic_id]
  end

  def self.find_id_in_db(model, raw, mapping_in_db)
    return if model == Classement
    return unless mapping_in_db

    key = model == Installation ? 's3ic_id' : 'georisques_id'
    mapping_in_db[raw[key]] if mapping_in_db.key?(raw[key])
  end

  def self.load_s3ic_id_to_envinorma_id
    # We load the id mapping, ignoring fictive or duplicated installations which are not updated
    Installation.where_not_fictive_nor_duplicated.pluck(:s3ic_id, :id).to_h
  end
end
