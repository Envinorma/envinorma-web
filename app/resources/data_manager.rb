# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class DataManager
  def self.seed_installations_and_associations
    installations_list = parse_seed_csv('installations_all.csv')
    Installation.validate_then_recreate(installations_list)

    classements_list = parse_seed_csv('classements_all.csv')
    Classement.validate_then_recreate(classements_list)

    aps_list = parse_seed_csv('aps_all.csv')
    AP.validate_then_recreate(aps_list)
  end

  def self.seed_arretes_and_associations
    arretes_list = parse_seed_csv('arretes.csv')
    Arrete.validate_then_recreate(arretes_list)

    sections_list = parse_seed_csv('sections.csv')
    Section.validate_then_recreate(sections_list)

    alineas_list = parse_seed_csv('alineas.csv')
    Alinea.validate_then_recreate(alineas_list)
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
