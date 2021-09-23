# frozen_string_literal: true

require 'open-uri'

ActiveRecord::Base.logger.level = 1

class DataManager
  SEED_FOLDER = Rails.root.join('db/seeds')
  AM_SEED_FOLDER = SEED_FOLDER.join('ams')
  AM_URL = 'http://storage.sbg.cloud.ovh.net/v1/AUTH_3287ea227a904f04ad4e8bceb0776108/am/ams/latest.zip'

  def self.seed_ams(from_ovh:)
    download_ams_zip_from_ovh if from_ovh

    ams_files = Dir.glob(AM_SEED_FOLDER.join('*.json'))
    AMManager.validate_then_recreate(ams_files)
  end

  def self.seed_installations_and_associations(validate:, use_sample: false)
    installations_file, classements_file, aps_file = fetch_installation_files(use_sample)
    InstallationsManager.seed(validate, installations_file, classements_file, aps_file)
  end

  def self.seed_aps(use_sample: false)
    _, _, aps_file = fetch_installation_files(use_sample)
    InstallationsManager.seed_aps(aps_file)
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
      ClassementReference.create!(
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

  def self.download_ams_zip_from_ovh
    flush_folder(AM_SEED_FOLDER)
    Tempfile.create do |file|
      download_file(AM_URL, file.path)
      Zip::File.open(file.path) do |zip_file|
        zip_file.each do |entry|
          entry.extract(AM_SEED_FOLDER.join(entry.name))
        end
      end
    end
  end

  def self.flush_folder(folder)
    folder.children.each(&:delete)
  end

  def self.download_file(url, filename)
    Rails.logger.info("Downloading #{url} to #{filename}.")
    download = URI.parse(url).open
    IO.copy_stream(download, filename)
    Rails.logger.info("Downloaded #{url} to #{filename}.")
  end
end
