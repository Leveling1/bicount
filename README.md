# Bicount

Bicount est une application mobile Flutter de gestion d’argent personnel et partagé.

Elle permet de suivre les entrées et sorties d’argent, gérer des abonnements, ajouter des fonds, partager des transactions avec des amis, et visualiser rapidement ses chiffres clés.

## Sens pratique

### À quoi sert l’application

- suivre ses transactions
- enregistrer des abonnements
- ajouter des fonds ponctuels
- gérer des revenus récurrents comme un salaire
- consulter une timeline unique qui rassemble transactions et fonds ajoutés
- suivre ses statistiques dans `Home` et `Analyses`
- partager son profil avec des amis via lien ou QR code
- recevoir des rappels locaux pour les abonnements

### Parcours utilisateur

- l’utilisateur entre via une page d’authentification unique
- il peut continuer avec Google, Apple ou email + code
- une fois connecté, il accède aux 4 surfaces visibles de la V1 :
  - `Home`
  - `Analyses`
  - `Transaction`
  - `Profile`

### Ce qu’on voit dans la V1

- `Home` : vue synthétique et activité récente
- `Analyses` : revenus, dépenses, abonnements et tendances
- `Transaction` : timeline et création de mouvements d’argent
- `Profile` : identité, partage social et accès aux réglages

## Description détaillée de l’application

Cette application sert à suivre la vie de son argent au quotidien, seul ou avec d’autres personnes, dans un cadre simple à comprendre. Elle a été pensée pour quelqu’un qui veut savoir ce qui entre, ce qui sort, ce qui revient chaque mois, ce qu’un proche lui doit, ce qu’il doit lui-même, et comment tout cela évolue dans le temps, sans avoir à tout recalculer à la main.

### Les détails de confort du quotidien

L’application essaie d’abord de rendre le suivi de l’argent plus naturel et moins fatigant.

- elle garde une présentation claire avec quatre zones principales seulement pour ne pas perdre l’utilisateur
- elle ouvre directement la bonne partie quand on touche une notification, un lien d’invitation ou certains raccourcis
- elle peut afficher des rappels utiles pour éviter les oublis
- elle aide à retrouver rapidement une information importante au bon endroit au bon moment
- elle s’adapte à la langue de l’utilisateur et peut aussi être réglée manuellement
- elle permet de changer l’apparence générale selon la préférence de la personne
- elle propose un profil personnalisable avec nom visible, image et identité partagée
- elle prévoit un accès simple aux réglages importants comme la déconnexion ou la demande de suppression du compte
- elle peut aussi proposer une demande d’évolution vers une version plus avancée de l’expérience

### Une application pensée pour la vraie vie

L’objectif n’est pas seulement d’enregistrer des chiffres. L’application raconte l’histoire concrète de l’argent d’une personne.

- elle montre l’argent que l’on reçoit
- elle montre l’argent que l’on dépense
- elle aide à distinguer ce qui est personnel de ce qui est partagé avec un ami ou un proche
- elle permet de voir ce qui s’est passé aujourd’hui, cette semaine, ce mois-ci ou sur une période plus longue
- elle conserve le contexte de chaque mouvement d’argent pour qu’il reste compréhensible plus tard
- elle évite que l’utilisateur se retrouve avec une suite de lignes sans sens ni lien entre elles

### L’entrée dans l’application

Quand une personne arrive dans l’application, elle n’a pas besoin de passer par un parcours compliqué. L’entrée a été simplifiée pour aller vite à l’essentiel.

- l’utilisateur commence sur une seule porte d’entrée claire
- il peut continuer avec son adresse email, avec Google ou avec Apple selon son appareil
- s’il choisit l’email, il valide simplement avec un code reçu
- s’il ouvre l’application à partir d’un lien d’invitation, le contexte est gardé pour qu’il reprenne au bon endroit après sa connexion
- une fois connecté, il arrive sur l’expérience principale sans détour inutile

### Les quatre grandes zones visibles

La version actuelle visible repose sur quatre espaces principaux, chacun avec un rôle précis.

#### `Home`

`Home` est la vue d’ensemble. C’est l’endroit où l’on comprend rapidement sa situation sans devoir ouvrir dix écrans.

- on y retrouve un résumé global de la situation financière du moment
- on y voit ce qui bouge le plus récemment
- on peut y repérer rapidement ce qui mérite une attention particulière
- on y suit l’équilibre général entre ce qui entre et ce qui sort
- on y retrouve des éléments utiles liés aux revenus récurrents ou aux dépenses récurrentes quand une action est attendue
- c’est aussi un point de départ rapide vers des actions fréquentes

#### `Analyses`

`Analyses` sert à prendre du recul. Là où `Home` donne une photo rapide, `Analyses` donne une lecture plus approfondie.

- l’utilisateur peut voir combien il a reçu sur une période
- il peut voir combien il a dépensé sur la même période
- il peut voir la différence entre les deux
- il peut suivre l’évolution de ses flux d’argent dans le temps
- il peut repérer les catégories qui pèsent le plus dans ses dépenses
- il peut comprendre la place des dépenses régulières et des revenus réguliers dans son quotidien
- il peut voir séparément les montants qu’il doit récupérer et ceux qu’il doit rembourser quand cela existe
- quand il change la période d’observation, l’application garde la page stable pour qu’il ne perde pas ses repères

#### `Transaction`

`Transaction` est l’espace d’action. C’est là que l’utilisateur ajoute ses mouvements d’argent et relit son historique.

- il peut enregistrer une dépense
- il peut enregistrer un revenu
- il peut retrouver l’historique dans une seule timeline claire
- il peut ouvrir le détail d’un mouvement pour mieux comprendre ce qui a été enregistré
- il peut modifier un mouvement simple si une information doit être corrigée
- il peut suivre des opérations personnelles ou partagées
- l’expérience a été pensée pour rester compréhensible même quand plusieurs personnes sont concernées par le même paiement

#### `Profile`

`Profile` rassemble l’identité visible de l’utilisateur et sa dimension sociale.

- on y retrouve les informations du profil
- on peut y voir les contacts liés à la vie partagée de l’application
- on peut accéder aux réglages depuis cet espace
- on peut partager son identité plus facilement avec d’autres personnes
- on peut garder une vue d’ensemble plus personnelle sur sa présence dans l’application

### Enregistrer ce qui entre et ce qui sort

Le cœur de l’application, c’est la saisie simple des mouvements d’argent.

- une dépense peut être ajoutée pour représenter de l’argent qui quitte la personne
- un revenu peut être ajouté pour représenter de l’argent reçu
- la date choisie par l’utilisateur est respectée
- la devise choisie est aussi respectée
- l’application garde le montant d’origine pour rester fidèle à la réalité du moment où l’action a eu lieu
- elle sait aussi remettre les montants dans une base commune pour permettre des résumés cohérents
- cela évite les approximations quand plusieurs devises sont utilisées

### Gérer l’argent partagé avec des proches

L’application n’est pas limitée à une gestion solo. Elle sert aussi à organiser l’argent partagé avec des amis, des proches ou d’autres contacts.

- un mouvement peut être associé à une autre personne
- on peut indiquer qui paie et qui reçoit
- on peut enregistrer une dépense faite pour plusieurs personnes à la fois
- on peut répartir un même montant de façon égale
- on peut aussi répartir selon des pourcentages
- il est également possible d’indiquer des montants différents pour chaque personne
- cela permet de gérer plus proprement les sorties de groupe, les achats communs ou les avances faites pour d’autres

### Suivre les dettes sans les mélanger avec le reste

L’application sait faire la différence entre une simple dépense et une somme qui devra être remboursée plus tard.

- une dette peut naître à partir d’une dépense ou d’un revenu selon la situation
- le mouvement d’argent principal reste visible comme un vrai mouvement
- le suivi de remboursement est gardé à part pour éviter les confusions
- les remboursements se gèrent dans un espace dédié
- l’utilisateur peut voir ce qu’il doit récupérer
- il peut aussi voir ce qu’il lui reste à rembourser
- les analyses mettent en avant ces montants quand ils existent
- cela aide à ne pas oublier qu’un paiement n’était pas simplement une perte définitive ou un gain définitif

### Gérer les revenus et dépenses qui reviennent

L’application ne sert pas seulement à saisir le présent. Elle aide aussi à suivre ce qui revient régulièrement.

- une personne peut suivre des charges récurrentes
- elle peut aussi suivre des revenus réguliers, comme un salaire ou d’autres rentrées prévues
- l’application distingue ce qui est seulement prévu de ce qui a réellement été reçu ou payé
- cela évite de gonfler artificiellement les chiffres avant qu’un mouvement soit vraiment confirmé
- certains revenus réguliers peuvent demander une confirmation manuelle quand l’utilisateur veut garder la main
- d’autres peuvent être pensés comme plus automatiques selon l’organisation choisie
- l’application peut rappeler qu’une échéance approche ou qu’une confirmation est attendue
- l’utilisateur garde ainsi une vision plus réaliste de sa situation, sans confondre promesse et argent réellement disponible

### Comprendre ses chiffres au lieu de juste les stocker

L’application ne se contente pas de conserver des lignes. Elle cherche à donner du sens.

- elle met en avant la balance globale de l’utilisateur
- elle montre les entrées et les sorties du mois
- elle aide à repérer les habitudes financières qui se répètent
- elle révèle si certains postes prennent trop de place
- elle permet de comparer plusieurs périodes
- elle aide à voir si la situation s’améliore, stagne ou se dégrade
- elle garde une lecture séparée pour certaines réalités importantes comme les dettes et les remboursements

### Partager son profil et inviter d’autres personnes

La dimension relationnelle fait partie de l’expérience.

- l’utilisateur peut partager son profil
- il peut créer un lien à envoyer
- il peut aussi utiliser un code visuel à montrer ou à scanner
- l’autre personne peut ouvrir une page d’invitation claire avant d’accepter
- l’application peut suivre les invitations envoyées et reçues
- elle permet d’accepter ou de refuser une invitation
- cela facilite la création de liens entre personnes qui vont ensuite partager certaines opérations d’argent

### Des rappels utiles plutôt que du bruit

Les notifications ont été pensées pour servir l’utilisateur, pas pour le déranger inutilement.

- elles peuvent rappeler une charge régulière ou un revenu attendu
- elles peuvent prévenir qu’une action mérite une confirmation
- elles peuvent ouvrir directement l’écran concerné pour éviter à l’utilisateur de chercher
- si l’application est déjà ouverte, l’information importante peut quand même être présentée proprement
- l’idée est d’aider à agir au bon moment, pas simplement d’envoyer des messages

### Une application qui reste utile même dans des conditions imparfaites

L’application a été pensée pour rester praticable dans la vraie vie, même quand tout n’est pas parfait.

- elle cherche à garder les informations disponibles de manière fiable
- elle reste centrée sur l’usage quotidien plutôt que sur une dépendance totale à une connexion parfaite
- elle essaie d’éviter les pertes d’information quand l’utilisateur change d’appareil ou revient plus tard
- elle conserve une continuité dans l’expérience pour que les chiffres restent compréhensibles et cohérents

### Ce que l’utilisateur peut régler lui-même

Au-delà du suivi d’argent, l’utilisateur garde la main sur plusieurs aspects personnels.

- changer la langue affichée
- changer le style visuel
- modifier son identité visible
- gérer sa déconnexion
- demander la suppression de son compte avec confirmation
- envoyer une demande liée à une version plus avancée du service

### Ce qui est visible aujourd’hui et ce qui reste en arrière-plan

La version actuelle met volontairement l’accent sur les besoins les plus concrets du quotidien.

- suivre ses entrées d’argent
- suivre ses sorties d’argent
- partager certains mouvements avec des proches
- comprendre ses tendances
- recevoir des rappels utiles
- gérer son profil et ses réglages

Certaines parties plus larges existent déjà en arrière-plan mais ne sont pas exposées dans l’expérience visible actuelle. Le choix a été fait de garder la version publique concentrée sur l’essentiel pour que l’application reste claire et solide.

### En résumé, pour qui est faite Bicount

Bicount s’adresse à une personne qui veut reprendre le contrôle de son argent sans utiliser un outil compliqué. Elle convient à quelqu’un qui veut voir ce qu’il gagne, ce qu’il dépense, ce qu’il partage avec d’autres, ce qu’il doit encore régler, ce qu’il doit récupérer, ce qui revient chaque mois, et la direction générale que prend sa situation. Elle ne sert pas seulement à noter des montants. Elle aide à comprendre, anticiper, partager, confirmer, comparer, et décider plus sereinement.

## Sens technique

### Stack principale

- Flutter
- `flutter_bloc`
- `go_router`
- Supabase
- Brick Offline First with Supabase
- Firebase Messaging
- `flutter_local_notifications`

### Principes d’architecture

- architecture par feature
- séparation `data / domain / presentation`
- fonctionnement `offline-first`
- temps réel ajouté au-dessus du local

### Organisation principale

- `lib/core`
- `lib/brick`
- `lib/features/authentification`
- `lib/features/main`
- `lib/features/home`
- `lib/features/analysis`
- `lib/features/transaction`
- `lib/features/subscription`
- `lib/features/add_fund`
- `lib/features/profile`
- `lib/features/friend`
- `lib/features/notification`

### Données et synchronisation

L’application utilise SQLite via Brick pour le stockage local puis synchronise avec Supabase.

Points importants :

- les écrans visibles lisent surtout une agrégation `MainBloc`
- les suppressions distantes sont réconciliées localement
- la récupération sur un nouvel appareil passe désormais par une hydratation distante initiale avant les streams temps réel
- les états métier persistés sont numériques et centralisés dans
  [state_app.dart](C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/lib/core/constants/state_app.dart)

### Multi-devises

Chaque entrée financière peut conserver :

- son montant d’origine
- sa devise d’origine
- la devise de référence au moment de création
- le montant converti
- le montant pivot en `CDF`
- la date et l’identifiant du snapshot FX

### Documentation backend utile

- [backend_followup_actions.md](C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/docs/backend_followup_actions.md)
- [currency_fx_backend_actions.md](C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/docs/currency_fx_backend_actions.md)
- [auth_backend_actions.md](C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/docs/auth_backend_actions.md)

## Développement

```bash
flutter pub get --offline
flutter gen-l10n
flutter analyze lib
flutter test
cd android && gradlew.bat :app:assembleDebug
```

## Note produit

Les domaines `company`, `group` et `project` existent encore dans le code mais restent masqués de la V1 visible. Ils ne doivent pas être supprimés sans demande explicite.
