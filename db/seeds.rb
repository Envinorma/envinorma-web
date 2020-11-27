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
Arrete.create(
    name: "AM - 2521",
    data: arrete_2521,
    installation_id: 1,
    short_title: "Arrêté du 9 avril 2019",
    title: "Arrêté du 9 avril 2019 relatif aux prescriptions générales applicables aux installations relevant du régime de l'enregistrement au titre de la rubrique n° 2521 de la nomenclature des installations classées pour la protection de l'environnement - Enrobage au bitume de matériaux routiers (Centrale d')",
    unique_version: false,
    installation_date_criterion_left: nil,
    installation_date_criterion_right: "2019-04-09",
    aida_url: "https://aida.ineris.fr/consultation_document/41901",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000038358856",
)


path = File.join(File.dirname(__FILE__), "./seeds/TREP1900331A/date-d-installation_>=_2019-04-09.json")
arrete_2521 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 2521",
    data: arrete_2521,
    installation_id: 1,
    short_title: "Arrêté du 9 avril 2019",
    title: "Arrêté du 9 avril 2019 relatif aux prescriptions générales applicables aux installations relevant du régime de l'enregistrement au titre de la rubrique n° 2521 de la nomenclature des installations classées pour la protection de l'environnement - Enrobage au bitume de matériaux routiers (Centrale d')",
    unique_version: false,
    installation_date_criterion_left: "2019-04-09",
    installation_date_criterion_right: nil,
    aida_url: "https://aida.ineris.fr/consultation_document/41901",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000038358856",
)


path = File.join(File.dirname(__FILE__), "./seeds/TREP1900331A/no_date_version.json")
arrete_2521 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 2521",
    data: arrete_2521,
    installation_id: 1,
    short_title: "Arrêté du 9 avril 2019",
    title: "Arrêté du 9 avril 2019 relatif aux prescriptions générales applicables aux installations relevant du régime de l'enregistrement au titre de la rubrique n° 2521 de la nomenclature des installations classées pour la protection de l'environnement - Enrobage au bitume de matériaux routiers (Centrale d')",
    unique_version: false,
    installation_date_criterion_left: nil,
    installation_date_criterion_right: nil,
    aida_url: "https://aida.ineris.fr/consultation_document/41901",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000038358856",
)


path = File.join(File.dirname(__FILE__), "./seeds/ATEP9760292A/no_date_version.json")
arrete_2517 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 2517",
    data: arrete_2517,
    installation_id: 1,
    short_title: "Arrêté du 30 juin 1997",
    title: "Arrêté du 30 juin 1997 relatif aux prescriptions générales applicables aux installations classées pour la protection de l'environnement soumises à déclaration sous la rubrique n° 2517 (Station de transit de produits minéraux solides, à l'exclusion de ceux visés par d'autres rubriques)",
    unique_version: true,
    installation_date_criterion_left: nil,
    installation_date_criterion_right: nil,
    aida_url: "https://aida.ineris.fr/consultation_document/5693",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000000369330",
)


path = File.join(File.dirname(__FILE__), "./seeds/ATEP9760290A/no_date_version.json")
arrete_2515 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 2515",
    data: arrete_2515,
    installation_id: 1,
    short_title: "Arrêté du 30 juin 1997",
    title: "Arrêté du 30 juin 1997 relatif aux prescriptions générales applicables aux installations classées pour la protection de l'environnement soumises à déclaration sous la rubrique n° 2515 (Broyage, concassage, criblage, ensachage, pulvérisation, nettoyage, tamisage, mélange de pierres, cailloux, minerais et autres produits minéraux naturels ou artificiels)",
    unique_version: true,
    installation_date_criterion_left: nil,
    installation_date_criterion_right: nil,
    aida_url: "https://aida.ineris.fr/consultation_document/5689",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000000552021",
)


path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_after_2017.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 1510",
    data: arrete_1510,
    installation_id: 2,
    short_title: "Arrêté du 11 avril 2017",
    title: "Arrêté du 11 avril 2017 relatif aux prescriptions générales applicables aux entrepôts couverts soumis à la rubrique 1510, y compris lorsqu'ils relèvent également de l'une ou plusieurs des rubriques 1530, 1532, 2662 ou 2663 de la nomenclature des installations classées pour la protection de l'environnement",
    unique_version: false,
    installation_date_criterion_left: "2017-07-01",
    installation_date_criterion_right: nil,
    aida_url: "https://aida.ineris.fr/consultation_document/39061",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000034429274",
)


path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_before_2003.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 1510",
    data: arrete_1510,
    installation_id: 2,
    short_title: "Arrêté du 11 avril 2017",
    title: "Arrêté du 11 avril 2017 relatif aux prescriptions générales applicables aux entrepôts couverts soumis à la rubrique 1510, y compris lorsqu'ils relèvent également de l'une ou plusieurs des rubriques 1530, 1532, 2662 ou 2663 de la nomenclature des installations classées pour la protection de l'environnement",
    unique_version: false,
    installation_date_criterion_left: nil,
    installation_date_criterion_right: "2003-07-01",
    aida_url: "https://aida.ineris.fr/consultation_document/39061",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000034429274",
)


path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_between_2003_and_2010.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 1510",
    data: arrete_1510,
    installation_id: 2,
    short_title: "Arrêté du 11 avril 2017",
    title: "Arrêté du 11 avril 2017 relatif aux prescriptions générales applicables aux entrepôts couverts soumis à la rubrique 1510, y compris lorsqu'ils relèvent également de l'une ou plusieurs des rubriques 1530, 1532, 2662 ou 2663 de la nomenclature des installations classées pour la protection de l'environnement",
    unique_version: false,
    installation_date_criterion_left: "2003-07-01",
    installation_date_criterion_right: "2009-04-30",
    aida_url: "https://aida.ineris.fr/consultation_document/39061",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000034429274",
)


path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_AND_date_between_2010_and_2017.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 1510",
    data: arrete_1510,
    installation_id: 2,
    short_title: "Arrêté du 11 avril 2017",
    title: "Arrêté du 11 avril 2017 relatif aux prescriptions générales applicables aux entrepôts couverts soumis à la rubrique 1510, y compris lorsqu'ils relèvent également de l'une ou plusieurs des rubriques 1530, 1532, 2662 ou 2663 de la nomenclature des installations classées pour la protection de l'environnement",
    unique_version: false,
    installation_date_criterion_left: "2010-04-16",
    installation_date_criterion_right: "2017-07-01",
    aida_url: "https://aida.ineris.fr/consultation_document/39061",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000034429274",
)


path = File.join(File.dirname(__FILE__), "./seeds/DEVP1706393A/reg_E_no_date.json")
arrete_1510 = JSON.parse(File.read(path))
Arrete.create(
    name: "AM - 1510",
    data: arrete_1510,
    installation_id: 2,
    short_title: "Arrêté du 11 avril 2017",
    title: "Arrêté du 11 avril 2017 relatif aux prescriptions générales applicables aux entrepôts couverts soumis à la rubrique 1510, y compris lorsqu'ils relèvent également de l'une ou plusieurs des rubriques 1530, 1532, 2662 ou 2663 de la nomenclature des installations classées pour la protection de l'environnement",
    unique_version: false,
    installation_date_criterion_left: nil,
    installation_date_criterion_right: nil,
    aida_url: "https://aida.ineris.fr/consultation_document/39061",
    legifrance_url: "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000034429274",
)

puts "Arretes are seeded"
