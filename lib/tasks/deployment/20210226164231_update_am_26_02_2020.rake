namespace :after_party do
  desc 'Deployment task: update_am_26_02_2020'
  task update_am_26_02_2020: :environment do
    puts "Running deploy task 'update_am_26_02_2020'"

    UpdateData.update_am
    UpdateData.recreate_enriched_am

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
