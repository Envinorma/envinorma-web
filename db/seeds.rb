# create installations
Installation.create(name: "Eva Industries", date: "07/05/1974".to_date)
Installation.create(name: "AURILIS GROUP", date: "02/05/2007".to_date)
puts "Installations are seeded"

# create classements
# first installation
Classement.create(rubrique: "2521", regime: "E", activite: "Enrobage au bitume de matériaux routiers", alinea: "1", installation_id: 1)
Classement.create(rubrique: "2517", regime: "D", activite: "Produits minéraux ou déchets non dangereux inertes (transit)", alinea: "3", installation_id: 1)
Classement.create(rubrique: "2515", regime: "D", activite: "Broyage, concassage,...et autres produits minéraux ou déchets non dangereux inertes", alinea: "1c", installation_id: 1)

# second installation
Classement.create(rubrique: "1510", regime: "E", activite: "Entrepôts couverts autres que 1511", alinea: "2", installation_id: 2)

puts "Classements are seeded"

# create arretes
# first installation
path = File.join(File.dirname(__FILE__), "./seeds/TREP1900331A/date-d-installation_<_2019-04-09.json")
arrete_2521 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 2521", data: arrete_2521, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/TREP1900331A/date-d-installation_>=_2019-04-09.json")
arrete_2521 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 2521", data: arrete_2521, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/ATEP9760292A/unique_version.json")
arrete_2517 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 2517", data: arrete_2517, installation_id: 1)

path = File.join(File.dirname(__FILE__), "./seeds/ATEP9760290A/unique_version.json")
arrete_2515 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 2515", data: arrete_2515, installation_id: 1)

# second installation
path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_after_2017.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 1510", data: arrete_1510, installation_id: 2)

path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_before_2003.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 1510", data: arrete_1510, installation_id: 2)

path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_between_2003_and_2010.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 1510", data: arrete_1510, installation_id: 2)

path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_between_2010_and_2017.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(name: "AM - 1510", data: arrete_1510, installation_id: 2)

puts "Arretes are seeded"
