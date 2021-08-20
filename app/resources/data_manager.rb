# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class DataManager
  def self.seed_ams_and_associations
    ams_files = Dir.glob(Rails.root.join('db/seeds/enriched_arretes/*.json'))
    AMManager.validate_then_recreate(ams_files)
  end

  def self.seed_installations_and_associations(validate:, use_sample: false)
    installations_file, classements_file, aps_file = fetch_installation_files(use_sample)
    InstallationsManager.seed(validate, installations_file, classements_file, aps_file)
  end

  def self.fetch_installation_files(use_sample)
    seed_folder = Rails.root.join('db/seeds')

    file_suffix = use_sample ? 'sample_rspec' : 'all'
    Rails.logger.info("Seeding dataset '#{file_suffix}'.")
    installations_file = File.join(seed_folder, "installations_#{file_suffix}.csv")
    classements_file = File.join(seed_folder, "classements_#{file_suffix}.csv")
    aps_file = File.join(seed_folder, "aps_#{file_suffix}.csv")
    [installations_file, classements_file, aps_file]
  end

  def self.seed_classement_references
    Rails.logger.info('Seeding classement_references.')
    seed_folder = Rails.root.join('db/seeds')
    classement_references_file = File.join(seed_folder, 'classement_references.csv')
    delete_and_reset_primary_key(ClassementReference)
    CSV.foreach(classement_references_file, headers: true) do |row|
      ClassementReference.create(
        rubrique: row['rubrique'],
        regime: row['regime'],
        alinea: row['alinea'],
        description: row['description']
      )
    end
    Rails.logger.info("Inserted #{ClassementReference.count} classement_references.")
  end

  def self.delete_and_reset_primary_key(model)
    Rails.logger.info "Deleting existing #{model}s."
    model.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end
end
