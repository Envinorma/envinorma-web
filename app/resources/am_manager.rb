# frozen_string_literal: true

class AMsManager
  def self.validate_then_recreate(ams_files)
    Rails.logger.info("Seeding #{ams_files.length} ams...")
    ams_to_seed = initialize_ams(ams_files)
    ams_in_db = fetch_existing_ams
    recreate(ams_to_seed, ams_in_db)
    Rails.logger.info("#{AM.count}/#{ams_files.length} ams are in db.")
  end

  def self.initialize_ams(ams_files)
    ams = {}
    ams_files.each_with_index do |json_file, index|
      am_hash = JSON.parse(File.read(json_file))
      am = AM.from_hash(am_hash)
      ams[am.version_identifier] = am
      Rails.logger.info("#{index + 1} ams initialized") if index % 10 == 9
    end
    ams
  end

  def self.fetch_existing_ams
    ams = {}
    AM.all.map { |am| ams[am.version_identifier] = am }
    ams
  end

  def self.recreate(ams_to_seed, ams_in_db)
    ids_to_insert, ids_to_delete, ids_to_update = split_ids(ams_to_seed, ams_in_db)
    insert_new_ams(ids_to_insert, ams_to_seed)
    delete_old_ams(ids_to_delete)
    update_existing_ams(ids_to_update)
  end

  def self.split_ids(ams_to_seed, ams_in_db)
    # Creates new AMs, updates existing AMs, and deletes AMs that are not in the seed file
    ams_to_insert = ams_to_seed.keys - ams_in_db.keys
    Rails.logger.info("#{ams_to_insert.length} new AMs to create.")
    ams_to_delete = ams_in_db.keys - ams_to_seed.keys
    Rails.logger.info("#{ams_to_delete.length} AMs to delete.")
    ams_to_update = ams_in_db.keys & ams_to_seed.keys
    Rails.logger.info("#{ams_to_update.length} AMs to update.")
    [ams_to_insert, ams_to_delete, ams_to_update]
  end

  def self.insert_new_ams(ids_to_insert, ams_to_seed)
    Rails.logger.info("Inserting #{ids_to_insert.length} AMs...")
    ids_to_insert.each { |id| ams_to_seed[id].save }
    Rails.logger.info('...done.')
  end

  def self.delete_old_ams(ids_to_delete)
    Rails.logger.info("Deleting #{ids_to_delete.length} AMs...")
    ids_to_delete.each do |id|
      AM.find(id).destroy
    end
    Rails.logger.info('...done.')
    delete_associated_prescriptions(ids_to_delete)
  end

  def self.delete_associated_prescriptions(ids_to_delete)
    Rails.logger.info('Deleting associated prescriptions...')
    deleted = Prescription.where(from_am_id: ids_to_delete).destroy_all
    Rails.logger.info("Deleted #{deleted.count} prescriptions.")
  end

  def self.update_existing_ams(ids_to_update)
    Rails.logger.info("Updating #{ids_to_update.length} AMs...")
    ids_to_update.each_with_index do |id, index|
      am = AM.find(id)
      am.update(ams_to_seed[id].to_hash)
      if different_content?(am, ams_to_seed[id])
        am.content_updated_at = DateTime.now
        am.save
      end
      Rails.logger.info("#{index + 1} ams updated") if index % 10 == 9
    end
    Rails.logger.info("...done. Updated #{AM.count}/#{ids_to_update.length} ams.")
  end

  def different_content?(_am_1, _am_2)
    raise 'Not implemented'
    # TODO
  end
end
