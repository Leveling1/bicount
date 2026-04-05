// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Bicount';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSectionTitle => 'Langue';

  @override
  String get languageSectionDescription =>
      'Choisissez comment Bicount s\'affiche. Par défaut, l\'application suit la langue de votre appareil.';

  @override
  String get languageSheetTitle => 'Choisir une langue';

  @override
  String get languageFollowSystem => 'Suivre la langue du système';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonTitle => 'Titre';

  @override
  String get commonSource => 'Source';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonAccept => 'Accepter';

  @override
  String get commonReject => 'Refuser';

  @override
  String get commonPreview => 'Aperçu';

  @override
  String get commonAmount => 'Montant';

  @override
  String get commonNote => 'Note';

  @override
  String get commonWhen => 'Quand';

  @override
  String get commonFrequency => 'Fréquence';

  @override
  String get commonSender => 'Expéditeur';

  @override
  String get commonBeneficiary => 'Bénéficiaire';

  @override
  String get commonDate => 'Date';

  @override
  String get commonTime => 'Heure';

  @override
  String get commonCreatedAt => 'Créé le';

  @override
  String get commonDateHint => 'JJ/MM/AAAA';

  @override
  String get commonPlaceholderNote => '...';

  @override
  String get commonMe => 'Moi';

  @override
  String get commonOpenLink => 'Ouvrir le lien';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonOr => 'ou';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonItems => 'éléments';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get commonError => 'Erreur';

  @override
  String get authBrandSubtitle => 'Argent perso et partagé, en toute clarté.';

  @override
  String get authLogIn => 'Se connecter';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get authDontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get authAlreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get authLoginWelcome =>
      'Retrouvez votre espace pour gérer argent personnel et partagé.';

  @override
  String get authSignupLead =>
      'Créez votre compte et démarrez avec une vision claire de vos finances.';

  @override
  String get authSignupDescription =>
      'Créez votre compte Bicount pour continuer.';

  @override
  String get authEmailAddress => 'Adresse e-mail';

  @override
  String get authYourEmailAddress => 'Votre adresse e-mail';

  @override
  String get authYourUserName => 'Votre nom d\'utilisateur';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authMinCharactersHint => '8 caractères min.';

  @override
  String get authAgreeTerms => 'J\'accepte les conditions d\'utilisation';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authCreateGoogleAccount => 'Créer un compte Google';

  @override
  String get authGenericSignInError =>
      'Impossible de vous connecter pour le moment. Réessayez.';

  @override
  String get authGenericSignUpError =>
      'Impossible de créer votre compte pour le moment. Réessayez.';

  @override
  String get authGenericSignOutError =>
      'Impossible de vous déconnecter pour le moment.';

  @override
  String get authGoogleCancelled => 'La connexion avec Google a été annulée.';

  @override
  String get authGoogleMissingEmail =>
      'Google n\'a pas renvoyé les informations nécessaires pour créer votre compte.';

  @override
  String get authGoogleTimeout =>
      'La connexion a pris trop de temps. Réessayez.';

  @override
  String get authNetworkError =>
      'Problème de réseau. Vérifiez votre connexion Internet.';

  @override
  String get authGoogleFailed =>
      'La connexion avec Google a échoué. Réessayez.';

  @override
  String get authUnifiedTitle => 'Gérez votre argent avec Bicount';

  @override
  String get authUnifiedSubtitle =>
      'Un seul accès simple et sécurisé pour votre argent perso et partagé.';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get authContinueWithEmail => 'Continuer avec l\'e-mail';

  @override
  String get authEmailPlaceholder => 'E-mail personnel ou professionnel';

  @override
  String get authOr => 'OU';

  @override
  String get authCheckYourEmailTitle =>
      'Vérifiez votre e-mail pour terminer la connexion';

  @override
  String authCheckYourEmailDescription(Object email) {
    return 'Nous avons envoyé votre code à $email';
  }

  @override
  String get authCodeFieldHint => 'Code';

  @override
  String get authCodeHelper => 'Entrez le code reçu par e-mail pour continuer.';

  @override
  String get authChangeEmailAddress => 'Changer l\'adresse e-mail';

  @override
  String get authVerifyCode => 'Vérifier le code';

  @override
  String get authLegalByContinuing => 'En continuant, vous acceptez les';

  @override
  String get authLegalAnd => 'et la';

  @override
  String get authLegalAcknowledge => 'et reconnaissez la';

  @override
  String get authConsumerTerms => 'Consumer Terms';

  @override
  String get authUsagePolicy => 'Usage Policy';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get validationEmailRequired => 'E-mail requis';

  @override
  String get validationInvalidEmail => 'E-mail invalide';

  @override
  String get validationPasswordRequired => 'Mot de passe requis';

  @override
  String get validationAtLeastEightCharacters => 'Au moins 8 caractères';

  @override
  String get validationFieldRequired => 'Ce champ est obligatoire';

  @override
  String get validationTooShort => 'Trop court';

  @override
  String get validationAmountGreaterThanZero =>
      'Saisissez un montant supérieur à zéro.';

  @override
  String get runtimeUnexpectedError =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get runtimeFriendSaveFailed =>
      'Impossible d\'enregistrer cet ami pour le moment.';

  @override
  String get runtimeFriendUpdateFailed =>
      'Impossible de mettre a jour cet ami pour le moment.';

  @override
  String get runtimeTransactionSaveFailed =>
      'La transaction n\'a pas pu être enregistrée.';

  @override
  String get runtimeTransactionDeleteFailed =>
      'Impossible de supprimer cette transaction pour le moment.';

  @override
  String get runtimeTransactionUpdateFailed =>
      'Impossible de mettre à jour cette transaction pour le moment.';

  @override
  String get runtimeSubscriptionDeleteFailed =>
      'Impossible de supprimer cet abonnement pour le moment.';

  @override
  String get runtimeSubscriptionSaveFailed =>
      'Impossible d\'enregistrer cet abonnement pour le moment.';

  @override
  String get runtimeSubscriptionUnsubscribeFailed =>
      'Impossible de mettre à jour cet abonnement pour le moment.';

  @override
  String get runtimeAccountFundingDeleteFailed =>
      'Impossible de supprimer cette alimentation de compte pour le moment.';

  @override
  String get runtimeAccountFundingSaveFailed =>
      'Impossible d\'enregistrer cette alimentation de compte pour le moment.';

  @override
  String get runtimeAccountFundingUpdateFailed =>
      'Impossible de mettre à jour cette alimentation de compte pour le moment.';

  @override
  String get runtimeProfileSaveFailed =>
      'Impossible d\'enregistrer votre profil pour le moment.';

  @override
  String get runtimeCurrencyRateLoadFailed =>
      'Impossible de charger les derniers taux de change pour le moment.';

  @override
  String get runtimeCurrencyOnlineSelectionRequired =>
      'Reconnectez-vous avant de changer votre devise de référence.';

  @override
  String get runtimeProRequestFailed =>
      'Impossible d\'envoyer votre demande Bicount Pro pour le moment.';

  @override
  String get runtimeDeleteAccountFailed =>
      'Impossible de supprimer votre compte pour le moment.';

  @override
  String get runtimeDataLoadFailed =>
      'Impossible de charger vos données pour le moment.';

  @override
  String get fieldEnterAmount => 'Saisir un montant';

  @override
  String get fieldSelectCurrency => 'Choisir une devise';

  @override
  String get onboardingSharedMoneyBadge => 'Argent partagé';

  @override
  String get onboardingSharedMoneyTitle =>
      'Suivez facilement chaque paiement partagé';

  @override
  String get onboardingSharedMoneyDescription =>
      'Suivez ce que vous donnez, ce que les autres reçoivent et ce qui demande encore votre attention, sans notes confuses ni messages sans fin.';

  @override
  String get onboardingDailyOverviewBadge => 'Vue quotidienne';

  @override
  String get onboardingDailyOverviewTitle =>
      'Voyez votre argent dans une vue claire et utile';

  @override
  String get onboardingDailyOverviewDescription =>
      'Suivez votre solde, vos abonnements et vos habitudes avec des visuels qui vous aident à décider plus vite.';

  @override
  String get onboardingProBadge => 'Bicount Pro';

  @override
  String get onboardingProTitle =>
      'Évoluez plus tard vers la finance d\'équipe et d\'activité';

  @override
  String get onboardingProDescription =>
      'Bicount Pro sera notre espace dédié aux équipes et aux activités professionnelles. Il n\'est pas encore actif, mais fait déjà partie de la vision Bicount.';

  @override
  String get onboardingProHighlight => 'Bientôt disponible';

  @override
  String get onboardingFooterPrimary =>
      'Bicount vous aide à gérer votre argent personnel et partagé avec clarté dès le premier jour.';

  @override
  String get onboardingFooterOverview =>
      'Une vue claire de votre solde, de vos habitudes et de vos abonnements vous aide à avancer plus vite sans effort inutile.';

  @override
  String get onboardingFooterPro =>
      'Bicount Pro sera la prochaine étape pour les équipes et la finance d\'activité, mais vous pouvez déjà commencer avec votre flux personnel.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navGraphs => 'Graphiques';

  @override
  String get navTransaction => 'Transactions';

  @override
  String get navProfile => 'Profil';

  @override
  String get shellOfflineBadge => 'Hors ligne';

  @override
  String get shellAddFunds => 'Ajouter des fonds';

  @override
  String get networkOfflineMessage =>
      'Connexion Internet perdue : vous êtes en mode hors ligne';

  @override
  String get networkUnstableMessage => 'Connexion Internet instable';

  @override
  String get homeBalance => 'Votre solde';

  @override
  String get homeAccounts => 'Comptes';

  @override
  String get homeTransactions => 'Transactions';

  @override
  String get homeShowMore => 'Voir plus';

  @override
  String get profileIncome => 'Revenus';

  @override
  String get profileExpense => 'Dépenses';

  @override
  String get profilePersonal => 'Personnel';

  @override
  String get profileRecurring => 'Récurrent';

  @override
  String get profileFriends => 'Amis';

  @override
  String get profileSeeAll => 'Tout voir';

  @override
  String get profileFirstFriendHint =>
      'Créez une transaction avec quelqu\'un pour ajouter votre premier ami. Son profil pourra être lié plus tard lorsqu\'il rejoindra Bicount.';

  @override
  String get profileLanguageTitle => 'Langue de l\'application';

  @override
  String get profileLanguageDescription =>
      'Changez de langue à tout moment. Si aucune langue n\'est choisie, Bicount suit votre appareil.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsHeaderSubtitle =>
      'Ajustez Bicount selon votre rythme, vos préférences et la sécurité de votre compte.';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsSectionSecurity => 'Sécurité';

  @override
  String get settingsEditProfileTitle => 'Modifier le profil';

  @override
  String get settingsEditProfileDescription =>
      'Mettez à jour votre nom visible et votre avatar.';

  @override
  String get settingsEditProfileCta => 'Mettre à jour le profil';

  @override
  String get settingsFriendsTitle => 'Amis et liaisons';

  @override
  String get settingsFriendsDescription =>
      'Consultez vos amis locaux et les profils déjà liés.';

  @override
  String get settingsThemeTitle => 'Thème';

  @override
  String get settingsThemeDescription =>
      'Choisissez l\'apparence de Bicount dans toute l\'application.';

  @override
  String get settingsThemeSheetTitle => 'Choisir un thème';

  @override
  String get settingsThemeSheetDescription =>
      'Continuez à suivre votre appareil ou choisissez une apparence fixe.';

  @override
  String get settingsThemeSystem => 'Suivre le système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageDescription =>
      'Changez la langue de l\'application à tout moment.';

  @override
  String get settingsLanguageSheetDescription =>
      'Si aucune langue n\'est choisie, Bicount suit votre appareil puis bascule en anglais si nécessaire.';

  @override
  String get settingsCurrencyTitle => 'Devise de référence';

  @override
  String get settingsCurrencyDescription =>
      'Choisissez la devise utilisée pour les soldes, les graphiques et les totaux.';

  @override
  String get settingsCurrencySheetTitle => 'Choisir une devise de référence';

  @override
  String get settingsCurrencySheetDescription =>
      'Cette devise est utilisée pour les totaux globaux et les analyses. Ce changement demande une synchronisation en ligne des taux.';

  @override
  String get settingsProTitle => 'Passer à Bicount Pro';

  @override
  String get settignsProMessage =>
      'Le compte pro arrive bientôt ! On finalise cette fonctionnalité pour vous. Merci d\'attendre un peu.';

  @override
  String get settingsProDescription =>
      'Expliquez-nous comment vous souhaitez utiliser Bicount Pro pour votre équipe ou votre activité.';

  @override
  String get settingsProSheetTitle => 'Demander Bicount Pro';

  @override
  String get settingsProSheetDescription =>
      'Partagez quelques détails pour que nous puissions vous recontacter quand l\'espace Pro sera prêt.';

  @override
  String get settingsProOrganizationLabel => 'Équipe ou entreprise';

  @override
  String get settingsProOrganizationHint =>
      'Le nom de votre équipe, studio, entreprise ou activité';

  @override
  String get settingsProUseCaseLabel => 'Que souhaitez-vous gérer ?';

  @override
  String get settingsProUseCaseHint =>
      'Décrivez votre fonctionnement, la taille de votre équipe ou vos besoins financiers';

  @override
  String get settingsProContactEmailLabel => 'E-mail de contact';

  @override
  String get settingsProSubmit => 'Envoyer la demande';

  @override
  String get settingsProfileSheetTitle => 'Modifier votre profil';

  @override
  String get settingsProfileSheetDescription =>
      'Choisissez l\'identité que les autres voient lorsqu\'ils font des transactions avec vous.';

  @override
  String get settingsProfileNameLabel => 'Nom affiché';

  @override
  String get settingsProfileNameHint => 'Saisissez votre nom affiché';

  @override
  String get settingsProfileAvatarLabel => 'Avatar';

  @override
  String get settingsMemojiConnectionTitle =>
      'Impossible de charger les avatars';

  @override
  String get settingsMemojiConnectionDescription =>
      'Vérifiez votre connexion Internet puis réessayez. Si certains avatars ont déjà été chargés, Bicount les garde disponibles en local.';

  @override
  String get settingsProfileSave => 'Enregistrer les changements';

  @override
  String get settingsDeleteTitle => 'Supprimer le compte';

  @override
  String get settingsDeleteDescription =>
      'Demandez la suppression du compte et dites-nous pourquoi vous partez.';

  @override
  String get settingsDeleteConfirmTitle => 'Supprimer ce compte ?';

  @override
  String get settingsDeleteConfirmDescription =>
      'Nous vous demanderons d\'abord une courte raison avant d\'envoyer la demande de suppression.';

  @override
  String get settingsDeleteConfirmCta => 'Continuer';

  @override
  String get settingsDeleteSheetTitle => 'Demande de suppression du compte';

  @override
  String get settingsDeleteSheetDescription =>
      'Aidez-nous à comprendre pourquoi vous souhaitez quitter Bicount.';

  @override
  String get settingsDeleteReasonLabel => 'Raison principale';

  @override
  String get settingsDeleteDetailsLabel => 'Détails supplémentaires';

  @override
  String get settingsDeleteDetailsHint =>
      'Ajoutez tout détail utile pour nous aider à améliorer le produit ou traiter votre demande';

  @override
  String get settingsDeleteReasonMissingFeatures =>
      'Fonctionnalités manquantes';

  @override
  String get settingsDeleteReasonTooExpensive => 'Trop cher';

  @override
  String get settingsDeleteReasonPrivacy =>
      'Préoccupations liées à la confidentialité';

  @override
  String get settingsDeleteReasonTooComplex => 'Trop complexe';

  @override
  String get settingsDeleteReasonNotUseful => 'Pas assez utile';

  @override
  String get settingsDeleteReasonOther => 'Autre';

  @override
  String get settingsDeleteSubmit => 'Envoyer la demande de suppression';

  @override
  String get settingsSignOutTitle => 'Se déconnecter';

  @override
  String get settingsSignOutDescription =>
      'Déconnectez cet appareil de votre compte Bicount.';

  @override
  String get settingsProfileUpdatedSuccess => 'Profil mis à jour avec succès.';

  @override
  String get settingsProRequestedSuccess =>
      'Votre demande Bicount Pro a bien été envoyée.';

  @override
  String get settingsSignedOutSuccess => 'Vous avez bien été déconnecté.';

  @override
  String get settingsDeleteRequestedSuccess =>
      'Votre demande de suppression de compte a bien été envoyée.';

  @override
  String get graphOverview => 'Vue d\'ensemble';

  @override
  String get graphOverviewDescription =>
      'Suivez vos flux, repérez vos dépenses récurrentes et gardez les signaux utiles à portée de vue.';

  @override
  String get graphUnableToLoad => 'Impossible de charger les analyses';

  @override
  String get graphCashflowTrend => 'Tendance des flux';

  @override
  String get graphIncomeMix => 'Sources d\'entree d\'argent';

  @override
  String get graphExpenseMix => 'Répartition des dépenses';

  @override
  String get graphSubscriptions => 'Abonnements';

  @override
  String get graphNetFlow => 'Flux net';

  @override
  String get graphIncome => 'Revenus';

  @override
  String get graphExpenses => 'Dépenses';

  @override
  String get graphActive => 'Actifs';

  @override
  String get graphMonthlyLoad => 'Charge mensuelle';

  @override
  String get graphNext7Days => '7 prochains jours';

  @override
  String get graphUpcomingCharges => 'Prélèvements à venir';

  @override
  String get graphNoActiveSubscriptions =>
      'Aucun abonnement actif planifié pour le moment.';

  @override
  String get graphPeriodAll => 'Tout';

  @override
  String get graphBreakdownAddFunds => 'Fonds ajoutes';

  @override
  String get graphBreakdownReceivedTransfers => 'Transferts recus';

  @override
  String get graphBreakdownExpenses => 'Dépenses';

  @override
  String get graphBreakdownSubscriptions => 'Abonnements';

  @override
  String get graphBreakdownOther => 'Autre';

  @override
  String get friendsTitle => 'Amis';

  @override
  String get friendDetailTitle => 'Détails de l\'ami';

  @override
  String get friendsDirectoryIntro =>
      'Touchez un ami pour consulter l\'historique des transactions en temps réel ou lier un profil local à un vrai compte.';

  @override
  String get friendsDirectoryEmpty =>
      'Créez une transaction avec quelqu\'un et il apparaîtra ici. Lorsqu\'il rejoindra Bicount, ouvrez sa fiche pour partager et lier le profil.';

  @override
  String get friendsTotal => 'Total';

  @override
  String get friendsLinked => 'Liés';

  @override
  String get friendsToLink => 'À lier';

  @override
  String get friendInviteLandingTitle => 'Invitation d\'ami';

  @override
  String get friendInvitationsTitle => 'Invitations d\'amis';

  @override
  String friendLinkTitle(Object name) {
    return 'Lier $name';
  }

  @override
  String get friendScreenIntro =>
      'Scannez une invitation, consultez les liaisons en attente et suivez les profils partagés en temps réel.';

  @override
  String get friendLinkIntro =>
      'Partagez ce profil d\'ami local quand la personne a créé un compte Bicount afin que le backend puisse relier les deux profils.';

  @override
  String friendShareProfileTitle(Object name) {
    return 'Partager le profil de $name';
  }

  @override
  String get friendShareProfileDescription =>
      'Générez un QR code ou un lien pour ce profil d\'ami précis.';

  @override
  String friendShareMessage(Object name, Object url) {
    return 'Rejoignez-moi sur Bicount et associez le profil de $name : $url';
  }

  @override
  String get friendMyProfile => 'mon profil Bicount';

  @override
  String get friendScanInvite => 'Scanner l\'invitation';

  @override
  String get friendScanQrTitle => 'Scanner le QR code d\'invitation';

  @override
  String get friendPendingRequests => 'Demandes en attente';

  @override
  String get friendIncomingEmpty => 'Aucune invitation reçue pour le moment.';

  @override
  String get friendSentInvitations => 'Invitations envoyées';

  @override
  String get friendSentEmpty =>
      'Vous n\'avez pas encore partagé de profil ami.';

  @override
  String get friendCurrentFriends => 'Amis actuels';

  @override
  String get friendCurrentEmpty =>
      'Vos contacts acceptés apparaîtront ici en temps réel.';

  @override
  String get friendInvitePreview => 'Aperçu de l\'invitation';

  @override
  String friendProfileToLink(Object name) {
    return 'Profil à lier : $name';
  }

  @override
  String friendInviteExpiresOn(Object date) {
    return 'Cette invitation expire le $date.';
  }

  @override
  String get friendShareGenerate => 'Générer l\'invitation';

  @override
  String get friendShareRefresh => 'Rafraîchir le lien';

  @override
  String get friendShareLink => 'Partager le lien';

  @override
  String get friendShareScanQr => 'Scanner le QR';

  @override
  String get friendInvitationLinkCopied => 'Lien d\'invitation copié.';

  @override
  String get friendInvitationReady => 'Invitation prête à être partagée.';

  @override
  String get friendInvitationNotFound => 'Cette invitation est introuvable.';

  @override
  String get friendInvitationAccepted => 'Invitation acceptée.';

  @override
  String get friendInvitationRejected => 'Invitation refusée.';

  @override
  String get friendInvitationPreviewOnlineRequired =>
      'Connectez-vous à Internet pour charger cette invitation.';

  @override
  String get friendInvitationAcceptOnlineRequired =>
      'Connectez-vous à Internet pour accepter cette invitation.';

  @override
  String get friendInvitationRejectOnlineRequired =>
      'Connectez-vous à Internet pour refuser cette invitation.';

  @override
  String get friendInvitationAcceptSignInRequired =>
      'Connectez-vous pour accepter cette invitation.';

  @override
  String get friendInvitationRejectSignInRequired =>
      'Connectez-vous pour refuser cette invitation.';

  @override
  String get friendInvitationLoadFailed =>
      'Impossible de charger cette invitation pour le moment.';

  @override
  String get friendInvitationAcceptFailed =>
      'Impossible d\'accepter cette invitation pour le moment.';

  @override
  String get friendInvitationRejectFailed =>
      'Impossible de refuser cette invitation pour le moment.';

  @override
  String friendProfileShared(Object name) {
    return 'Profil partagé : $name';
  }

  @override
  String friendSharedBy(Object status, Object sender) {
    return '$status · partagé par $sender';
  }

  @override
  String get friendLinkedAccount => 'Compte lié';

  @override
  String get friendLocalFriend => 'Ami local';

  @override
  String get friendLinkHint =>
      'Cet ami est encore local à votre compte. Utilisez le bouton de partage pour le lier lorsque la personne aura créé un profil Bicount.';

  @override
  String get friendGiven => 'Donné';

  @override
  String get friendReceived => 'Reçu';

  @override
  String get friendNet => 'Net';

  @override
  String get friendSharedTransactions => 'Transactions partagées';

  @override
  String get friendTransactionsEmpty =>
      'Les transactions avec cet ami apparaîtront ici en temps réel.';

  @override
  String get friendUnableToReadInvite => 'Impossible de lire cette invitation.';

  @override
  String get friendEditTitle => 'Modifier l\'ami';

  @override
  String get friendEditDescription =>
      'Mettez a jour le nom local et l\'avatar utilises pour cet ami.';

  @override
  String get friendProfileUpdated => 'Ami mis a jour.';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAccepted => 'Acceptée';

  @override
  String get statusRejected => 'Refusée';

  @override
  String get statusExpired => 'Expirée';

  @override
  String get statusPaused => 'En pause';

  @override
  String get statusUnsubscribed => 'Désabonné';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusInactive => 'Inactif';

  @override
  String get transactionNoTransactionsFound => 'Aucune transaction trouvée';

  @override
  String get transactionToday => 'Aujourd\'hui';

  @override
  String get transactionYesterday => 'Hier';

  @override
  String get transactionFilterAll => 'Tout';

  @override
  String get transactionFilterIncome => 'Revenus';

  @override
  String get transactionFilterExpense => 'Dépenses';

  @override
  String get transactionFilterSubscription => 'Abonnement';

  @override
  String get transactionFilterOther => 'Autre';

  @override
  String get transactionFilterPersonal => 'Personnel';

  @override
  String get transactionAddTitle => 'Ajouter une transaction';

  @override
  String get transactionEditTitle => 'Modifier la transaction';

  @override
  String get transactionNewSubscriptionTitle => 'Nouvel abonnement';

  @override
  String get transactionAddFundsTitle => 'Ajouter des fonds à votre compte';

  @override
  String get transactionSavedSuccess => 'Transaction enregistrée avec succès.';

  @override
  String get transactionDeletedSuccess => 'Transaction supprimée avec succès.';

  @override
  String get transactionUpdatedSuccess =>
      'Transaction mise à jour avec succès.';

  @override
  String get transactionDeleteConfirmTitle => 'Supprimer cette transaction ?';

  @override
  String get transactionDeleteConfirmDescription =>
      'Cette action retire la transaction de votre historique et synchronise la suppression dès que possible.';

  @override
  String get transactionDeleteConfirmCta => 'Supprimer la transaction';

  @override
  String get transactionDuplicateBeneficiary =>
      'Ce bénéficiaire est déjà dans la répartition.';

  @override
  String get transactionEditSingleBeneficiaryOnly =>
      'Modifiez cette transaction avec un seul bénéficiaire.';

  @override
  String get transactionAddAtLeastOneBeneficiary =>
      'Ajoutez au moins un bénéficiaire.';

  @override
  String get transactionEnterValidAmount => 'Saisissez un montant valide.';

  @override
  String get transactionPreviewEnterValidTotal =>
      'Saisissez un montant total valide pour prévisualiser la répartition.';

  @override
  String get transactionSplitMethod => 'Méthode de répartition';

  @override
  String get transactionSplitDetails => 'Détail de la répartition';

  @override
  String get transactionSplitEqually => 'Répartir également';

  @override
  String get transactionSplitModeEqual => 'Égal';

  @override
  String get transactionSplitModePercentage => 'Pourcentage';

  @override
  String get transactionSplitModeCustom => 'Personnalisé';

  @override
  String get transactionSplitHelperEqual =>
      'Bicount répartit le montant total de façon égale entre tous les bénéficiaires.';

  @override
  String get transactionSplitHelperPercentage =>
      'Définissez un pourcentage pour chaque bénéficiaire. Le total doit atteindre 100 %.';

  @override
  String get transactionSplitHelperCustom =>
      'Définissez le montant exact reçu par chaque bénéficiaire.';

  @override
  String get transactionSetPercentageReceived =>
      'Définissez le pourcentage reçu.';

  @override
  String get transactionSetExactAmountReceived =>
      'Définissez le montant exact reçu.';

  @override
  String get transferEnterTransactionName =>
      'Saisissez le nom de la transaction';

  @override
  String get transferPaidBy => 'Payé par';

  @override
  String get transferEnterSenderName => 'Saisissez le nom du payeur';

  @override
  String get transferItsMePayer => 'C\'est moi qui paie';

  @override
  String get transferBeneficiaries => 'Bénéficiaires';

  @override
  String get transferEnterBeneficiaryName => 'Saisissez le nom du bénéficiaire';

  @override
  String get transferBeneficiariesHint =>
      'Ajoutez autant de bénéficiaires que nécessaire. Utilisez Moi si vous recevez aussi une part.';

  @override
  String get subscriptionIntro =>
      'Enregistrez un paiement récurrent comme un service de streaming, Internet, une salle de sport, un logiciel ou toute dépense répétitive.';

  @override
  String get subscriptionName => 'Nom de l\'abonnement';

  @override
  String get subscriptionNameHint => 'ex. Netflix, Spotify...';

  @override
  String get subscriptionFrequencyHint => 'Choisissez la fréquence';

  @override
  String get subscriptionStartDate => 'Date de début';

  @override
  String get subscriptionNextPaymentDifferent =>
      'Le prochain paiement aura lieu à une autre date.';

  @override
  String get subscriptionNextBillingDate => 'Date du prochain paiement';

  @override
  String get subscriptionEditTitle => 'Modifier l\'abonnement';

  @override
  String get subscriptionSavedSuccess => 'Abonnement enregistré avec succès !';

  @override
  String get subscriptionUpdatedSuccess => 'Abonnement modifié avec succès.';

  @override
  String get subscriptionDeletedSuccess => 'Abonnement supprimé avec succès.';

  @override
  String get subscriptionSearchPrompt =>
      'Recherchez par nom d\'abonnement ou par note.';

  @override
  String get subscriptionSearchEmpty =>
      'Aucun abonnement ne correspond à votre recherche.';

  @override
  String get subscriptionNextBilling => 'Prochaine échéance';

  @override
  String get subscriptionBillingStop => 'Fin de facturation';

  @override
  String get subscriptionCumulativeExpenses => 'Dépenses cumulées';

  @override
  String get subscriptionSubscribedOn => 'Abonné depuis le';

  @override
  String get subscriptionUnsubscribe => 'Se désabonner';

  @override
  String get subscriptionUnsubscribeSuccess =>
      'Abonnement résilié avec succès.';

  @override
  String get subscriptionDeleteConfirmTitle => 'Supprimer cet abonnement ?';

  @override
  String get subscriptionDeleteConfirmDescription =>
      'Cette action retire l\'abonnement et ses entrées générées liées de votre historique.';

  @override
  String get subscriptionDeleteConfirmCta => 'Supprimer l\'abonnement';

  @override
  String get accountFundingIntro =>
      'Enregistrez un apport ponctuel ou un revenu récurrent comme un salaire pour garder votre solde à jour.';

  @override
  String get accountFundingEnterSource => 'Saisissez la source des fonds';

  @override
  String get accountFundingSavedSuccess =>
      'Opération d\'alimentation du compte ajoutée avec succès';

  @override
  String get accountFundingUpdatedSuccess =>
      'Alimentation du compte mise à jour avec succès';

  @override
  String get accountFundingDeletedSuccess =>
      'Alimentation du compte supprimée avec succès.';

  @override
  String get accountFundingRecurringSavedSuccess =>
      'Revenu récurrent enregistré avec succès';

  @override
  String get accountFundingDeleteConfirmTitle =>
      'Supprimer cet ajout de fonds ?';

  @override
  String get accountFundingDeleteConfirmDescription =>
      'Cette action retire l\'ajout de fonds de votre historique et met à jour vos projections.';

  @override
  String get accountFundingDeleteConfirmCta => 'Supprimer l\'ajout de fonds';

  @override
  String get accountFundingEditTitle => 'Modifier l\'ajout de fonds';

  @override
  String get accountFundingTypeTitle => 'Type de revenu';

  @override
  String get accountFundingTypeHint => 'Choisissez un type de revenu';

  @override
  String get accountFundingTypeSalary => 'Salaire';

  @override
  String get accountFundingTypeOther => 'Autre revenu';

  @override
  String get accountFundingRepeatLabel => 'Répéter ce revenu automatiquement';

  @override
  String get accountFundingFrequencyHint =>
      'Choisissez le rythme de répétition';

  @override
  String get accountFundingFirstCreditDate => 'Date du premier versement';

  @override
  String get salaryConfirmBeforeCountingTitle =>
      'Confirmer chaque salaire avant de le compter';

  @override
  String get salaryConfirmBeforeCountingHelper =>
      'Utilisez cette option si votre employeur peut payer en retard et que vous voulez seulement compter l\'argent réellement reçu.';

  @override
  String get salaryReminderToggleTitle => 'Me rappeler le jour de paie';

  @override
  String get salaryReminderToggleHelper =>
      'Bicount vous demandera si le salaire a bien été reçu à la date prévue.';

  @override
  String get salaryTrackingTitle => 'Fonds récurrents';

  @override
  String get salaryEmptyState =>
      'Créez un fond récurrent depuis Ajouter des fonds pour suivre les paiements attendus et les crédits confirmés.';

  @override
  String get salaryAttentionSectionTitle => 'À confirmer';

  @override
  String get salaryPlansTitle => 'Plans récurrents';

  @override
  String get salaryRecentPaymentsTitle => 'Paiements enregistrés récents';

  @override
  String get salaryOverdueTitle => 'Arriérés';

  @override
  String get salaryDueTodayTitle => 'Prévu aujourd\'hui';

  @override
  String get salaryNextPaydayTitle => 'Prochaine échéance';

  @override
  String get salaryModeConfirm => 'Confirmation';

  @override
  String get salaryModeAutomatic => 'Automatique';

  @override
  String get salaryStatusUpcoming => 'À venir';

  @override
  String get salaryStatusDueToday => 'Aujourd\'hui';

  @override
  String get salaryStatusOverdue => 'En retard';

  @override
  String get salaryStatusReceived => 'Reçu';

  @override
  String salaryExpectedOn(Object date) {
    return 'Prévu le $date';
  }

  @override
  String salaryReceivedOn(Object date) {
    return 'Reçu le $date';
  }

  @override
  String salaryNextPaydayValue(Object date) {
    return 'Prochaine échéance : $date';
  }

  @override
  String salaryReminderStatusValue(Object status) {
    return 'Rappels : $status';
  }

  @override
  String salaryArrearsValue(Object amount) {
    return 'En attente : $amount';
  }

  @override
  String get salaryConfirmPaymentCta => 'Confirmer la réception';

  @override
  String get salaryKeepAutomaticCta =>
      'Stopper les rappels et reprendre l\'automatique';

  @override
  String get salaryAutomaticModeHelper =>
      'Ce paiement sera compté maintenant et les prochains crédits récurrents dépendront du traitement automatique backend.';

  @override
  String get salaryReminderDisabledHelper =>
      'Les rappels sont déjà désactivés pour ce salaire.';

  @override
  String get salaryPaymentConfirmedSuccess =>
      'Paiement récurrent confirmé avec succès.';

  @override
  String get salaryAutomaticModeEnabledSuccess =>
      'Le suivi récurrent est repassé en mode automatique.';

  @override
  String get salaryHomeCardTitle => 'Suivi récurrent';

  @override
  String salaryHomeCardAttention(Object amount) {
    return 'Montant en attente : $amount';
  }

  @override
  String salaryHomeCardNext(Object date) {
    return 'Prochain fond récurrent prévu le $date';
  }

  @override
  String salaryHomeCardCount(Object count) {
    return '$count paiements demandent votre attention';
  }

  @override
  String salaryPlansCount(Object count) {
    return '$count plans récurrents actifs';
  }

  @override
  String get runtimeSalaryConfirmFailed =>
      'Impossible de confirmer ce paiement de salaire pour le moment.';

  @override
  String get runtimeSalaryTrackingSaveFailed =>
      'Impossible de mettre à jour ce suivi récurrent pour le moment.';

  @override
  String get transactionTypeTransfer => 'Transfert';

  @override
  String get transactionTypeSubscription => 'Abonnement';

  @override
  String get transactionTypeAddFund => 'Ajouter des fonds';

  @override
  String get transactionTypeIncome => 'Revenus';

  @override
  String get transactionTypeExpense => 'Dépenses';

  @override
  String get transactionTypeOther => 'Autre';

  @override
  String get frequencyWeekly => 'Hebdomadaire';

  @override
  String get frequencyMonthly => 'Mensuel';

  @override
  String get frequencyQuarterly => 'Trimestriel';

  @override
  String get frequencyYearly => 'Annuel';

  @override
  String get frequencyOneTime => 'Ponctuel';

  @override
  String get runtimeSplitPercentagePositive =>
      'Chaque bénéficiaire doit avoir un pourcentage supérieur à zéro.';

  @override
  String get runtimeSplitPercentagesTotal =>
      'Les pourcentages doivent totaliser 100 %.';

  @override
  String get runtimeSplitAmountPositive =>
      'Chaque bénéficiaire doit avoir un montant supérieur à zéro.';

  @override
  String get runtimeSplitMismatch =>
      'La répartition ne correspond pas au montant total. Vérifiez les montants individuels.';
}
