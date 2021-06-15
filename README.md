# Envinorma

Envinorma cherche à faciliter la préparation des inspections en simplifiant l'accès à la réglementation applicables aux industries non nucléaires en France ([les ICPE](https://fr.wikipedia.org/wiki/Installation_class%C3%A9e_pour_la_protection_de_l'environnement)).

Ce projet est réalisé dans le cadre du programme [EIG](https://entrepreneur-interet-general.etalab.gouv.fr/).


Pour en savoir plus, vous pouvez consulter [la page du projet](https://entrepreneur-interet-general.etalab.gouv.fr/defis/2020/envinorma.html) ou vous rendre sur [l'application](envinorma.herokuapp.com/).


## Lancer l'application en local

### Télécharger l'application
```
git clone git@github.com:Envinorma/envinorma-web.git
cd envinorma-web
bundle install
```

### Seeder les données et lancer le serveur
```
rails db:seed
rails -s
```
Vous pouvez maintenant vous rendre sur l'URL `localhost:3000` et vous devriez pouvoir utiliser l'application en local.

### Lancer les tests
```
bundle exec rspec # unit and features tests
rubocop #linter ruby
slim-lint app/views/ #linter slim
```
