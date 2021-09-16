# Envinorma

Envinorma facilite la préparation des inspections en simplifiant l'accès à la réglementation applicables aux industries non nucléaires en France ([les ICPE](https://fr.wikipedia.org/wiki/Installation_class%C3%A9e_pour_la_protection_de_l'environnement)).

Ce projet a été lancé dans le cadre du programme [EIG](https://entrepreneur-interet-general.etalab.gouv.fr/).

#### Liens utiles :
- [la page du projet](https://entrepreneur-interet-general.etalab.gouv.fr/defis/2020/envinorma.html)
- [la documentation technique](https://envinorma.github.io/)
- [l'url de l'application](http://envinorma.herokuapp.com/)

![l'application envinorma.herokuapp.com](app/javascript/images/cover.png)


## Lancer l'application en local

### Télécharger l'application
```
git clone git@github.com:Envinorma/envinorma-web.git
cd envinorma-web
```

### Installer les librairies
```
bundle install
yarn install
```

### Seeder les données et lancer le serveur
```
rails db:create db:migrate db:seed
rails s
```
Vous pouvez maintenant vous rendre sur l'URL `localhost:3000` pour utiliser l'application en local.

### Lancer les tests
```
bundle exec rspec #unit and features tests
rubocop #linter ruby
slim-lint app/views/ #linter slim
```

> Pour mettre en place des "git hooks" afin de lancer ces tests à chaque push, exécuter `$ ./scripts/install-hooks.bash`

## Déployer sur Heroku
Installer la CLI heroku : https://devcenter.heroku.com/articles/heroku-cli

S'identifier

```
heroku login
```

Se connecter avec le dépôt distant et déployer

```
git remote add heroku https://git.heroku.com/envinorma.git
git push heroku master
```

---

## Pour aller plus loin

### Les données

Pour fonctionner l'application nécessite un certains nombres de données externes, liées aux installations et à la règlementation.
Vous trouverez dans [ce dossier](https://github.com/Envinorma/data-tasks) les différentes tâches de préparation de la donnée. Elle est ensuite incorporée dans l'application à l'aide du `DataManager`.

```
DataManager.seed_installations_and_associations(true)
#permet de seeder les installations ainsi que leurs classements et arrêtés préfectoraux associés

DataManager.seed_ams
#permet de seeder les arrêtés ministériels
```

> La donnée est simplement supprimée puis recréée.

> On utilise la gem `after_party` pour lancer des tâches au moment du déploiement. ex: lorsque que l'on met en production un nouveau lot d'arrêtés ministériels

![le schéma de la donnée](/docs/schema.png)

> La donnée des tables `installations`, `classements`, `APs` et `AMs` sont seedées à partir de scripts et ne sont pas modifiées directement par l'utilisateur. L'utilisateur peut toutefois créer de nouvelles installations (à partir de 0 ou en dupliquant des installations existantes) et y ajouter ou modifier leurs classements.

### Fonctionnalités clés

Le coeur de l'application consiste à retrouver les AMs qui s'appliquent à une installation. Puis à afficher une version "personnalisée" de l'AM - basée sur les spécificités de l'installation - en retirant les prescriptions innaplicables ou modifiées.

Pour que cela fonctionne, les AMs sont au préalable structurés et encodés au format .json. Des critères d'applicabilités y sont ajoutés si cela est pertinent (ex: un paragraphe ne s'applique si la date de mise en service est ultérieur au 1er septembre 2010). Toutes ces opérations de préparation des AM se font manuellement par un agent au niveau du [Back-office](https://envinorma-back-office.herokuapp.com/).

> Pour en savoir +, (QUEL LIEN ?)

#### Récupérer la liste des AMs applicables

C'est le module `FilterAMs` qui se charge de récupérer les AM en fonction du classement de l'installation. Il se base uniquement sur le couple rubrique-régime pour récupérer les AMs.
Puis il va ajouter des informations d'applicabilité en fonction des alinéas, des dates ou du volume. Le but étant de récupérer potentiellement des AM non applicables mais correspondant au couple rubrique-régime, afin que l'utilisateur les voit - afin de le rassurer - ou qu'il puisse les utiliser s'ils sont mal renseignés.

#### Transformer les AMs en fonction des valeurs des classements

C'est le module `Parametrization` qui s'occupe de cette partie. Il comprend 3 modules différents :

- `conditions` qui permet d'évaluer si une condition est satisfaite
- `parameters` qui permet d'ajouter ou de supprimer des informations des AMs en vue de leur affichage
- `warnings` qui permet de construire les messages d'alerte

