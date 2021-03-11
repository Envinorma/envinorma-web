# frozen_string_literal: true

class Classement < ApplicationRecord
  belongs_to :installation

  validates :regime, :rubrique, presence: true
  validates :regime, inclusion: { in: %w[A E D NC unknown], message: 'is not valid' }
  validates :regime_acte, inclusion: { in: %w[A E D NC unknown], message: 'is not valid', allow_blank: true }

  def self.recreate!(classements_list)
    Classement.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Classement.table_name)

    classements_list.each do |classement|
      Classement.create(
        rubrique: classement['rubrique'],
        regime: classement['regime'],
        alinea: classement['alinea'],
        rubrique_acte: classement['rubrique_acte'],
        regime_acte: classement['regime_acte'],
        alinea_acte: classement['alinea_acte'],
        activite: classement['activite'],
        date_autorisation: classement['date_autorisation']&.to_date,
        volume: "#{classement['volume']} #{classement['unit']}",
        installation_id: Installation.find_by(s3ic_id: classement['s3ic_id'])&.id
      )
    end
    puts 'Classements are seeded'
  end
end
