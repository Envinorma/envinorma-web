namespace :after_party do
  desc 'Deployment task: add_publication_date_in_arrete'
  task add_publication_date_in_arrete: :environment do
    puts "Running deploy task 'add_publication_date_in_arrete'"

    # Put your task implementation HERE.
    DataManager.seed_arretes_and_associations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end