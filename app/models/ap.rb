# frozen_string_literal: true

class AP < ApplicationRecord
  belongs_to :installation

  validates :georisques_id, :installation_id, :installation_s3ic_id, presence: true
  validates :georisques_id, length: { is: 36 }
  validates :georisques_id, format: { with: %r{\A([A-Z]{1}/[a-f0-9]{1}/[a-f0-9]{32})\z},
                                      message: 'check georisques_id format' }

  validates :installation_s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                             message: 'check s3ic_id format' }

  def title
    "#{description} - #{date.strftime('%d/%m/%y')}"
  end

  def short_title
    "AP - #{date.strftime('%d/%m/%y')}"
  end

  class << self
    def recreate_from_file(seed_file)
      puts "#{Time.now} Seeding aps..."
      batch_size = 5000
      nb_aps = `wc -l #{seed_file}`.to_i - 1 # count lines without overflowing memory
      nb_batches = (nb_aps.to_f / batch_size).ceil
      puts "#{nb_batches} batches of size #{batch_size} to process"

      s3ic_id_to_envinorma_id = Installation.load_s3ic_id_to_envinorma_id

      # We avoid actually building batches in order to avoid memory overflow
      CSV.foreach(seed_file, headers: true).each_slice(batch_size).each_with_index do |raw_batch, batch_index|
        hash_batch = raw_batch.map { |raw| create_ap_hash(raw, s3ic_id_to_envinorma_id) }
        insert_batch(batch_index, nb_batches, hash_batch)
        GC.start if batch_index % 10 == 9 # Force garbage collection for RAM limitations
      end

      puts "...done. Inserted #{AP.count}/#{nb_aps} aps."
    end

    private

    def create_ap_hash(ap_raw, s3ic_id_to_envinorma_id)
      {
        'installation_s3ic_id' => ap_raw['installation_s3ic_id'],
        'description' => ap_raw['description'],
        'date' => ap_raw['date'],
        'georisques_id' => ap_raw['georisques_id'],
        'installation_id' => s3ic_id_to_envinorma_id[ap_raw['installation_s3ic_id']]
      }
    end

    def validate_batch(ap_hashes)
      ap_hashes.each do |ap_hash|
        ap = AP.new(ap_hash)

        raise "error validations #{ap.inspect} #{ap.errors.full_messages}" unless ap.validate
      end
    end

    def validate_batch_and_destroy_existing_aps(ap_hashes)
      puts '...validating first batch.'
      validate_batch(ap_hashes)

      puts '...destroying existing aps.'
      AP.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(AP.table_name)
    end

    def insert_batch(batch_index, nb_batches, ap_hashes)
      validate_batch_and_destroy_existing_aps(ap_hashes) if batch_index.zero?
      puts "...inserting batch #{batch_index + 1}/#{nb_batches}"
      inserted_ids = AP.insert_all(ap_hashes)
      missing_insertions = ap_hashes.length - inserted_ids.length
      puts "Warning: #{missing_insertions} aps were not inserted!" unless missing_insertions.zero?
    end
  end
end
