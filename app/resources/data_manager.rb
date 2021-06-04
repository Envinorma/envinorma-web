# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class DataManager
  def self.seed_arretes_and_associations
    arretes_files = Dir.glob("#{Rails.root}/db/seeds/enriched_arretes/*.json")
    Arrete.validate_then_recreate(arretes_files)
  end

  def self.seed_installations_and_associations
    seed_folder = File.join(Rails.root, 'db', 'seeds')

    installations_file = File.join(seed_folder, 'installations_all.csv')
    classements_file = File.join(seed_folder, 'classements_all.csv')
    aps_file = File.join(seed_folder, 'aps_all.csv')

    # Validate files
    recreate_from_file(installations_file, Installation, 1000, true, {})
    recreate_from_file(classements_file, Classement, 5000, true, {})
    recreate_from_file(aps_file, AP, 5000, true, {})

    # Delete old objects
    delete_old_objects

    # Insert files
    recreate_from_file(installations_file, Installation, 1000, false, {})
    s3ic_id_to_envinorma_id = load_s3ic_id_to_envinorma_id
    recreate_from_file(classements_file, Classement, 5000, false, s3ic_id_to_envinorma_id)
    recreate_from_file(aps_file, AP, 5000, false, s3ic_id_to_envinorma_id)
  end

  def self.recreate_from_file(seed_file, model, batch_size, validate_only, s3ic_id_to_envinorma_id)
    verb = validate_only ? 'Validating' : 'Seeding'
    puts "#{Time.now} #{verb} #{model}s..."
    nb_lines = `wc -l #{seed_file}`.to_i - 1 # count lines without overflowing memory
    nb_batches = (nb_lines.to_f / batch_size).ceil
    puts "#{nb_batches} batches of size #{batch_size} to process"

    batch_generator = CSV.foreach(seed_file, headers: true).each_slice(batch_size)
    batchwise_insertion(batch_generator, model, nb_batches, validate_only, s3ic_id_to_envinorma_id)

    puts "...done. Inserted #{model.count}/#{nb_lines} #{model}s." unless validate_only
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
    puts "...validating batch #{batch_index + 1}/#{nb_batches}"
    hash_batch.each do |hash|
      object = model.new(hash)

      raise "error validations #{object.inspect} #{object.errors.full_messages}" unless object.validate
    end
  end

  def self.insert_batch(model, batch_index, nb_batches, hash_batch)
    puts "...inserting batch #{batch_index + 1}/#{nb_batches}"
    inserted_ids = model.insert_all(hash_batch)
    missing_insertions = hash_batch.length - inserted_ids.length
    puts "Warning: #{missing_insertions} #{model}s were not inserted!" unless missing_insertions.zero?
  end

  def self.delete_old_objects
    AP.delete_and_reset_primary_key
    Classement.delete_and_reset_primary_key
    Prescription.delete_and_reset_primary_key
    puts 'Deleting existing Installations.' # Delete is faster than Destroy
    Installation.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Installation.table_name)
  end

  def self.load_s3ic_id_to_envinorma_id
    result = {}
    Installation.all.pluck(:id, :s3ic_id).each do |id, s3ic_id|
      result[s3ic_id] = id
    end
    result
  end
end
