# frozen_string_literal: true

require 'open-uri'

ActiveRecord::Base.logger.level = 1

class DataManager
  SEED_FOLDER = Rails.root.join('db/seeds')
  AM_SEED_FOLDER = SEED_FOLDER.join('ams')
  AM_URL = 'http://storage.sbg.cloud.ovh.net/v1/AUTH_3287ea227a904f04ad4e8bceb0776108/am/ams/latest.zip'
  MISC_BUCKET_URL = 'http://storage.sbg.cloud.ovh.net/v1/AUTH_3287ea227a904f04ad4e8bceb0776108/misc'

  def self.seed_ams(from_ovh:)
    download_ams_zip_from_ovh if from_ovh

    ams_files = Dir.glob(AM_SEED_FOLDER.join('*.json'))
    AMManager.validate_then_recreate(ams_files)
  end

  def self.seed_installations_and_associations(validate:, use_sample: false)
    Rails.logger.info("Seeding installations '#{file_suffix(use_sample)}'.")
    installations_file, classements_file, aps_file = installation_files(use_sample)
    InstallationsManager.seed(validate, installations_file, classements_file, aps_file)
  end

  def self.update_aps(from_ovh:, use_sample: false)
    Rails.logger.info("Seeding aps '#{file_suffix(use_sample)}'.")
    download_aps_from_ovh if from_ovh
    InstallationsManager.seed_aps(aps_file(use_sample))
  end

  def self.aps_file(use_sample)
    installation_files(use_sample).last
  end

  def self.installation_files(use_sample)
    suffix = file_suffix(use_sample)
    %w[installations classements aps].map { |type| SEED_FOLDER.join("#{type}_#{suffix}.csv") }
  end

  def self.file_suffix(use_sample)
    use_sample ? 'sample_rspec' : 'all'
  end

  def self.seed_classement_references
    Rails.logger.info('Seeding classement_references.')
    classement_references_file = SEED_FOLDER.join('classement_references.csv')
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

  def self.download_aps_from_ovh
    download_file("#{MISC_BUCKET_URL}/aps_all.csv", aps_file(false))
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
