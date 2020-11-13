#create installations
Installation.create(name: "Eva Industries", date: Date.today)
Installation.create(name: "France Démolition", date: Date.today)
puts "Installations are seeded"

#create classements
Classement.create(rubrique: 2521, regime: "enregistrement", alinea: "1", installation_id: 1)
Classement.create(rubrique: 2517, regime: "déclaration", alinea: "3", installation_id: 1)
Classement.create(rubrique: 2515, regime: "déclaration", alinea: "1c", installation_id: 1)
Classement.create(rubrique: 4801, regime: "déclaration", alinea: "2", installation_id: 1)
puts "Classements are seeded"

#create arretes
path = File.join(File.dirname(__FILE__), "./seeds/TREP1900331A/date-d-installation_<_2019-04-09_00:00:00.json")
arrete_2521 = JSON.parse(File.read(path))
Arrete.create(name: "04/04/19 - 2521", data: arrete_2521, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/TREP1900331A/date-d-installation_>=_2019-04-09_00:00:00.json")
arrete_2521 = JSON.parse(File.read(path))
Arrete.create(name: "04/04/19 - 2521", data: arrete_2521, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/ATEP9760292A/unique_version.json")
arrete_2517 = JSON.parse(File.read(path))
Arrete.create(name: "30/06/97 - 2517", data: arrete_2517, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/DEVP1235896A/date-d-installation_<_2012-11-26_00:00:00.json")
arrete_2515 = JSON.parse(File.read(path))
Arrete.create(name: "26/11/12 - 2515", data: arrete_2515, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/DEVP1235896A/date-d-installation_>=_2012-11-26_00:00:00.json")
arrete_2515 = JSON.parse(File.read(path))
Arrete.create(name: "26/11/12 - 2515", data: arrete_2515, installation_id: 1)

puts "Arretes are seeded"
