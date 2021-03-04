namespace :after_party do
  desc 'Deployment task: seed_unique_classements'
  task seed_unique_classements: :environment do
    puts "Running deploy task 'seed_unique_classements'"

    # Put your task implementation HERE.
    require 'csv'

    path = File.join(Rails.root, 'db', 'seeds', 'unique_classements.csv')
    unique_classements = CSV.parse(File.read(path), headers: true)

    unique_classements.each do |classement|
      UniqueClassement.create(
        rubrique: classement['rubrique'],
        regime: classement['regime'],
        alinea: classement['alinea']
      )
    end
    puts 'UniqueClassement are seeded'

    Arrete.all.each do |arrete|
      arrete.data.classements_with_alineas.each do |arrete_classement|
        classements = UniqueClassement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
        classements.each do |classement|
          ArretesUniqueClassement.create(arrete_id: arrete.id, unique_classement_id: classement.id)
        end
      end
    end
    puts 'ArretesUniqueClassement are seeded'

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
