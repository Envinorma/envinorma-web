# frozen_string_literal: true

class Installation < ApplicationRecord
  has_many :classements, dependent: :destroy
  accepts_nested_attributes_for :classements, allow_destroy: true

  has_many :APs, dependent: :destroy
  has_many :prescriptions, dependent: :destroy
  belongs_to :user, optional: true

  validates :name, :s3ic_id, presence: true
  validates :s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                message: 'check s3ic_id format' }
  validates_uniqueness_of :user_id, scope: :duplicated_from_id, if: -> { duplicated_from_id.present? }

  scope :not_attached_to_user, -> { where(user: nil) }

  def retrieve_aps
    if duplicated_from_id?
      Installation.find(duplicated_from_id).APs
    else
      self.APs
    end
  end

  def duplicated_by_user?(user_id_cookies)
    user_id && user_id == user_id_cookies.to_i
  end

  def duplicate!(user)
    installation_duplicated = Installation.create(
      name: name,
      s3ic_id: s3ic_id,
      region: region,
      department: department,
      zipcode: zipcode,
      city: city,
      last_inspection: last_inspection,
      regime: regime,
      seveso: seveso,
      state: state,
      user_id: user.id,
      duplicated_from_id: id
    )

    classements.each do |classement|
      Classement.create(
        rubrique: classement.rubrique,
        regime: classement.regime,
        alinea: classement.alinea,
        rubrique_acte: classement.rubrique_acte,
        regime_acte: classement.regime_acte,
        alinea_acte: classement.alinea_acte,
        activite: classement.activite,
        date_autorisation: classement.date_autorisation,
        date_mise_en_service: classement.date_mise_en_service,
        volume: classement.volume,
        installation_id: installation_duplicated.id
      )
    end

    installation_duplicated
  end

  class << self
    def load_s3ic_id_to_envinorma_id
      result = {}
      Installation.all.pluck(:id, :s3ic_id).each do |id, s3ic_id|
        result[s3ic_id] = id
      end
      result
    end

    def recreate_from_file(seed_file)
      puts "#{Time.now} Seeding installations..."
      batch_size = 1000
      nb_installations = `wc -l #{seed_file}`.to_i - 1 # count lines without overflowing memory
      nb_batches = (nb_installations.to_f / batch_size).ceil
      puts "#{nb_batches} batches of size #{batch_size} to process"

      # We avoid actually building batches in order to avoid memory overflow
      CSV.foreach(seed_file, headers: true).each_slice(batch_size).each_with_index do |raw_batch, batch_index|
        hash_batch = raw_batch.map { |raw| create_installation_hash(raw) }
        insert_batch(batch_index, nb_batches, hash_batch)
        GC.start if batch_index % 10 == 9 # Force garbage collection for RAM limitations
      end

      puts "...done. Inserted #{Installation.count}/#{nb_installations} installations."
    end

    private

    def create_installation_hash(installation_raw)
      {
        'name' => installation_raw['name'],
        's3ic_id' => installation_raw['s3ic_id'],
        'region' => installation_raw['region'],
        'department' => installation_raw['department'],
        'zipcode' => installation_raw['code_postal'],
        'city' => installation_raw['city'],
        'last_inspection' => installation_raw['last_inspection']&.to_date,
        'regime' => installation_raw['regime'],
        'seveso' => installation_raw['seveso'],
        'state' => installation_raw['active'],
        'created_at' => DateTime.now,
        'updated_at' => DateTime.now
      }
    end

    def validate_batch(installation_hashes)
      installation_hashes.each do |installation_hash|
        installation = Installation.new(installation_hash)

        unless installation.validate
          raise "error validations #{installation.inspect} #{installation.errors.full_messages}"
        end
      end
    end

    def delete_old_objects
      AP.delete_and_reset_primary_key
      Classement.delete_and_reset_primary_key
      Prescription.delete_and_reset_primary_key
      puts 'Deleting existing Installations.' # Delete is faster than Destroy
      Installation.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Installation.table_name)
    end

    def validate_batch_and_destroy_existing_installations(installation_hashes)
      puts '...validating first batch.'
      validate_batch(installation_hashes)

      delete_old_objects
    end

    def insert_batch(batch_index, nb_batches, installation_hashes)
      validate_batch_and_destroy_existing_installations(installation_hashes) if batch_index.zero?
      puts "...inserting batch #{batch_index + 1}/#{nb_batches}"
      inserted_ids = Installation.insert_all(installation_hashes)
      missing_insertions = installation_hashes.length - inserted_ids.length
      puts "Warning: #{missing_insertions} installations were not inserted!" unless missing_insertions.zero?
    end
  end
end
