namespace :after_party do
  desc 'Deployment task: seed_arretes_and_installations'
  task seed_arretes_and_installations: :environment do
    puts "Running deploy task 'seed_arretes_and_installations'"

    # Put your task implementation HERE.
    DataManager.seed_arretes_and_associations
    DataManager.seed_installations_and_associations(false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end