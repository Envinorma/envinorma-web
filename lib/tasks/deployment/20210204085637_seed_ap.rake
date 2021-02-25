# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: seed_ap_from_csv_list'
  task seed_ap: :environment do
    puts "Running deploy task 'seed_ap'"

    # Put your task implementation HERE.
    require 'csv'

    path = File.join(Rails.root, 'db', 'seeds', 'aps_idf.csv')
    arretes_prefectoraux = CSV.parse(File.read(path), headers: true)

    arretes_prefectoraux.each do |ap|
      ap = AP.create(
        installation_s3ic_id: ap['installation_s3ic_id'],
        description: ap['description'],
        date: ap['date'],
        url: ap['url'],
        installation_id: Installation.find_by(s3ic_id: ap['installation_s3ic_id'])&.id
      )

      puts "AP not created for installation #{ap['installation_s3ic_id']}" unless ap.save
    end

    puts 'Arretes prefectoraux are seeded'

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
