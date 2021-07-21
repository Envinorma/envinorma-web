# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class DataManager
  def self.seed_arretes_and_associations
    arretes_files = Dir.glob(Rails.root.join('db/seeds/enriched_arretes/*.json'))
    Arrete.validate_then_recreate(arretes_files)
  end

  def self.seed_installations_and_associations(validate:, use_sample: false)
    seed_folder = Rails.root.join('db/seeds')

    file_suffix = use_sample ? 'sample_rspec' : 'all'
    Rails.logger.info("Seeding dataset '#{file_suffix}'.")
    installations_file = File.join(seed_folder, "installations_#{file_suffix}.csv")
    classements_file = File.join(seed_folder, "classements_#{file_suffix}.csv")
    aps_file = File.join(seed_folder, "aps_#{file_suffix}.csv")

    # Validate files
    if validate
      # We create a fake installation to which all APs and classements will be attached.
      # It enables validation and the fake installation is removed juste after.
      Installation.create(id: 1, s3ic_id: '0000.00000', name: 'test') if Installation.where(id: 1).first.nil?
      recreate_or_validate_from_file(installations_file, Installation, 1000, true, {})
      recreate_or_validate_from_file(classements_file, Classement, 5000, true, nil)
      recreate_or_validate_from_file(aps_file, AP, 5000, true, nil)
    end

    previous_envinorma_id_to_s3ic_id = load_envinorma_id_to_s3ic_id({})
    recreate_or_validate_from_file(installations_file, Installation, 1000, false, {})
    s3ic_id_to_envinorma_id = load_new_s3ic_id_to_envinorma_id(previous_envinorma_id_to_s3ic_id)

    # Delete old objects
    delete_old_objects

    # Insert files
    recreate_or_validate_from_file(classements_file, Classement, 5000, false, s3ic_id_to_envinorma_id)
    recreate_or_validate_from_file(aps_file, AP, 5000, false, s3ic_id_to_envinorma_id)
  end

  def self.recreate_or_validate_from_file(seed_file, model, batch_size, validate_only, s3ic_id_to_envinorma_id)
    verb = validate_only ? 'Validating' : 'Seeding'
    Rails.logger.info "#{Time.zone.now} #{verb} #{model}s..."
    nb_lines = `wc -l #{seed_file}`.to_i - 1 # count lines without overflowing memory
    nb_batches = (nb_lines.to_f / batch_size).ceil
    Rails.logger.info "#{nb_batches} batches of size #{batch_size} to process"

    batch_generator = CSV.foreach(seed_file, headers: true).each_slice(batch_size)
    batchwise_insertion(batch_generator, model, nb_batches, validate_only, s3ic_id_to_envinorma_id)

    Rails.logger.info "...done. Inserted #{model.count}/#{nb_lines} #{model}s." unless validate_only
  end

  def self.batchwise_insertion(batches, model, nb_batches, validate_only, s3ic_id_to_envinorma_id)
    # We avoid actually building batches in order to avoid memory overflow
    batches.each_with_index do |raw_batch, batch_index|
      hash_batch = build_hash_batch(model, raw_batch, s3ic_id_to_envinorma_id)
      if validate_only
        validate_batch(model, batch_index, nb_batches, hash_batch)
      else
        insert_batch(model, batch_index, nb_batches, hash_batch)
      end

      GC.start if batch_index % 10 == 9 # Force garbage collection every 10 batches for RAM limitations
    end
  end

  def self.build_hash_batch(model, raw_batch, s3ic_id_to_envinorma_id)
    if model == Installation
      raw_batch.map { |raw| model.create_hash_from_csv_row(raw) }
    else
      raw_batch.map { |raw| model.create_hash_from_csv_row(raw, s3ic_id_to_envinorma_id) }
    end
  end

  def self.validate_batch(model, batch_index, nb_batches, hash_batch)
    Rails.logger.info "...validating batch #{batch_index + 1}/#{nb_batches}"
    hash_batch.each do |hash|
      object = model.new(hash)

      raise "error validations #{object.inspect} #{object.errors.full_messages}" unless object.validate
    end
  end

  def self.insert_batch(model, batch_index, nb_batches, hash_batch)
    Rails.logger.info "...inserting batch #{batch_index + 1}/#{nb_batches}"
    # Below line skips validation, but it is handled separately
    inserted_ids = model.insert_all(hash_batch) # rubocop:disable Rails/SkipsModelValidations
    missing_insertions = hash_batch.length - inserted_ids.length
    Rails.logger.info "Warning: #{missing_insertions} #{model}s were not inserted!" unless missing_insertions.zero?
  end

  def self.delete_old_objects
    delete_and_reset_primary_key(AP)
    delete_and_reset_primary_key(Classement)
    delete_and_reset_primary_key(Prescription)
    delete_and_reset_primary_key(Installation)
  end

  def self.delete_and_reset_primary_key(model)
    Rails.logger.info "Deleting existing #{model}s."
    model.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end

  def self.load_envinorma_id_to_s3ic_id
    result = {}
    Installation.all.pluck(:id, :s3ic_id).each do |id, s3ic_id|
      result[id] = s3ic_id
    end
    result
  end

  def self.load_new_s3ic_id_to_envinorma_id(previous_envinorma_id_to_s3ic_id)
    result = {}
    Installation.all.pluck(:id, :s3ic_id).each do |id, s3ic_id|
      result[s3ic_id] = id unless previous_envinorma_id_to_s3ic_id.key?(id)
    end
    result
  end
end
