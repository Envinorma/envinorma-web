namespace :after_party do
  desc 'Deployment task: seed_ams'
  task seed_ams: :environment do
    puts "Running deploy task 'seed_ams'"

    # Put your task implementation HERE.
    DataManager.seed_ams_and_associations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end