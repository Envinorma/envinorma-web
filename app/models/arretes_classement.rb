# frozen_string_literal: true

class ArretesClassement < ApplicationRecord
  belongs_to :arrete
  belongs_to :classement

  def self.update_for(classement)
    arretes = []
    ArretesClassement.where(classement_id: classement.id).delete_all
    arretes << Arrete.where("data -> 'classements' @> ?",
                            [{ rubrique: classement.rubrique.to_s, regime: classement.regime.to_s }].to_json)

    arretes.flatten.each do |arrete|
      ArretesClassement.create(arrete_id: arrete.id, classement_id: classement.id)
    end
  end
end
