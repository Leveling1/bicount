# Journal de synchronisation V2 : déploiement compatible V1

## État

La migration `supabase/migrations/20261106125356_offline_sync_journal_compat.sql`
est préparée localement. Elle n'a pas été appliquée au projet Bicount de
production. Le schéma `public` a été exporté sans données et restauré dans une
instance Supabase locale isolée, puis la migration y a été appliquée. Des tests
SQL utilisent des comptes fictifs et sont annulés après exécution. Ils couvrent
les cinq tables, les comptes liés, la perte d'accès, les curseurs, la lecture
RLS et des écritures V1 sous le rôle `authenticated`, capture désactivée puis
activée pour un pilote. La branche Supabase demandée a été refusée : le projet
n'est pas sur un forfait Pro.

L'environnement local est dans `supabase/.temp/preprod` (exclu de Git).
Studio et l'API sont accessibles sur `http://127.0.0.1:54323` et
`http://127.0.0.1:54321`. Avec l'accord de l'utilisateur, Docker Desktop a été
configuré sur `Localhost by default`, puis les ports ouverts ont été vérifiés
sur le poste. Cette option est globale : les autres conteneurs recréés sans
adresse explicite peuvent eux aussi devenir accessibles uniquement localement.
Les valeurs de référence non personnelles sont chargées
depuis `supabase/tests/preprod_reference_seed.sql`. Aucun utilisateur ni aucune
transaction de production n'a été copié. Le déclencheur local
`notifications.push_notifications` est désactivé afin d'empêcher les envois
externes. Les Edge Functions, objets Storage, tâches cron, données FX et
configuration Auth de production ne sont pas reproduits. Vector et Logflare
sont exclus du démarrage local ; leur collecte de logs n'est pas disponible.
Pour les essais de change, `supabase/tests/preprod_fx_seed.sql` ajoute quatre
taux fictifs et non officiels exclusivement à la base locale ; ces valeurs ne
doivent jamais être utilisées en production ni pour des calculs réels.
Les cinq tables suivies, `currencies` et `friend_invites` ont été ajoutées à la
publication Realtime locale. Le
test `python supabase/tests/preprod_api_smoke.py` crée un compte fictif local,
teste Auth, RLS, Realtime, le journal sur deux comptes liés, les suppressions
et la pagination, puis nettoie ces comptes. Le déclencheur `auth.users` de
création du profil a également été reproduit localement après contrôle de sa
définition en production.
Il nécessite le module Python `websockets` et un SDK Flutter installé.
Après un redémarrage de Docker, un essai a expiré en attendant un événement
Realtime d'insertion malgré l'abonnement ; quatre essais suivants ont réussi.
La cause n'est pas encore établie. La reprise par journal reste nécessaire et
ce délai intermittent doit être investigué avant la validation finale.

Le code Flutter permet maintenant de sélectionner le serveur local avec
`BICOUNT_LOCAL_PREPROD=true` et une clé locale fournie à la compilation. Cette
sélection refuse un build release et n'autorise que `127.0.0.1:54321` pour
Supabase. Un mode Android distinct est préparé avec l'identifiant
`com.youngsolver.bicount.preprod`, des liens propres, une configuration Firebase
fictive et sans synchronisation de jeton. Un contrôle au démarrage interdit de
mélanger l'identifiant d'application et la configuration de préproduction.
Le build local a été compilé et démarré sur l'émulateur Android du PC, avec
redirection ADB du port 54321 vers l'API locale. Son identité et ses liens ont
été vérifiés dans le manifeste ; son parcours complet reste à valider. La
résolution des conflits n'est pas prête et aucun APK V1 n'a encore été testé
contre cet environnement. Ne pas utiliser ce build avec des données réelles.

Pour consulter la base, utiliser `docker exec -it supabase_db_preprod psql -U
postgres`. Pour redémarrer les services, utiliser `supabase start --workdir
supabase/.temp/preprod --exclude vector,logflare` et vérifier les ports publiés
avec `netstat` après chaque démarrage.
Éviter `supabase db reset` et `supabase stop
--no-backup` : ces commandes supprimeraient la copie locale et ses données de
test. Ne jamais utiliser ce répertoire local pour un `db push` vers production.

## Ce que la migration ajoute

- Deux nouvelles tables publiques, `bicount_sync_clock` et
  `bicount_sync_events`, lisibles uniquement par l'utilisateur concerné.
- Un schéma privé `bicount_sync` pour la configuration et les fonctions.
- Cinq déclencheurs sur `users`, `friends`, `transactions`, `debts` et
  `recurring_transfert`. La capture reste **désactivée par défaut**.
- Les événements ne contiennent que la table, l'identifiant et l'opération.
  Les lignes complètes continuent à être lues par les politiques RLS existantes.

La migration ne modifie aucune colonne, aucune politique ni aucune ligne des
tables V1. Elle ne remplace aucun RPC ni aucun flux Realtime existant. Les
anciens clients gardent leurs appels et leurs droits actuels. Les déclencheurs
font toutefois une vérification de configuration après chaque écriture : cette
faible surcharge doit être mesurée avant la production.

Cela garantit seulement que ce changement n'enlève pas de contrat V1. Le
backend actuel a déjà supprimé `account_funding`, `subscriptions` et
`recurring_fundings`, tandis que les fonctions existantes
`charge_subscription` et `process_recurring_funding` les mentionnent encore.
Le journal ne répare pas ce problème antérieur de l'ancienne version.

## Contrat du curseur

Le curseur `sequence` est propre à chaque `user_uid`. L'incrément de la ligne
`bicount_sync_clock` verrouille ce curseur jusqu'au commit, ce qui sérialise
les écritures concurrentes pour cet utilisateur. Le client lit les événements
par pages avec `user_uid = auth.uid()` et `sequence > dernier_curseur`, dans
l'ordre des séquences. Il n'avance son curseur SQLite qu'après avoir appliqué
la page dans la même transaction locale.
`oldest_available_sequence` permet de détecter un curseur devenu trop ancien
après compactage ; la fonction de compactage n'est pas programmée.
Une génération change à chaque modification de la configuration de capture :
un client qui revient après une désactivation effectue un nouveau snapshot.

Lors de la première installation, le client lit le curseur courant **avant**
son snapshot initial, puis relit le journal depuis ce curseur. Les événements
rejoués sont idempotents. `upsert` signifie « relire la ligne normale sous
RLS » ; si elle n'est plus visible, le client la retire de son cache. `delete`
retire la ligne locale. `invalidate` demande un snapshot ciblé des transactions
ou des dettes après un changement de lien d'amitié.

Les déclencheurs protègent les écritures V1 : une erreur du journal émet un
avertissement serveur et laisse l'écriture originale aboutir. En conséquence,
le client V2 conserve une comparaison complète toutes les heures comme filet
de sécurité. Une fonction privée de compactage est préparée : elle efface
uniquement une suite continue d'événements vieille d'au moins 90 jours, met à
jour le seuil de reprise et oblige les appareils trop anciens à reprendre un
snapshot. Aucun effacement automatique n'est programmé à cette étape.

## Séquence de validation

1. Compléter et vérifier la configuration locale des services nécessaires.
2. Tester V1 avant/après la migration : connexion, profil, ami, transaction,
   dette, modèle récurrent, suppression autorisée et notification existante.
3. Activer la capture pour un compte pilote seulement, puis vérifier les
   créations, modifications, suppressions, changements d'accès et reconnexions.
4. Mesurer la latence des écritures et le volume du journal. Vérifier que
   chaque événement n'est lisible que par son destinataire.
5. Le lecteur Flutter est présent derrière `BICOUNT_SYNC_JOURNAL=true`, désactivé
   par défaut. Valider ses parcours sur appareil avant toute activation générale.

Les builds habituels utilisent encore des écritures inconditionnelles et ne
protègent pas les modifications concurrentes. Le protocole ci-dessous est
expérimental et limité à la préproduction locale.
La migration locale supplémentaire `20261107155506_offline_conflict_clock.sql`
prépare une horloge privée par ligne et conserve un marqueur après suppression.
Elle est installée uniquement en préproduction. Elle observe l'heure à laquelle
le serveur reçoit une écriture V1, pas nécessairement l'heure réelle de son
édition hors ligne ; elle ne suffit donc pas à déterminer le gagnant ni à
protéger une écriture concurrente. La capture est désactivée sans pilote, et
une défaillance du déclencheur laisse l'écriture V1 aboutir. Les versions
enregistrées ne constituent donc pas une preuve suffisante à elles seules.
La migration locale `20261107160407_offline_conditional_mutation.sql` ajoute une
primitive expérimentale : pour une modification ou suppression d'une ligne
existante, elle verrouille la ligne puis compare son contenu complet à la
version attendue, sous les droits RLS de l'appelant. Une différence renvoie un
conflit sans modifier la ligne. Une modification déjà présente à l'identique
est reconnue lors d'un nouvel essai. Les créations, la sélection automatique
selon la date et la confirmation d'une suppression après une réponse réseau
perdue ne sont pas couvertes. Une modification distante suivie d'un retour à
l'ancien contenu ne peut pas être détectée par cette seule comparaison ; une
version serveur fiable est encore nécessaire pour ce cas. La migration locale
`20261110221847_offline_conditional_journal_guard.sql` ajoute une garde
expérimentale fondée sur la séquence et la génération du journal : elle détecte
ce retour à l'ancien contenu lorsque les événements sont complets et refuse les
curseurs expirés ou les générations différentes. Une défaillance silencieuse
du déclencheur V1 peut néanmoins manquer un événement : cette garde ne donne
donc pas encore une garantie absolue.
La référence locale reçoit sa séquence uniquement pour une ligne effectivement
lue par un snapshot commencé après cette séquence, ou appliquée depuis une page
du journal. Une opération en attente garde son ancienne référence. Une écriture
conditionnelle V2 est annulée si son propre événement n'est pas enregistré.
La boucle Flutter peut l'utiliser uniquement avec le paramètre de compilation
expérimental `BICOUNT_EXPERIMENTAL_CONDITIONAL=true`, désactivé par défaut.
Le démarrage refuse ce paramètre sans le mode de préproduction locale.
Dans ce mode, les opérations sans référence distante et les conflits restent
en attente, sans repli vers une écriture inconditionnelle. Une création dont
la provenance est connue peut être envoyée si le journal est actif ; la
tentative exacte et le repère du journal sont conservés avant l'envoi. Le
client expérimental utilise la fonction de reçu préparée pour rejouer la même
création sans doublon. Sans reçu, ou si la ligne n'est plus lisible ou ne
correspond pas au contenu initial, la modification reste en attente.
Le marqueur de référence précède l'insertion, ce qui peut conduire à un
conflit conservateur sur une modification effectuée pendant l'envoi. Ce n'est pas une solution de
conflit complète ni une protection active dans les builds habituels. Les tests
API locaux vérifient notamment que deux écritures concurrentes sur la même
base ne peuvent pas toutes les deux être appliquées. Les conflits conservent
localement l'opération, la référence et la ligne distante quand elle est visible.
Une écriture confirmée met à jour la référence sans retirer une opération plus
récente créée pendant son envoi. La migration locale
`20261112190801_offline_conflict_event_time.sql` ajoute un temps et une
empreinte aux nouveaux événements du journal. Dans le mode expérimental, le
client calibre une horloge de session auprès du serveur, enregistre une plage
temporelle avec chaque opération, puis choisit la version la plus récente si les
plages ne se chevauchent pas. La version écartée est conservée localement et
une écriture distante utilise une vérification conditionnelle. Sans horloge
calibrée, événement exploitable ou ordre clair, l'opération reste en attente.
Les suppressions distantes et les anciennes opérations sans référence temporelle
restent également en attente si leur résultat est ambigu. Un client V1 qui
envoie tardivement une modification hors ligne n'indique pas au serveur son
heure réelle d'édition : son heure d'arrivée peut être prise pour celle-ci.
Les changements d'horloge non détectés, une panne silencieuse de capture et
l'inaccessibilité des archives locales empêchent toute garantie absolue.
Une suppression distante confirmée plus récente peut être appliquée en
conservant la modification locale dans l'archive. Si une modification locale
est postérieure à une suppression distante, elle reste en attente : la
recréation conditionnelle de la ligne n'est pas encore implémentée.

Pour les essais Android locaux, choisir dans VS Code la configuration
`Bicount - Préproduction conflits expérimentale (Android)`. Le journal est
activé pour tous les comptes de la préproduction locale. Attendre la première
synchronisation en ligne avant de couper l'accès au conteneur
`supabase_kong_preprod`, afin d'établir les références et une mesure d'horloge.
Les opérations préexistantes sans référence temporelle fiable peuvent rester
en attente ; les archives sont locales et ne constituent pas une sauvegarde
serveur. Cette configuration ne doit pas être considérée comme prête pour une
diffusion en production.
La migration expérimentale `20261111100542_offline_creation_receipt.sql`
prépare un reçu enregistré avec l'insertion, dont l'accès est limité à son
auteur ; l'insertion métier reste soumise aux droits RLS de l'appelant. Testée
avec des comptes fictifs, elle est installée uniquement dans la préproduction
locale ; son client Flutter est raccordé uniquement au mode expérimental.
Des essais SQL et HTTP locaux couvrent une réponse perdue, des envois
concurrents, le rejet d'un contenu modifié, les droits RLS et l'absence de
recréation après suppression. La compatibilité complète reste à vérifier avant
toute utilisation.
Les trois nouvelles migrations expérimentales exigent le paramètre de session
`bicount.local_preprod = 'allow'` avant exécution ; sans lui, elles échouent
avant leurs modifications. Ce verrou réduit le risque d'application accidentelle
mais ne remplace pas une vérification de l'environnement ciblé.
Le reçu public ne renvoie pas la ligne initiale enregistrée en privé : il ne
doit pas contourner une éventuelle perte d'accès à la donnée métier. La reprise
d'une réponse perdue récupère et vérifie la ligne via RLS ; elle reste en
attente si elle ne correspond pas au contenu initial ou n'est plus accessible.
Les identifiants historiques non rapprochables et les opérations associées
restent également en attente, comme décrit dans `OFFLINE_FIRST_V2.md`.

Pour suspendre immédiatement la capture après déploiement, mettre
`enabled_for_all = false` et `pilot_user_uids = '{}'` dans la table privée
`bicount_sync.capture_config`. Cette opération ne supprime aucun événement ni
aucune donnée métier. Il ne faut pas supprimer les nouvelles tables pour
revenir à V1 : elles sont ignorées par cette version.
