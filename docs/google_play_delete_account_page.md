# Page publique Google Play - suppression du compte et des donnees Bicount

## But du document

Ce document donne au developpeur front tout ce qu'il lui faut pour implementer la page publique demandee par Google Play pour Bicount.

Cette page doit couvrir deux besoins Google Play :

- l'URL publique de suppression du compte
- l'URL publique expliquant comment supprimer une partie ou la totalite de certaines donnees sans supprimer le compte

L'objectif est d'eviter une page trop vague de type politique de confidentialite generale.
La page doit expliquer tres clairement :

- comment demander la suppression du compte dans l'application
- comment supprimer certaines donnees sans supprimer le compte
- ce qui se passe apres l'envoi de la demande
- quelles donnees peuvent etre conservees temporairement pour des raisons legales, de securite ou de traitement

## Recommandation de route

Utiliser une seule page publique et stable :

- URL canonique recommandee : `https://bicount.levelingcoder.com/delete-account`
- chemin recommande : `/delete-account`

Cette meme URL peut etre renseignee dans les deux champs Google Play :

- `URL de suppression de compte`
- `URL de suppression des donnees sans suppression du compte`

Optionnel :

- si le site veut aussi exposer `/delete-data`, faire une redirection vers `/delete-account`
- dans ce cas, garder `/delete-account` comme URL canonique

## Ce que le front doit faire

Le front doit creer une page publique qui :

- est accessible sans connexion
- fonctionne correctement sur mobile
- a un titre clair et immediatement comprensible
- contient une date de derniere mise a jour
- explique la suppression du compte et la suppression partielle de donnees sur la meme page
- ne demande pas d'authentification web pour lire les instructions
- ne promet pas une suppression instantanee si le flux reel est une demande de suppression

## Ce que le front ne doit pas faire

- ne pas reutiliser uniquement la page `privacy-policy` sans explication dediee
- ne pas afficher un simple texte legal generique sans etapes concretement actionnables
- ne pas dire que le compte est supprime instantanement si l'application envoie d'abord une demande
- ne pas creer un faux formulaire web de suppression si le produit n'a pas encore de flux web de suppression
- ne pas cacher les informations importantes derriere un accordion ferme par defaut

## Comportement produit a respecter

Le contenu de la page doit rester coherent avec le produit mobile actuel :

- la suppression du compte se fait depuis l'application Bicount
- l'utilisateur doit etre connecte dans l'application pour soumettre la demande
- dans l'application, la demande passe par une confirmation puis un formulaire de raison
- apres succes, l'utilisateur voit un message de confirmation et il est deconnecte
- certaines donnees peuvent etre supprimees directement dans l'application sans supprimer le compte

Important :

- la page publique est une page d'explication
- ce n'est pas, a ce stade, un back-office ni un formulaire web de suppression

## Structure de page recommandee

Le dev front peut reprendre cette structure quasiment telle quelle :

1. Hero / titre principal
2. Resume rapide en 3 points
3. Section `Comment supprimer votre compte`
4. Section `Que se passe-t-il apres votre demande ?`
5. Section `Supprimer certaines donnees sans supprimer le compte`
6. Section `Donnees pouvant etre conservees temporairement`
7. Section `Important a savoir`
8. Section `Besoin d'aide ?`
9. Footer simple avec liens legaux

## Elements d'interface recommandes

- un conteneur de lecture centre avec largeur confortable sur desktop
- une mise en page mobile-first
- des ancres ou un sommaire rapide en haut de page
- des blocs d'information ou cartes pour les points critiques
- un style visuel aligne avec Bicount
- un bouton ou lien vers la politique de confidentialite
- un lien vers la page d'accueil du site

## Meta recommandees

- `title` : `Suppression du compte Bicount et suppression des donnees`
- `meta description` : `Consultez la procedure officielle Bicount pour demander la suppression de votre compte ou supprimer certaines donnees sans fermer votre compte.`
- `canonical` : `https://bicount.levelingcoder.com/delete-account`

## Texte exact a publier sur la page

Le texte ci-dessous peut etre donne tel quel au dev front pour integration.

---

# Supprimer votre compte ou certaines de vos donnees Bicount

**Derniere mise a jour : [A RENSEIGNER AVANT MISE EN LIGNE]**

Chez Bicount, vous pouvez :

- demander la suppression de votre compte directement depuis l'application
- supprimer certaines donnees sans supprimer votre compte
- consulter publiquement la procedure officielle depuis cette page, sans connexion web

Cette page explique la marche a suivre, ce qui se passe apres votre demande et les cas dans lesquels certaines donnees peuvent etre conservees temporairement.

## En bref

- **Suppression du compte** : la demande se fait dans l'application Bicount, depuis les reglages.
- **Suppression partielle de donnees** : certaines donnees peuvent etre supprimees directement dans l'application sans fermer le compte.
- **Traitement de la demande** : selon la nature de la demande, certaines informations peuvent etre conservees temporairement lorsque la loi, la securite ou la prevention de la fraude l'exigent.

## Comment supprimer votre compte Bicount

Pour demander la suppression de votre compte Bicount, suivez ces etapes :

1. Ouvrez l'application Bicount sur votre appareil.
2. Connectez-vous au compte que vous souhaitez supprimer.
3. Accedez a l'espace **Profil**.
4. Ouvrez les **Reglages** depuis l'icone dediee en haut de l'ecran.
5. Dans la section **Securite**, appuyez sur **Supprimer le compte**.
6. Une fenetre de confirmation s'affiche. Appuyez sur **Continuer** pour poursuivre.
7. Un formulaire intitule **Demande de suppression du compte** s'ouvre.
8. Selectionnez la raison principale de votre demande.
9. Si vous le souhaitez, ajoutez des details complementaires.
10. Appuyez sur **Envoyer la demande de suppression**.
11. Si la demande est envoyee avec succes, Bicount affiche un message de confirmation puis vous deconnecte de l'application.

## Ce qu'il faut comprendre sur la suppression du compte

La suppression du compte Bicount correspond a une **demande de suppression de compte** envoyee depuis l'application.

Cela signifie que :

- la demande est transmise a l'infrastructure Bicount pour traitement
- le compte n'est pas presente sur cette page web comme etant supprime instantanement par simple clic sur le site
- certaines operations de suppression ou d'anonymisation peuvent necessiter un traitement interne supplementaire selon les obligations applicables

## Que se passe-t-il apres l'envoi de votre demande ?

Apres l'envoi de la demande :

1. Bicount enregistre votre demande de suppression.
2. Votre session mobile est fermee si la demande est soumise avec succes.
3. Les donnees liees au compte sont ensuite traitees conformement a la politique de suppression applicable.
4. Lorsque cela est necessaire, certaines donnees peuvent etre supprimees, anonymisees ou temporairement conservees afin de respecter des obligations legales, de securite, de prevention de fraude ou de resolution de litiges.

## Supprimer certaines donnees sans supprimer votre compte

Vous pouvez supprimer certaines donnees directement depuis l'application Bicount sans demander la suppression complete de votre compte.

Selon les fonctionnalites que vous utilisez, cela peut inclure par exemple :

- certaines **transactions**
- certaines **dettes**
- certains **plans recurrents**

La suppression partielle se fait depuis l'ecran de detail de l'element concerne, lorsque l'option de suppression est disponible.

### Exemple general pour une suppression partielle

1. Ouvrez l'application Bicount.
2. Connectez-vous a votre compte.
3. Ouvrez l'ecran qui contient la donnee que vous souhaitez supprimer.
4. Accedez au detail de l'element concerne.
5. Utilisez l'action **Supprimer** lorsqu'elle est disponible.
6. Confirmez votre choix.

La suppression partielle n'entraine pas la fermeture de votre compte Bicount.

## Donnees pouvant etre conservees temporairement

Dans certains cas, Bicount peut conserver temporairement certaines informations apres une demande de suppression, uniquement lorsque cela est necessaire pour :

- traiter et tracer la demande de suppression
- respecter une obligation legale ou reglementaire applicable
- assurer la securite du service
- prevenir la fraude ou les abus
- gerer un litige ou faire valoir un droit

Lorsque de telles informations doivent etre conservees, elles le sont uniquement pendant la duree strictement necessaire a cette finalite, puis elles sont supprimees ou anonymisees lorsque leur conservation n'est plus requise.

## Important a savoir

- **Se deconnecter** n'equivaut pas a **supprimer son compte**.
- **Supprimer certaines donnees** n'equivaut pas a **supprimer son compte**.
- Cette page explique la procedure officielle. La demande de suppression du compte doit etre effectuee depuis l'application Bicount.

## Besoin d'aide ?

Si vous avez besoin d'assistance supplementaire concernant la suppression de votre compte ou de vos donnees :

- consultez la politique de confidentialite Bicount
- utilisez le canal d'assistance officiel de Bicount s'il est mis a votre disposition

**Lien recommande a afficher sur la page :**

- `Politique de confidentialite`

**Optionnel si l'equipe fournit un contact officiel valide :**

- `Support : [A RENSEIGNER - EMAIL OU PAGE SUPPORT OFFICIELLE]`

---

## Instructions d'integration front

Le developpeur front peut suivre les etapes ci-dessous.

### Etape 1 - Creer la route publique

Creer la page publique sur :

- `/delete-account`

Optionnel :

- ajouter `/delete-data` en redirection vers `/delete-account`

### Etape 2 - Integrer le contenu tel quel

Le contenu fourni dans la section `Texte exact a publier sur la page` doit etre integre presque mot pour mot.

Les seules valeurs a remplacer avant publication sont :

- la date de derniere mise a jour
- le contact support si Bicount veut afficher un canal officiel

### Etape 3 - Ajouter les liens utiles

Ajouter au minimum :

- un lien vers `/privacy-policy`
- un lien vers la page d'accueil du site

### Etape 4 - Soigner la lisibilite mobile

Verifier que la page :

- se lit correctement sur smartphone
- n'a pas de blocs trop larges
- garde les etapes numerotees clairement visibles
- rend les titres et sous-titres faciles a scanner

### Etape 5 - Ajouter les meta SEO simples

Ajouter :

- un `title`
- une `meta description`
- une `canonical`

### Etape 6 - Ne pas devier du flux produit reel

Le dev front ne doit pas ajouter de promesses non couvertes par le produit actuel.

En particulier :

- ne pas afficher `Votre compte sera supprime instantanement`
- ne pas ajouter un formulaire web de suppression si rien ne le traite cote produit
- ne pas retirer la mention selon laquelle la procedure se fait dans l'application

## Texte court a reutiliser dans Google Play Console

Si un rappel est necessaire pour la console ou pour l'equipe publication :

- URL conseillee pour les deux champs : `https://bicount.levelingcoder.com/delete-account`
- cette page explique la suppression du compte dans l'application et la suppression partielle de donnees sans suppression du compte

## Checklist de validation avant mise en ligne

- la page est publique et accessible sans connexion
- l'URL finale est stable
- la page contient les etapes de suppression du compte
- la page contient la suppression partielle de donnees
- la page contient une section sur les donnees pouvant etre conservees temporairement
- la page contient une date de mise a jour
- la page contient au moins un lien vers la politique de confidentialite
- la page est lisible sur mobile
- la page n'affirme pas une suppression instantanee si ce n'est pas le flux reel

## Sources produit de reference

Ce document est coherent avec les references suivantes du projet :

- `docs/auth_web_legal_pages.md`
- `docs/settings_backend_actions.md`
- le flux de suppression de compte present dans la feature `settings`
