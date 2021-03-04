# frozen_string_literal: true

class UpdateData
  def self.update_am
    ids = []
    path = File.join(Rails.root, 'db', 'seeds', 'am_list.json')
    am_list = JSON.parse(File.read(path))
    am_list.each do |am|
      arrete = Arrete.find_by(cid: am['id'])

      if arrete.present?
        arrete.update!(
          data: am,
          short_title: am['short_title'],
          title: am.dig('title', 'text'),
          unique_version: am['unique_version'],
          installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
          installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
          aida_url: am['aida_url'],
          legifrance_url: am['legifrance_url'],
          summary: am['summary']
        )

        arrete.arretes_unique_classements.delete_all
      else
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
      end

      arrete.data.classements_with_alineas.each do |arrete_classement|
        classements = UniqueClassement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
        classements.each do |classement|
          ArretesUniqueClassement.create(arrete_id: arrete.id, unique_classement_id: classement.id)
        end
      end

      ids << am['id']
    end

    # delete AM in BDD if not present in json list
    ids_to_remove = Arrete.all.pluck(:cid) - ids
    if ids_to_remove.present?
      ids_to_remove.each do |id|
        Arrete.find_by(cid: id).destroy!
        puts "Arrete width cid : #{id} has been deleted"
      end
    end

    puts 'Arretes updated with new json list'
  end

  def self.recreate_enriched_am
    EnrichedArrete.destroy_all

    Dir.glob("#{Rails.root}/db/seeds/enriched_arretes/*.json").each do |json_file|
      am = JSON.parse(File.read(json_file))
      EnrichedArrete.create(
        data: am,
        short_title: am['short_title'],
        title: am.dig('title', 'text'),
        unique_version: am['unique_version'],
        installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
        installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
        aida_url: am['aida_url'],
        legifrance_url: am['legifrance_url'],
        summary: am['summary'],
        arrete_id: Arrete.find_by(cid: am['id']).id
      )
    end

    puts 'Enriched arretes are created'
  end
end
