# frozen_string_literal: true

class AMManager
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
      am_hash = parse_file(json_file)
      raise "Error: AM file #{json_file} is empty." if am_hash.nil?

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
    delete_old_ams(ids_to_delete, ams_in_db)
    update_existing_ams(ids_to_update, ams_in_db, ams_to_seed)
  end

  def self.split_ids(ams_to_seed, ams_in_db)
    # Creates new AMs, updates existing AMs, and deletes AMs that are not in the seed file
    ams_to_insert = ams_to_seed.keys - ams_in_db.keys
    ams_to_delete = ams_in_db.keys - ams_to_seed.keys
    ams_to_update = ams_in_db.keys & ams_to_seed.keys
    Rails.logger.info("#{ams_to_insert.length} AMs to create, #{ams_to_delete.length}"\
                      "AMs to delete. #{ams_to_update.length} AMs to update.")
    [ams_to_insert, ams_to_delete, ams_to_update]
  end

  def self.insert_new_ams(ids_to_insert, ams_to_seed)
    Rails.logger.info("Inserting #{ids_to_insert.length} AMs...")
    ids_to_insert.each { |id| ams_to_seed[id].save }
    Rails.logger.info('...done.')
  end

  def self.delete_old_ams(ids_to_delete, ams_in_db)
    Rails.logger.info("Deleting #{ids_to_delete.length} AMs...")
    ids_to_delete.each do |id|
      AM.find(ams_in_db[id].id).destroy
    end
    Rails.logger.info('...done.')
    delete_associated_prescriptions(ids_to_delete)
  end

  def self.delete_associated_prescriptions(ids_to_delete)
    Rails.logger.info('Deleting associated prescriptions...')
    deleted = Prescription.where(from_am_id: ids_to_delete).destroy_all
    Rails.logger.info("Deleted #{deleted.count} prescriptions.")
  end

  def self.update_existing_ams(ids_to_update, ams_in_db, ams_to_seed)
    Rails.logger.info("Updating #{ids_to_update.length} AMs...")
    nb_content_updated = 0
    ids_to_update.each_with_index do |id, index|
      am_in_db = ams_in_db[id]
      am_in_seed = ams_to_seed[id]
      update_hash = am_in_seed.to_hash
      unless same_content?(am_in_db, am_in_seed)
        update_hash['content_updated_at'] = DateTime.now unless same_content?(am_in_db, am_in_seed)
        nb_content_updated += 1
      end
      am_in_db.update(update_hash)
      Rails.logger.info("#{index + 1} ams updated") if index % 10 == 9
    end
    Rails.logger.info("...done. Updated #{AM.count}/#{ids_to_update.length} ams" \
                      " (content edited for #{nb_content_updated} ams).")
  end

  def self.parse_file(json_file)
    JSON.parse(File.read(json_file))
  end

  def self.same_content?(am1, am2)
    return false if am1.title != am2.title

    sections_lists_have_same_content?(am1.data.sections, am2.data.sections)
  end

  def self.sections_lists_have_same_content?(sections1, sections2)
    return false if sections1.count != sections2.count

    sections1.zip(sections2).each do |section1, section2|
      return false unless sections_have_same_content?(section1, section2)
    end
    true
  end

  def self.sections_have_same_content?(section1, section2)
    return false if section1.title.text != section2.title.text

    return false unless sections_lists_have_same_content?(section1.sections, section2.sections)

    alineas_lists_have_same_content?(section1.outer_alineas, section2.outer_alineas)
  end

  def self.alineas_lists_have_same_content?(alineas1, alineas2)
    return false if alineas1.count != alineas2.count

    alineas1.zip(alineas2).each do |alinea1, alinea2|
      return false unless alineas_have_same_content?(alinea1, alinea2)
    end
    true
  end

  def self.alineas_have_same_content?(alinea1, alinea2)
    return false if alinea1.text != alinea2.text

    return alinea1.table.blank? && alinea2.table.blank? if alinea1.table.blank? || alinea2.table.blank?

    tables_have_same_content?(alinea1.table, alinea2.table)
  end

  def self.tables_have_same_content?(table1, table2)
    return false if table1.rows.count != table2.rows.count

    table1.rows.zip(table2.rows).each do |row1, row2|
      return false unless rows_have_same_content?(row1, row2)
    end
    true
  end

  def self.rows_have_same_content?(row1, row2)
    return false if row1.cells.count != row2.cells.count

    row1.cells.zip(row2.cells).each do |cell1, cell2|
      return false unless cells_have_same_content?(cell1, cell2)
    end
    true
  end

  def self.cells_have_same_content?(cell1, cell2)
    cell1.content.text == cell2.content.text
  end
end
