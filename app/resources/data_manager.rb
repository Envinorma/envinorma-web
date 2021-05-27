# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class DataManager
  def self.seed_installations_and_associations
    installations_list = parse_seed_csv('installations_all.csv')
    Installation.validate_then_recreate(installations_list)

    classements_list = parse_seed_csv('classements_all.csv')
    Classement.validate_then_recreate(classements_list)

    seed_aps
  end

  def self.seed_aps
    aps_list = parse_seed_csv('aps_all.csv')
    AP.validate_then_recreate(aps_list)
  end

  def self.seed_arretes_and_associations
    arretes_list = parse_seed_json('am_list.json')
    enriched_arretes_files = Dir.glob("#{Rails.root}/db/seeds/enriched_arretes/*.json")
    Arrete.validate_then_recreate(arretes_list, enriched_arretes_files)
  end

  def self.update_am
    ids = []
    path = File.join(Rails.root, 'db', 'seeds', 'am_list.json')
    am_list = JSON.parse(File.read(path))
    am_list.each do |am|
      arrete = Arrete.find_by(cid: am['id'])

      if arrete.present?
        arrete.update!(
          data: am,
          date_of_signature: am['date_of_signature'].to_date,
          title: am.dig('title', 'text'),
          unique_version: am['unique_version'],
          installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
          installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
          aida_url: am['aida_url'],
          legifrance_url: am['legifrance_url']
        )

        arrete.arretes_unique_classements.delete_all
      else
        arrete = Arrete.create!(
          data: am,
          cid: am['id'],
          date_of_signature: am['date_of_signature'].to_date,
          title: am.dig('title', 'text'),
          unique_version: am['unique_version'],
          installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
          installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
          aida_url: am['aida_url'],
          legifrance_url: am['legifrance_url']
        )
      end

      arrete.classements_with_alineas.each do |arrete_classement|
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

  def self.parse_seed_csv(doc_name)
    path = File.join(Rails.root, 'db', 'seeds', doc_name)
    CSV.parse(File.read(path), headers: true)
  end

  def self.parse_seed_json(doc_name)
    path = File.join(Rails.root, 'db', 'seeds', doc_name)
    JSON.parse(File.read(path))
  end
end
