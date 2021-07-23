namespace :after_party do
  desc 'Deployment task: seed_classements_references'
  task seed_classements_references: :environment do
    puts "Running deploy task 'seed_classements_references'"

    # Put your task implementation HERE.
    DataManager.seed_classement_references

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end