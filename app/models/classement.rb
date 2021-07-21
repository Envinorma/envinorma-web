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
    def create_hash_from_csv_row(classement_raw, s3ic_id_to_envinorma_id)
      s3ic_id = classement_raw['s3ic_id']
      if s3ic_id_to_envinorma_id.nil?
        installation_id = 1
      else
        raise "s3ic_id #{s3ic_id} not found" unless s3ic_id_to_envinorma_id.key?(s3ic_id)

        installation_id = s3ic_id_to_envinorma_id[s3ic_id]
      end

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
        'installation_id' => installation_id,
        'created_at' => DateTime.now,
        'updated_at' => DateTime.now
      }
    end
  end
end
