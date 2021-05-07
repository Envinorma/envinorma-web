namespace :after_party do
  desc 'Deployment task: remove_alinea_ids'
  task remove_alinea_ids: :environment do
    puts "Running deploy task 'remove_alinea_ids'"

    # Put your task implementation HERE.
    DataManager.seed_arretes_and_associations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end