import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Bicount'**
  String get appName;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @languageSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how Bicount is displayed. By default, the app follows your device language.'**
  String get languageSectionDescription;

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get languageSheetTitle;

  /// No description provided for @languageFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system language'**
  String get languageFollowSystem;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get commonSource;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get commonReject;

  /// No description provided for @commonPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get commonPreview;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get commonNote;

  /// No description provided for @commonWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get commonWhen;

  /// No description provided for @commonFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get commonFrequency;

  /// No description provided for @commonSender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get commonSender;

  /// No description provided for @commonBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get commonBeneficiary;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get commonTime;

  /// No description provided for @commonCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get commonCreatedAt;

  /// No description provided for @commonDateHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get commonDateHint;

  /// No description provided for @commonPlaceholderNote.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get commonPlaceholderNote;

  /// No description provided for @commonMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get commonMe;

  /// No description provided for @commonOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get commonOpenLink;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @authBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal and shared money, made calm.'**
  String get authBrandSubtitle;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authDontHaveAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLoginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to your shared and personal money space.'**
  String get authLoginWelcome;

  /// No description provided for @authSignupLead.
  ///
  /// In en, this message translates to:
  /// **'Create your account and start with a clear money flow.'**
  String get authSignupLead;

  /// No description provided for @authSignupDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your Bicount account to continue.'**
  String get authSignupDescription;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailAddress;

  /// No description provided for @authYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get authYourEmailAddress;

  /// No description provided for @authYourUserName.
  ///
  /// In en, this message translates to:
  /// **'Your user name'**
  String get authYourUserName;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authMinCharactersHint.
  ///
  /// In en, this message translates to:
  /// **'min. 8 characters'**
  String get authMinCharactersHint;

  /// No description provided for @authAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms of use'**
  String get authAgreeTerms;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authCreateGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a Google account'**
  String get authCreateGoogleAccount;

  /// No description provided for @authGenericSignInError.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in right now. Please try again.'**
  String get authGenericSignInError;

  /// No description provided for @authGenericSignUpError.
  ///
  /// In en, this message translates to:
  /// **'Unable to create your account right now. Please try again.'**
  String get authGenericSignUpError;

  /// No description provided for @authGenericSignOutError.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign out right now.'**
  String get authGenericSignOutError;

  /// No description provided for @authGoogleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authGoogleCancelled;

  /// No description provided for @authGoogleMissingEmail.
  ///
  /// In en, this message translates to:
  /// **'Google did not return the information needed to create your account.'**
  String get authGoogleMissingEmail;

  /// No description provided for @authGoogleTimeout.
  ///
  /// In en, this message translates to:
  /// **'Sign-in took too long. Please try again.'**
  String get authGoogleTimeout;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network issue. Please check your internet connection.'**
  String get authNetworkError;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleFailed;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get validationEmailRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get validationPasswordRequired;

  /// No description provided for @validationAtLeastEightCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get validationAtLeastEightCharacters;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationFieldRequired;

  /// No description provided for @validationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get validationTooShort;

  /// No description provided for @validationAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get validationAmountGreaterThanZero;

  /// No description provided for @runtimeUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get runtimeUnexpectedError;

  /// No description provided for @runtimeFriendSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save this friend right now.'**
  String get runtimeFriendSaveFailed;

  /// No description provided for @runtimeTransactionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The transaction could not be saved.'**
  String get runtimeTransactionSaveFailed;

  /// No description provided for @runtimeSubscriptionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save this subscription right now.'**
  String get runtimeSubscriptionSaveFailed;

  /// No description provided for @runtimeSubscriptionUnsubscribeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update this subscription right now.'**
  String get runtimeSubscriptionUnsubscribeFailed;

  /// No description provided for @runtimeAccountFundingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save this account funding right now.'**
  String get runtimeAccountFundingSaveFailed;

  /// No description provided for @runtimeProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save your profile right now.'**
  String get runtimeProfileSaveFailed;

  /// No description provided for @runtimeProRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to request Bicount Pro right now.'**
  String get runtimeProRequestFailed;

  /// No description provided for @runtimeDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete your account right now.'**
  String get runtimeDeleteAccountFailed;

  /// No description provided for @runtimeDataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your data right now.'**
  String get runtimeDataLoadFailed;

  /// No description provided for @fieldEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get fieldEnterAmount;

  /// No description provided for @fieldSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get fieldSelectCurrency;

  /// No description provided for @onboardingSharedMoneyBadge.
  ///
  /// In en, this message translates to:
  /// **'Shared money'**
  String get onboardingSharedMoneyBadge;

  /// No description provided for @onboardingSharedMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep every shared payment easy to follow'**
  String get onboardingSharedMoneyTitle;

  /// No description provided for @onboardingSharedMoneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Track what you give, what others receive, and what still needs attention without messy notes or endless messages.'**
  String get onboardingSharedMoneyDescription;

  /// No description provided for @onboardingDailyOverviewBadge.
  ///
  /// In en, this message translates to:
  /// **'Daily overview'**
  String get onboardingDailyOverviewBadge;

  /// No description provided for @onboardingDailyOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'See your money in one calm, useful view'**
  String get onboardingDailyOverviewTitle;

  /// No description provided for @onboardingDailyOverviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow your balance, subscriptions, and everyday habits with visuals that help you decide faster.'**
  String get onboardingDailyOverviewDescription;

  /// No description provided for @onboardingProBadge.
  ///
  /// In en, this message translates to:
  /// **'Bicount Pro'**
  String get onboardingProBadge;

  /// No description provided for @onboardingProTitle.
  ///
  /// In en, this message translates to:
  /// **'Grow into team and business finance later'**
  String get onboardingProTitle;

  /// No description provided for @onboardingProDescription.
  ///
  /// In en, this message translates to:
  /// **'Bicount Pro is our upcoming space for teams and business activity. It is not active yet, but it is already part of the Bicount direction.'**
  String get onboardingProDescription;

  /// No description provided for @onboardingProHighlight.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get onboardingProHighlight;

  /// No description provided for @onboardingFooterPrimary.
  ///
  /// In en, this message translates to:
  /// **'Bicount helps you manage personal and shared money with clarity from day one.'**
  String get onboardingFooterPrimary;

  /// No description provided for @onboardingFooterOverview.
  ///
  /// In en, this message translates to:
  /// **'A clear picture of your balance, habits, and subscriptions helps you move faster without extra effort.'**
  String get onboardingFooterOverview;

  /// No description provided for @onboardingFooterPro.
  ///
  /// In en, this message translates to:
  /// **'Bicount Pro is the next step for teams and business finance, while today you can already start with your personal flow.'**
  String get onboardingFooterPro;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGraphs.
  ///
  /// In en, this message translates to:
  /// **'Graphs'**
  String get navGraphs;

  /// No description provided for @navTransaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get navTransaction;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @shellOfflineBadge.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get shellOfflineBadge;

  /// No description provided for @shellAddFunds.
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get shellAddFunds;

  /// No description provided for @networkOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Internet connection lost: you are in offline mode'**
  String get networkOfflineMessage;

  /// No description provided for @networkUnstableMessage.
  ///
  /// In en, this message translates to:
  /// **'Unstable internet connection'**
  String get networkUnstableMessage;

  /// No description provided for @homeBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get homeBalance;

  /// No description provided for @homeAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeAccounts;

  /// No description provided for @homeTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get homeTransactions;

  /// No description provided for @homeShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get homeShowMore;

  /// No description provided for @profileIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get profileIncome;

  /// No description provided for @profileExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get profileExpense;

  /// No description provided for @profilePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profilePersonal;

  /// No description provided for @profileRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get profileRecurring;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profileFriends;

  /// No description provided for @profileSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get profileSeeAll;

  /// No description provided for @profileFirstFriendHint.
  ///
  /// In en, this message translates to:
  /// **'Create a transaction with someone to add your first friend. Their profile can be linked later when they join Bicount.'**
  String get profileFirstFriendHint;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch language anytime. If no language is chosen, Bicount follows your device.'**
  String get profileLanguageDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune Bicount around your routine, your preferences, and your account safety.'**
  String get settingsHeaderSubtitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfileTitle;

  /// No description provided for @settingsEditProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your visible name and avatar.'**
  String get settingsEditProfileDescription;

  /// No description provided for @settingsEditProfileCta.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get settingsEditProfileCta;

  /// No description provided for @settingsFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends and links'**
  String get settingsFriendsTitle;

  /// No description provided for @settingsFriendsDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your local friends and linked profiles.'**
  String get settingsFriendsDescription;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how Bicount looks across the app.'**
  String get settingsThemeDescription;

  /// No description provided for @settingsThemeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme'**
  String get settingsThemeSheetTitle;

  /// No description provided for @settingsThemeSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep following your device or pick a fixed appearance.'**
  String get settingsThemeSheetDescription;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the app language at any time.'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsLanguageSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'If no language is selected, Bicount follows your device and falls back to English if needed.'**
  String get settingsLanguageSheetDescription;

  /// No description provided for @settingsProTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to Bicount Pro'**
  String get settingsProTitle;

  /// No description provided for @settingsProDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you want to use Bicount Pro for your team or activity.'**
  String get settingsProDescription;

  /// No description provided for @settingsProSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Bicount Pro'**
  String get settingsProSheetTitle;

  /// No description provided for @settingsProSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Share a few details so we can contact you when the Pro space is ready.'**
  String get settingsProSheetDescription;

  /// No description provided for @settingsProOrganizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Team or company'**
  String get settingsProOrganizationLabel;

  /// No description provided for @settingsProOrganizationHint.
  ///
  /// In en, this message translates to:
  /// **'Your team, studio, company, or activity name'**
  String get settingsProOrganizationHint;

  /// No description provided for @settingsProUseCaseLabel.
  ///
  /// In en, this message translates to:
  /// **'What would you like to manage?'**
  String get settingsProUseCaseLabel;

  /// No description provided for @settingsProUseCaseHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your workflow, team size, or finance needs'**
  String get settingsProUseCaseHint;

  /// No description provided for @settingsProContactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get settingsProContactEmailLabel;

  /// No description provided for @settingsProSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get settingsProSubmit;

  /// No description provided for @settingsProfileSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get settingsProfileSheetTitle;

  /// No description provided for @settingsProfileSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the identity other people see when they transact with you.'**
  String get settingsProfileSheetDescription;

  /// No description provided for @settingsProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get settingsProfileNameLabel;

  /// No description provided for @settingsProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get settingsProfileNameHint;

  /// No description provided for @settingsProfileAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get settingsProfileAvatarLabel;

  /// No description provided for @settingsMemojiConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load avatars'**
  String get settingsMemojiConnectionTitle;

  /// No description provided for @settingsMemojiConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again. If some avatars were already loaded, Bicount keeps them available locally.'**
  String get settingsMemojiConnectionDescription;

  /// No description provided for @settingsProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsProfileSave;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion and tell us why you are leaving.'**
  String get settingsDeleteDescription;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'We will ask for a short reason before sending the deletion request.'**
  String get settingsDeleteConfirmDescription;

  /// No description provided for @settingsDeleteConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get settingsDeleteConfirmCta;

  /// No description provided for @settingsDeleteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account request'**
  String get settingsDeleteSheetTitle;

  /// No description provided for @settingsDeleteSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us understand why you want to leave Bicount.'**
  String get settingsDeleteSheetDescription;

  /// No description provided for @settingsDeleteReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Main reason'**
  String get settingsDeleteReasonLabel;

  /// No description provided for @settingsDeleteDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra details'**
  String get settingsDeleteDetailsLabel;

  /// No description provided for @settingsDeleteDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add any detail that can help us improve or process your request'**
  String get settingsDeleteDetailsHint;

  /// No description provided for @settingsDeleteReasonMissingFeatures.
  ///
  /// In en, this message translates to:
  /// **'Missing features'**
  String get settingsDeleteReasonMissingFeatures;

  /// No description provided for @settingsDeleteReasonTooExpensive.
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get settingsDeleteReasonTooExpensive;

  /// No description provided for @settingsDeleteReasonPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy concerns'**
  String get settingsDeleteReasonPrivacy;

  /// No description provided for @settingsDeleteReasonTooComplex.
  ///
  /// In en, this message translates to:
  /// **'Too complex'**
  String get settingsDeleteReasonTooComplex;

  /// No description provided for @settingsDeleteReasonNotUseful.
  ///
  /// In en, this message translates to:
  /// **'Not useful enough'**
  String get settingsDeleteReasonNotUseful;

  /// No description provided for @settingsDeleteReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get settingsDeleteReasonOther;

  /// No description provided for @settingsDeleteSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send deletion request'**
  String get settingsDeleteSubmit;

  /// No description provided for @settingsSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOutTitle;

  /// No description provided for @settingsSignOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this device from your Bicount account.'**
  String get settingsSignOutDescription;

  /// No description provided for @settingsProfileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get settingsProfileUpdatedSuccess;

  /// No description provided for @settingsProRequestedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your Bicount Pro request has been sent.'**
  String get settingsProRequestedSuccess;

  /// No description provided for @settingsSignedOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have been signed out.'**
  String get settingsSignedOutSuccess;

  /// No description provided for @settingsDeleteRequestedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account deletion request has been submitted.'**
  String get settingsDeleteRequestedSuccess;

  /// No description provided for @graphOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get graphOverview;

  /// No description provided for @graphOverviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your flow, spot your recurring costs, and keep the useful signals close.'**
  String get graphOverviewDescription;

  /// No description provided for @graphUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load analytics'**
  String get graphUnableToLoad;

  /// No description provided for @graphCashflowTrend.
  ///
  /// In en, this message translates to:
  /// **'Cashflow trend'**
  String get graphCashflowTrend;

  /// No description provided for @graphExpenseMix.
  ///
  /// In en, this message translates to:
  /// **'Expense mix'**
  String get graphExpenseMix;

  /// No description provided for @graphSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get graphSubscriptions;

  /// No description provided for @graphNetFlow.
  ///
  /// In en, this message translates to:
  /// **'Net flow'**
  String get graphNetFlow;

  /// No description provided for @graphIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get graphIncome;

  /// No description provided for @graphExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get graphExpenses;

  /// No description provided for @graphActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get graphActive;

  /// No description provided for @graphMonthlyLoad.
  ///
  /// In en, this message translates to:
  /// **'Monthly load'**
  String get graphMonthlyLoad;

  /// No description provided for @graphNext7Days.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get graphNext7Days;

  /// No description provided for @graphUpcomingCharges.
  ///
  /// In en, this message translates to:
  /// **'Upcoming charges'**
  String get graphUpcomingCharges;

  /// No description provided for @graphNoActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions scheduled yet.'**
  String get graphNoActiveSubscriptions;

  /// No description provided for @graphPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get graphPeriodAll;

  /// No description provided for @graphBreakdownExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get graphBreakdownExpenses;

  /// No description provided for @graphBreakdownSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get graphBreakdownSubscriptions;

  /// No description provided for @graphBreakdownOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get graphBreakdownOther;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @friendsDirectoryIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap a friend to review the live transaction history or link a local profile to a real account.'**
  String get friendsDirectoryIntro;

  /// No description provided for @friendsDirectoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create a transaction with someone and they will appear here. When they join Bicount, open their detail screen to share and link the profile.'**
  String get friendsDirectoryEmpty;

  /// No description provided for @friendsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get friendsTotal;

  /// No description provided for @friendsLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get friendsLinked;

  /// No description provided for @friendsToLink.
  ///
  /// In en, this message translates to:
  /// **'To link'**
  String get friendsToLink;

  /// No description provided for @friendInviteLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend invite'**
  String get friendInviteLandingTitle;

  /// No description provided for @friendInvitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend invitations'**
  String get friendInvitationsTitle;

  /// No description provided for @friendLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Link {name}'**
  String friendLinkTitle(Object name);

  /// No description provided for @friendScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Scan an invite, review pending links, and track shared profiles in real time.'**
  String get friendScreenIntro;

  /// No description provided for @friendLinkIntro.
  ///
  /// In en, this message translates to:
  /// **'Share this local friend profile when the person has created a Bicount account so the backend can link both profiles together.'**
  String get friendLinkIntro;

  /// No description provided for @friendShareProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Share {name} profile'**
  String friendShareProfileTitle(Object name);

  /// No description provided for @friendShareProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a QR code or a link for this specific friend profile.'**
  String get friendShareProfileDescription;

  /// No description provided for @friendShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join me on Bicount and link the profile for {name}: {url}'**
  String friendShareMessage(Object name, Object url);

  /// No description provided for @friendMyProfile.
  ///
  /// In en, this message translates to:
  /// **'my Bicount profile'**
  String get friendMyProfile;

  /// No description provided for @friendScanInvite.
  ///
  /// In en, this message translates to:
  /// **'Scan invite'**
  String get friendScanInvite;

  /// No description provided for @friendScanQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan invitation QR code'**
  String get friendScanQrTitle;

  /// No description provided for @friendPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get friendPendingRequests;

  /// No description provided for @friendIncomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No incoming invitations for now.'**
  String get friendIncomingEmpty;

  /// No description provided for @friendSentInvitations.
  ///
  /// In en, this message translates to:
  /// **'Sent invitations'**
  String get friendSentInvitations;

  /// No description provided for @friendSentEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not shared a friend profile yet.'**
  String get friendSentEmpty;

  /// No description provided for @friendCurrentFriends.
  ///
  /// In en, this message translates to:
  /// **'Current friends'**
  String get friendCurrentFriends;

  /// No description provided for @friendCurrentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your accepted contacts will show up here in real time.'**
  String get friendCurrentEmpty;

  /// No description provided for @friendInvitePreview.
  ///
  /// In en, this message translates to:
  /// **'Invitation preview'**
  String get friendInvitePreview;

  /// No description provided for @friendProfileToLink.
  ///
  /// In en, this message translates to:
  /// **'Profile to link: {name}'**
  String friendProfileToLink(Object name);

  /// No description provided for @friendInviteExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'This invite expires on {date}.'**
  String friendInviteExpiresOn(Object date);

  /// No description provided for @friendShareGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate invite'**
  String get friendShareGenerate;

  /// No description provided for @friendShareRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh link'**
  String get friendShareRefresh;

  /// No description provided for @friendShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get friendShareLink;

  /// No description provided for @friendShareScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get friendShareScanQr;

  /// No description provided for @friendInvitationLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation link copied.'**
  String get friendInvitationLinkCopied;

  /// No description provided for @friendInvitationReady.
  ///
  /// In en, this message translates to:
  /// **'Invitation ready to share.'**
  String get friendInvitationReady;

  /// No description provided for @friendInvitationNotFound.
  ///
  /// In en, this message translates to:
  /// **'This invitation was not found.'**
  String get friendInvitationNotFound;

  /// No description provided for @friendInvitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted.'**
  String get friendInvitationAccepted;

  /// No description provided for @friendInvitationRejected.
  ///
  /// In en, this message translates to:
  /// **'Invitation rejected.'**
  String get friendInvitationRejected;

  /// No description provided for @friendProfileShared.
  ///
  /// In en, this message translates to:
  /// **'Profile shared: {name}'**
  String friendProfileShared(Object name);

  /// No description provided for @friendSharedBy.
  ///
  /// In en, this message translates to:
  /// **'{status} · shared by {sender}'**
  String friendSharedBy(Object status, Object sender);

  /// No description provided for @friendLinkedAccount.
  ///
  /// In en, this message translates to:
  /// **'Linked account'**
  String get friendLinkedAccount;

  /// No description provided for @friendLocalFriend.
  ///
  /// In en, this message translates to:
  /// **'Local friend'**
  String get friendLocalFriend;

  /// No description provided for @friendLinkHint.
  ///
  /// In en, this message translates to:
  /// **'This friend is still local to your account. Use the share button to link it when the person has created a Bicount profile.'**
  String get friendLinkHint;

  /// No description provided for @friendGiven.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get friendGiven;

  /// No description provided for @friendReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get friendReceived;

  /// No description provided for @friendNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get friendNet;

  /// No description provided for @friendSharedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Shared transactions'**
  String get friendSharedTransactions;

  /// No description provided for @friendTransactionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Transactions with this friend will appear here in real time.'**
  String get friendTransactionsEmpty;

  /// No description provided for @friendUnableToReadInvite.
  ///
  /// In en, this message translates to:
  /// **'Unable to read this invitation.'**
  String get friendUnableToReadInvite;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusUnsubscribed.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get statusUnsubscribed;

  /// No description provided for @transactionNoTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get transactionNoTransactionsFound;

  /// No description provided for @transactionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transactionToday;

  /// No description provided for @transactionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get transactionYesterday;

  /// No description provided for @transactionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get transactionFilterAll;

  /// No description provided for @transactionFilterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionFilterIncome;

  /// No description provided for @transactionFilterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionFilterExpense;

  /// No description provided for @transactionFilterSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get transactionFilterSubscription;

  /// No description provided for @transactionFilterOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get transactionFilterOther;

  /// No description provided for @transactionFilterPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get transactionFilterPersonal;

  /// No description provided for @transactionAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get transactionAddTitle;

  /// No description provided for @transactionNewSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'New subscription'**
  String get transactionNewSubscriptionTitle;

  /// No description provided for @transactionAddFundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add funds to your account'**
  String get transactionAddFundsTitle;

  /// No description provided for @transactionSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully.'**
  String get transactionSavedSuccess;

  /// No description provided for @transactionDuplicateBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'This beneficiary is already in the split.'**
  String get transactionDuplicateBeneficiary;

  /// No description provided for @transactionAddAtLeastOneBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Add at least one beneficiary.'**
  String get transactionAddAtLeastOneBeneficiary;

  /// No description provided for @transactionEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get transactionEnterValidAmount;

  /// No description provided for @transactionPreviewEnterValidTotal.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid total amount to preview the split.'**
  String get transactionPreviewEnterValidTotal;

  /// No description provided for @transactionSplitMethod.
  ///
  /// In en, this message translates to:
  /// **'Split method'**
  String get transactionSplitMethod;

  /// No description provided for @transactionSplitDetails.
  ///
  /// In en, this message translates to:
  /// **'Split details'**
  String get transactionSplitDetails;

  /// No description provided for @transactionSplitEqually.
  ///
  /// In en, this message translates to:
  /// **'Split equally'**
  String get transactionSplitEqually;

  /// No description provided for @transactionSplitModeEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get transactionSplitModeEqual;

  /// No description provided for @transactionSplitModePercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get transactionSplitModePercentage;

  /// No description provided for @transactionSplitModeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get transactionSplitModeCustom;

  /// No description provided for @transactionSplitHelperEqual.
  ///
  /// In en, this message translates to:
  /// **'Bicount splits the total amount equally for every beneficiary.'**
  String get transactionSplitHelperEqual;

  /// No description provided for @transactionSplitHelperPercentage.
  ///
  /// In en, this message translates to:
  /// **'Set a percentage for each beneficiary. The total must reach 100%.'**
  String get transactionSplitHelperPercentage;

  /// No description provided for @transactionSplitHelperCustom.
  ///
  /// In en, this message translates to:
  /// **'Set the exact amount received by each beneficiary.'**
  String get transactionSplitHelperCustom;

  /// No description provided for @transactionSetPercentageReceived.
  ///
  /// In en, this message translates to:
  /// **'Set the percentage received.'**
  String get transactionSetPercentageReceived;

  /// No description provided for @transactionSetExactAmountReceived.
  ///
  /// In en, this message translates to:
  /// **'Set the exact amount received.'**
  String get transactionSetExactAmountReceived;

  /// No description provided for @transferEnterTransactionName.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction name'**
  String get transferEnterTransactionName;

  /// No description provided for @transferPaidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get transferPaidBy;

  /// No description provided for @transferEnterSenderName.
  ///
  /// In en, this message translates to:
  /// **'Enter sender name'**
  String get transferEnterSenderName;

  /// No description provided for @transferItsMePayer.
  ///
  /// In en, this message translates to:
  /// **'It\'s me paying'**
  String get transferItsMePayer;

  /// No description provided for @transferBeneficiaries.
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get transferBeneficiaries;

  /// No description provided for @transferEnterBeneficiaryName.
  ///
  /// In en, this message translates to:
  /// **'Enter beneficiary name'**
  String get transferEnterBeneficiaryName;

  /// No description provided for @transferBeneficiariesHint.
  ///
  /// In en, this message translates to:
  /// **'Add as many receivers as you want. Use Me if you are also receiving a share.'**
  String get transferBeneficiariesHint;

  /// No description provided for @subscriptionIntro.
  ///
  /// In en, this message translates to:
  /// **'Register a recurring payment such as streaming services, internet, gym, software, or any repetitive expense.'**
  String get subscriptionIntro;

  /// No description provided for @subscriptionName.
  ///
  /// In en, this message translates to:
  /// **'Subscription name'**
  String get subscriptionName;

  /// No description provided for @subscriptionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix, Spotify...'**
  String get subscriptionNameHint;

  /// No description provided for @subscriptionFrequencyHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the frequency'**
  String get subscriptionFrequencyHint;

  /// No description provided for @subscriptionStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get subscriptionStartDate;

  /// No description provided for @subscriptionNextPaymentDifferent.
  ///
  /// In en, this message translates to:
  /// **'The next payment will be on a different date.'**
  String get subscriptionNextPaymentDifferent;

  /// No description provided for @subscriptionNextBillingDate.
  ///
  /// In en, this message translates to:
  /// **'Next billing date'**
  String get subscriptionNextBillingDate;

  /// No description provided for @subscriptionSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription saved successfully!'**
  String get subscriptionSavedSuccess;

  /// No description provided for @subscriptionNextBilling.
  ///
  /// In en, this message translates to:
  /// **'Next billing'**
  String get subscriptionNextBilling;

  /// No description provided for @subscriptionBillingStop.
  ///
  /// In en, this message translates to:
  /// **'Billing stop'**
  String get subscriptionBillingStop;

  /// No description provided for @subscriptionCumulativeExpenses.
  ///
  /// In en, this message translates to:
  /// **'Cumulative expenses'**
  String get subscriptionCumulativeExpenses;

  /// No description provided for @subscriptionSubscribedOn.
  ///
  /// In en, this message translates to:
  /// **'Subscribed on'**
  String get subscriptionSubscribedOn;

  /// No description provided for @subscriptionUnsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get subscriptionUnsubscribe;

  /// No description provided for @subscriptionUnsubscribeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled successfully.'**
  String get subscriptionUnsubscribeSuccess;

  /// No description provided for @accountFundingIntro.
  ///
  /// In en, this message translates to:
  /// **'Add money to your account securely by recording a new deposit or credit to increase your available balance.'**
  String get accountFundingIntro;

  /// No description provided for @accountFundingEnterSource.
  ///
  /// In en, this message translates to:
  /// **'Enter source of funds'**
  String get accountFundingEnterSource;

  /// No description provided for @accountFundingSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account funding transaction added successfully'**
  String get accountFundingSavedSuccess;

  /// No description provided for @transactionTypeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transactionTypeTransfer;

  /// No description provided for @transactionTypeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get transactionTypeSubscription;

  /// No description provided for @transactionTypeAddFund.
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get transactionTypeAddFund;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get transactionTypeOther;

  /// No description provided for @frequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @frequencyQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get frequencyQuarterly;

  /// No description provided for @frequencyYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get frequencyYearly;

  /// No description provided for @frequencyOneTime.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get frequencyOneTime;

  /// No description provided for @runtimeSplitPercentagePositive.
  ///
  /// In en, this message translates to:
  /// **'Every beneficiary needs a percentage greater than zero.'**
  String get runtimeSplitPercentagePositive;

  /// No description provided for @runtimeSplitPercentagesTotal.
  ///
  /// In en, this message translates to:
  /// **'Percentages must add up to 100%.'**
  String get runtimeSplitPercentagesTotal;

  /// No description provided for @runtimeSplitAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Every beneficiary needs an amount greater than zero.'**
  String get runtimeSplitAmountPositive;

  /// No description provided for @runtimeSplitMismatch.
  ///
  /// In en, this message translates to:
  /// **'The split does not match the total amount. Check the individual amounts.'**
  String get runtimeSplitMismatch;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
