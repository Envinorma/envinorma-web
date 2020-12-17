path = File.join(File.dirname(__FILE__), "./seeds/am_list.json")
am_list = JSON.parse(File.read(path))
am_list.each do |am|
  Arrete.create(
    data: am,
    short_title: am["short_title"],
    title: am.dig("title", "text"),
    unique_version: am["unique_version"],
    installation_date_criterion_left: am.dig("installation_date_criterion", "installation_date_criterion_left"),
    installation_date_criterion_right: am.dig("installation_date_criterion", "installation_date_criterion_right"),
    aida_url: am["aida_url"],
    legifrance_url: am["legifrance_url"],
    summary: am["summary"]
  )
end
puts "Arretes are seeded"


require 'csv'
path = File.join(File.dirname(__FILE__), "./seeds/installations.csv")
installations_list = CSV.parse(File.read(path), headers: true)
installations_list.each do |installation|
  Installation.create(
    name: installation["name"],
    s3ic_id: installation["s3ic_id"],
    region: installation["region"],
    department: installation["department"],
    zipcode: installation["code_postal"],
    city: installation["city"],
    last_inspection: installation["last_inspection"]&.to_date,
    regime: installation["regime"],
    seveso: installation["seveso"],
    state: installation["active"])
end
puts "Installations are seeded"


path = File.join(File.dirname(__FILE__), "./seeds/classements.csv")
classements_list = CSV.parse(File.read(path), headers: true)

classements_list.each do |classement|
  if classement["etat_activite"] == "1"
    Classement.create(
      rubrique: classement["code_nomenclature"],
      regime: classement["id_regime"],
      alinea: classement["alinea"],
      activite: classement["activite_nomenclature_inst"],
      date_autorisation: classement["date_autorisation"]&.to_date,
      volume: "#{classement['volume_inst']} #{classement['unite']}",
      installation_id: Installation.find_by(s3ic_id: classement["installation_id"])&.id)
  end
end
puts "Classements are seeded"


Arrete.all.each do |arrete|
  arrete.data.classements.each do |arrete_classement|
    classements = Classement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
    classements.each do |classement|
      ArretesClassement.create(arrete_id: arrete.id, classement_id: classement.id)
    end
  end
end
puts "ArreteClassement are seeded"


Dir.glob("#{Rails.root}/db/seeds/enriched_arretes/*.json").each do |json_file|
  am = JSON.parse(File.read(json_file))

  EnrichedArrete.create(
    data: am,
    short_title: am["short_title"],
    title: am.dig("title", "text"),
    unique_version: am["unique_version"],
    installation_date_criterion_left: am.dig("installation_date_criterion", "installation_date_criterion_left"),
    installation_date_criterion_right: am.dig("installation_date_criterion", "installation_date_criterion_right"),
    aida_url: am["aida_url"],
    legifrance_url: am["legifrance_url"],
    summary: am["summary"],
    arrete_id: Arrete.find_by("data->>'id' = ?", "#{am["id"]}").id
  )
end
puts "Enriched Arretes are seeded"
