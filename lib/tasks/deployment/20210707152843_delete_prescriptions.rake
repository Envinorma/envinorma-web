namespace :after_party do
  desc 'Deployment task: delete_prescriptions'
  task delete_prescriptions: :environment do
    puts "Running deploy task 'delete_prescriptions'"

    # Put your task implementation HERE.
    Prescription.destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end