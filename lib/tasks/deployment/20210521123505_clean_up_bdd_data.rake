namespace :after_party do
  desc 'Deployment task: clean_up_bdd_data'
  task clean_up_bdd_data: :environment do
    puts "Running deploy task 'clean_up_bdd_data'"

    # Put your task implementation HERE.
    User.destroy_all
    Installation.where.not(user: nil).destroy_all
    Prescription.destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
