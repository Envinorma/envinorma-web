# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: update_am_from_new_json_list'
  task update_am: :environment do
    puts "Running deploy task 'update_am'"

    # add cid to all arrete in BDD
    Arrete.all.each do |arrete|
      arrete.update!(cid: arrete.data.id)
    end

    puts 'Arretes updated with cid'

    # update AM with new json list
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

        arrete.data.classements_with_alineas.each do |arrete_classement|
          classements = Classement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
          classements.each do |classement|
            ArretesClassement.create(arrete_id: arrete.id, classement_id: classement.id)
          end
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

    # recreate enriched arretes
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

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
