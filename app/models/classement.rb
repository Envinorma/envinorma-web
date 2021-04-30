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
    def validate_then_recreate(classements_list)
      puts 'Seeding classements...'
      puts '...validating'
      classements = []
      classements_list.each do |classement_raw|
        installation_id = Installation.find_by(s3ic_id: classement_raw['s3ic_id'])&.id
        next unless installation_id

        classement = Classement.new(
          rubrique: classement_raw['rubrique'],
          regime: classement_raw['regime'],
          alinea: classement_raw['alinea'],
          rubrique_acte: classement_raw['rubrique_acte'],
          regime_acte: classement_raw['regime_acte'],
          alinea_acte: classement_raw['alinea_acte'],
          activite: classement_raw['activite'],
          date_autorisation: classement_raw['date_autorisation']&.to_date,
          volume: "#{classement_raw['volume']} #{classement_raw['unit']}",
          installation_id: installation_id
        )
        raise "error validations #{classement.inspect} #{classement.errors.full_messages}" unless classement.validate

        classements << classement
      end
      recreate(classements)
    end

    private

    def recreate(classements)
      puts '...destroying'
      Classement.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Classement.table_name)
      puts '...creating'
      classements.each(&:save)
      puts "...done. Inserted #{Classement.count}/#{classements.length} classements."
    end
  end
end
