# frozen_string_literal: true

DataManager.seed_installations_and_associations(false)
DataManager.seed_ams

# Make after_party tasks to status "up" to skip them
pending_files = AfterParty::TaskRecorder.pending_files

if pending_files.present?
  pending_files.each do |pending_file|
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(pending_file.filename).timestamp
  end
end
