namespace :after_party do
  desc 'Deployment task: remove_enriched_arretes'
  task remove_enriched_arretes: :environment do
    puts "Running deploy task 'remove_enriched_arretes'"

    # Put your task implementation HERE.
    EnrichedArrete.delete_all
    DataManager.seed_arretes_and_associations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end