# frozen_string_literal: true

class Classement < ApplicationRecord
  belongs_to :installation

  validates :regime, :rubrique, :installation_id, presence: true
  validates :regime, inclusion: { in: %w[A E D NC unknown], message: 'is not valid' }
  validates :regime_acte, inclusion: { in: %w[A E D NC unknown], message: 'is not valid', allow_blank: true }

  def human_readable_volume
    words = (volume || '').split
    return volume if words.length > 2 || words.length.zero?

    volume_number = simplify_volume(words.first || '')
    volume_unit = words.length == 1 ? '' : words.last
    volume_unit.empty? ? volume_number.to_s : "#{volume_number} #{volume_unit}"
  end

  def float?(string)
    true if Float(string)
  rescue StandardError
    false
  end

  def int?(string)
    !(string =~ /\A[0-9]*\.000\z/).nil?
  end

  def simplify_volume(volume)
    return if volume.nil?
    return volume.to_i if int?(volume)
    return volume.to_f if float?(volume)

    volume
  end

  class << self
    def delete_and_reset_primary_key
      puts 'Deleting existing Classements.'
      Classement.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Classement.table_name)
    end

    def recreate_from_file(seed_file)
      puts "#{Time.now} Seeding classements..."
      batch_size = 5000
      nb_classements = `wc -l #{seed_file}`.to_i - 1 # count lines without overflowing memory
      nb_batches = (nb_classements.to_f / batch_size).ceil

      s3ic_id_to_envinorma_id = Installation.load_s3ic_id_to_envinorma_id

      # We avoid actually building batches in order to avoid memory overflow
      CSV.foreach(seed_file, headers: true).each_slice(batch_size).each_with_index do |raw_batch, batch_index|
        hash_batch = raw_batch.map { |raw| create_classement_hash(raw, s3ic_id_to_envinorma_id) }
        insert_batch(batch_index, nb_batches, hash_batch)
        GC.start if batch_index % 10 == 9 # Force garbage collection for RAM limitations
      end

      puts "...done. Inserted #{Classement.count}/#{nb_classements} classements."
    end

    private

    def create_classement_hash(classement_raw, s3ic_id_to_envinorma_id)
      {
        'rubrique' => classement_raw['rubrique'],
        'regime' => classement_raw['regime'],
        'alinea' => classement_raw['alinea'],
        'rubrique_acte' => classement_raw['rubrique_acte'],
        'regime_acte' => classement_raw['regime_acte'],
        'alinea_acte' => classement_raw['alinea_acte'],
        'activite' => classement_raw['activite'],
        'date_autorisation' => classement_raw['date_autorisation']&.to_date,
        'date_mise_en_service' => classement_raw['date_mise_en_service']&.to_date,
        'volume' => "#{classement_raw['volume']} #{classement_raw['unit']}",
        'installation_id' => s3ic_id_to_envinorma_id[classement_raw['s3ic_id']],
        'created_at' => DateTime.now,
        'updated_at' => DateTime.now
      }
    end

    def validate_batch(classement_hashes)
      classement_hashes.each do |classement_hash|
        classement = Classement.new(classement_hash)

        raise "error validations #{classement.inspect} #{classement.errors.full_messages}" unless classement.validate
      end
    end

    def validate_batch_and_destroy_existing_classements(classement_hashes)
      puts '...validating first batch.'
      validate_batch(classement_hashes)

      puts '...destroying existing classements.'
      Classement.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Classement.table_name)
    end

    def insert_batch(batch_index, nb_batches, classement_hashes)
      validate_batch_and_destroy_existing_classements(classement_hashes) if batch_index.zero?
      puts "...inserting batch #{batch_index + 1}/#{nb_batches}"
      inserted_ids = Classement.insert_all(classement_hashes)
      missing_insertions = classement_hashes.length - inserted_ids.length
      puts "Warning: #{missing_insertions} classements were not inserted!" unless missing_insertions.zero?
    end
  end
end
