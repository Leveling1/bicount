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
