# frozen_string_literal: true

class Classement < ApplicationRecord
  include RegimeHelper

  belongs_to :installation

  validates :regime, :rubrique, :installation_id, presence: true
  validates :regime, inclusion: { in: %w[A E D NC unknown], message: 'is not valid' }
  validates :regime_acte, inclusion: { in: %w[A E D NC unknown], message: 'is not valid', allow_blank: true }

  validate :volume_format

  def volume_format
    start_with_number = (volume =~ /\A[0-9]+([.,][0-9]+)?\z/) || (volume =~ /\A[0-9]+([.,][0-9]+)?\s.+/)
    return unless volume.present? && !start_with_number

    errors.add(:volume,
               "doit démarrer par un chiffre. Ce chiffre doit être suivi d'un espace s'il est accompagné d'une unité")
  end

  def volume
    words = (super || '').split
    return super if words.length.zero?

    volume_number = simplify_volume((words.first || '').gsub(',', '.'))
    volume_unit = words[1..].join(' ')
    "#{volume_number} #{volume_unit}".strip
  end

  def float_volume
    volume_string = (volume || '').split.first

    return volume.to_f if float?(volume_string)
  end

  def float?(string)
    true if Float(string)
  rescue StandardError
    false
  end

  def int?(string)
    # of the 'X.000' when from georisques
    # of the 'X' when from user
    !(string =~ /\A[0-9]+(\.000)?\z/).nil?
  end

  def simplify_volume(volume)
    return if volume.blank?
    return volume.to_i if int?(volume)
    return volume.to_f if float?(volume)

    volume
  end

  def regime_score
    regime.present? ? REGIMES[regime] : REGIMES[:empty]
  end

  class << self
    def create_from(installation_id, reference, params)
      Classement.create(installation_id: installation_id, rubrique: reference.rubrique,
                        regime: reference.regime, alinea: reference.alinea,
                        activite: reference.description,
                        date_autorisation: params[:date_autorisation],
                        date_mise_en_service: params[:date_mise_en_service],
                        volume: params[:volume])
    end

    def create_hash_from_csv_row(classement_raw)
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
        'created_at' => DateTime.now,
        'updated_at' => DateTime.now
      }
    end
  end
end
