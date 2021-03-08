# frozen_string_literal: true

class Arrete < ApplicationRecord
  has_many :arretes_unique_classements, dependent: :delete_all
  has_many :unique_classements, through: :arretes_unique_classements
  has_many :enriched_arretes, dependent: :destroy

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def self.recreate!(arretes_list)
    Arrete.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Arrete.table_name)

    arretes_list.each do |am|
      arrete = Arrete.create!(
        data: am,
        cid: am['id'],
        short_title: am['short_title'],
        title: am.dig('title', 'text'),
        unique_version: am['unique_version'],
        installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
        installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
        aida_url: am['aida_url'],
        legifrance_url: am['legifrance_url'],
        summary: am['summary']
      )

      arrete.data.classements_with_alineas.each do |arrete_classement|
        classements = UniqueClassement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
        classements.each do |classement|
          ArretesUniqueClassement.create(arrete_id: arrete.id, unique_classement_id: classement.id)
        end
      end
    end
  end
end
