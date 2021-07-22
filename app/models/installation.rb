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

  # Validation below ensures that one user can duplicate the installation only once
  # Rubocop does not recommend this validation as it can get slow
  # For now, we can afford this validation so we disable this warning.
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :user_id, uniqueness: { scope: :duplicated_from_id, if: -> { duplicated_from_id.present? } }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  scope :not_attached_to_user, -> { where(user: nil) }

  def retrieve_aps
    if duplicated_from_id?
      Installation.find(duplicated_from_id).APs
    else
      self.APs
    end
  end

  def fictive?
    s3ic_id == '0000.00000'
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
    def create_hash_from_csv_row(installation_raw)
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
  end
end
