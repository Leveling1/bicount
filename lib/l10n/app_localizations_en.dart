// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bicount';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSectionDescription => 'Choose how Bicount is displayed. By default, the app follows your device language.';

  @override
  String get languageSheetTitle => 'Choose a language';

  @override
  String get languageFollowSystem => 'Follow system language';

  @override
  String get commonSave => 'Save';

  @override
  String get commonTitle => 'Title';

  @override
  String get commonSource => 'Source';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonReject => 'Reject';

  @override
  String get commonPreview => 'Preview';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonNote => 'Note';

  @override
  String get commonWhen => 'When';

  @override
  String get commonFrequency => 'Frequency';

  @override
  String get commonSender => 'Sender';

  @override
  String get commonBeneficiary => 'Beneficiary';

  @override
  String get commonDate => 'Date';

  @override
  String get commonTime => 'Time';

  @override
  String get commonCreatedAt => 'Created at';

  @override
  String get commonDateHint => 'DD/MM/YYYY';

  @override
  String get commonPlaceholderNote => '...';

  @override
  String get commonMe => 'Me';

  @override
  String get commonOpenLink => 'Open link';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonOr => 'or';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonItems => 'items';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonError => 'Error';

  @override
  String get authBrandSubtitle => 'Personal and shared money, made calm.';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authDontHaveAccount => 'Don\'t have an account?';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authLoginWelcome => 'Welcome back to your shared and personal money space.';

  @override
  String get authSignupLead => 'Create your account and start with a clear money flow.';

  @override
  String get authSignupDescription => 'Create your Bicount account to continue.';

  @override
  String get authEmailAddress => 'Email address';

  @override
  String get authYourEmailAddress => 'Your email address';

  @override
  String get authYourUserName => 'Your user name';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authMinCharactersHint => 'min. 8 characters';

  @override
  String get authAgreeTerms => 'I agree to the terms of use';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authCreateGoogleAccount => 'Create a Google account';

  @override
  String get authGenericSignInError => 'Unable to sign in right now. Please try again.';

  @override
  String get authGenericSignUpError => 'Unable to create your account right now. Please try again.';

  @override
  String get authGenericSignOutError => 'Unable to sign out right now.';

  @override
  String get authGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authGoogleMissingEmail => 'Google did not return the information needed to create your account.';

  @override
  String get authGoogleTimeout => 'Sign-in took too long. Please try again.';

  @override
  String get authNetworkError => 'Network issue. Please check your internet connection.';

  @override
  String get authGoogleFailed => 'Google sign-in failed. Please try again.';

  @override
  String get authUnifiedTitle => 'Manage your money with Bicount';

  @override
  String get authUnifiedSubtitle => 'Start with one secure sign-in for personal and shared money.';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueWithEmail => 'Continue with email';

  @override
  String get authEmailPlaceholder => 'Personal or work email';

  @override
  String get authOr => 'OR';

  @override
  String get authCheckYourEmailTitle => 'Check your email to finish signing in';

  @override
  String authCheckYourEmailDescription(Object email) {
    return 'We sent your code to $email';
  }

  @override
  String get authCodeFieldHint => 'Code';

  @override
  String get authCodeHelper => 'Enter the code from your email to continue.';

  @override
  String get authChangeEmailAddress => 'Change email address';

  @override
  String get authVerifyCode => 'Verify code';

  @override
  String get authLegalByContinuing => 'By continuing, you agree to Bicount\'s';

  @override
  String get authLegalAnd => 'and';

  @override
  String get authLegalAcknowledge => 'and acknowledge the';

  @override
  String get authConsumerTerms => 'Consumer Terms';

  @override
  String get authUsagePolicy => 'Usage Policy';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get validationEmailRequired => 'Email required';

  @override
  String get validationInvalidEmail => 'Invalid email';

  @override
  String get validationPasswordRequired => 'Password required';

  @override
  String get validationAtLeastEightCharacters => 'At least 8 characters';

  @override
  String get validationFieldRequired => 'This field is required';

  @override
  String get validationTooShort => 'Too short';

  @override
  String get validationAmountGreaterThanZero => 'Enter an amount greater than zero.';

  @override
  String get runtimeUnexpectedError => 'Something went wrong. Please try again.';

  @override
  String get runtimeFriendSaveFailed => 'Unable to save this contact right now.';

  @override
  String get runtimeFriendUpdateFailed => 'Unable to update this contact right now.';

  @override
  String get runtimeTransactionSaveFailed => 'The transaction could not be saved.';

  @override
  String get runtimeTransactionDeleteFailed => 'Unable to delete this transaction right now.';

  @override
  String get runtimeTransactionUpdateFailed => 'Unable to update this transaction right now.';

  @override
  String get runtimeSubscriptionDeleteFailed => 'Unable to delete this subscription right now.';

  @override
  String get runtimeSubscriptionSaveFailed => 'Unable to save this subscription right now.';

  @override
  String get runtimeSubscriptionUnsubscribeFailed => 'Unable to update this subscription right now.';

  @override
  String get runtimeAccountFundingDeleteFailed => 'Unable to delete this account funding right now.';

  @override
  String get runtimeAccountFundingSaveFailed => 'Unable to save this account funding right now.';

  @override
  String get runtimeAccountFundingUpdateFailed => 'Unable to update this account funding right now.';

  @override
  String get runtimeProfileSaveFailed => 'Unable to save your profile right now.';

  @override
  String get runtimeCurrencyRateLoadFailed => 'Unable to load the latest exchange rates right now.';

  @override
  String get runtimeCurrencyOnlineSelectionRequired => 'Reconnect before changing your reference currency.';

  @override
  String get runtimeProRequestFailed => 'Unable to request Bicount Pro right now.';

  @override
  String get runtimeDeleteAccountFailed => 'Unable to delete your account right now.';

  @override
  String get runtimeDataLoadFailed => 'Unable to load your data right now.';

  @override
  String get fieldEnterAmount => 'Enter amount';

  @override
  String get fieldSelectCurrency => 'Select currency';

  @override
  String get onboardingSharedMoneyBadge => 'Shared money';

  @override
  String get onboardingSharedMoneyTitle => 'Keep every shared payment easy to follow';

  @override
  String get onboardingSharedMoneyDescription => 'Track what you give, what others receive, and what still needs attention without messy notes or endless messages.';

  @override
  String get onboardingDailyOverviewBadge => 'Daily overview';

  @override
  String get onboardingDailyOverviewTitle => 'See your money in one calm, useful view';

  @override
  String get onboardingDailyOverviewDescription => 'Follow your balance, subscriptions, and everyday habits with visuals that help you decide faster.';

  @override
  String get onboardingProBadge => 'Bicount Pro';

  @override
  String get onboardingProTitle => 'Grow into team and business finance later';

  @override
  String get onboardingProDescription => 'Bicount Pro is our upcoming space for teams and business activity. It is not active yet, but it is already part of the Bicount direction.';

  @override
  String get onboardingProHighlight => 'Coming soon';

  @override
  String get onboardingFooterPrimary => 'Bicount helps you manage personal and shared money with clarity from day one.';

  @override
  String get onboardingFooterOverview => 'A clear picture of your balance, habits, and subscriptions helps you move faster without extra effort.';

  @override
  String get onboardingFooterPro => 'Bicount Pro is the next step for teams and business finance, while today you can already start with your personal flow.';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalysis => 'Analysis';

  @override
  String get navTransaction => 'Transaction';

  @override
  String get navProfile => 'Profile';

  @override
  String get shellOfflineBadge => 'Offline';

  @override
  String get shellAddFunds => 'Add funds';

  @override
  String get networkOfflineMessage => 'Internet connection lost: you are in offline mode';

  @override
  String get networkUnstableMessage => 'Unstable internet connection';

  @override
  String get homeBalance => 'Your balance';

  @override
  String get homeWidgetAddTransactionCta => 'Add transaction';

  @override
  String get homeWidgetBalanceFallbackSubtitle => 'No recurring activity is due in the next 2 days.';

  @override
  String homeWidgetDueOn(Object date) {
    return 'Due on $date';
  }

  @override
  String get homeAccounts => 'Accounts';

  @override
  String get homeMonthlyInflow => 'Monthly inflow';

  @override
  String get homeMonthlyOutflow => 'Monthly outflow';

  @override
  String get homeTransactions => 'Transactions';

  @override
  String get homeShowMore => 'Show more';

  @override
  String get profileIncome => 'Income';

  @override
  String get profileExpense => 'Expense';

  @override
  String get profilePersonal => 'Personal';

  @override
  String get profileRecurring => 'Recurring plans';

  @override
  String get profileFriends => 'Contacts';

  @override
  String get profileSeeAll => 'See all';

  @override
  String get profileFirstFriendHint => 'Create a transaction with someone to add your first contact. Their profile can be linked later when they join Bicount.';

  @override
  String get profileLanguageTitle => 'App language';

  @override
  String get profileLanguageDescription => 'Switch language anytime. If no language is chosen, Bicount follows your device.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeaderSubtitle => 'Tune Bicount around your routine, your preferences, and your account safety.';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsEditProfileTitle => 'Edit profile';

  @override
  String get settingsEditProfileDescription => 'Update your visible name and avatar.';

  @override
  String get settingsEditProfileCta => 'Update profile';

  @override
  String get settingsFriendsTitle => 'Contacts and links';

  @override
  String get settingsFriendsDescription => 'Review your local contacts and linked profiles.';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeDescription => 'Choose how Bicount looks across the app.';

  @override
  String get settingsThemeSheetTitle => 'Choose a theme';

  @override
  String get settingsThemeSheetDescription => 'Keep following your device or pick a fixed appearance.';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDescription => 'Change the app language at any time.';

  @override
  String get settingsLanguageSheetDescription => 'If no language is selected, Bicount follows your device and falls back to English if needed.';

  @override
  String get settingsCurrencyTitle => 'Reference currency';

  @override
  String get settingsCurrencyDescription => 'Choose the currency used for balances, analysis views, and totals.';

  @override
  String get settingsCurrencySheetTitle => 'Choose a reference currency';

  @override
  String get settingsCurrencySheetDescription => 'This currency is used for global totals and analytics. Changing it requires a live exchange-rate sync.';

  @override
  String get settingsProTitle => 'Switch to Bicount Pro';

  @override
  String get settignsProMessage => 'Pro account coming soon! We\'re finalizing this feature for you. Thanks for waiting a bit.';

  @override
  String get settingsProDescription => 'Tell us how you want to use Bicount Pro for your team or activity.';

  @override
  String get settingsProSheetTitle => 'Request Bicount Pro';

  @override
  String get settingsProSheetDescription => 'Share a few details so we can contact you when the Pro space is ready.';

  @override
  String get settingsProOrganizationLabel => 'Team or company';

  @override
  String get settingsProOrganizationHint => 'Your team, studio, company, or activity name';

  @override
  String get settingsProUseCaseLabel => 'What would you like to manage?';

  @override
  String get settingsProUseCaseHint => 'Tell us about your workflow, team size, or finance needs';

  @override
  String get settingsProContactEmailLabel => 'Contact email';

  @override
  String get settingsProSubmit => 'Send request';

  @override
  String get settingsProfileSheetTitle => 'Edit your profile';

  @override
  String get settingsProfileSheetDescription => 'Choose the identity other people see when they transact with you.';

  @override
  String get settingsProfileNameLabel => 'Display name';

  @override
  String get settingsProfileNameHint => 'Enter your display name';

  @override
  String get settingsProfileAvatarLabel => 'Avatar';

  @override
  String get settingsMemojiConnectionTitle => 'Unable to load avatars';

  @override
  String get settingsMemojiConnectionDescription => 'Check your internet connection and try again. If some avatars were already loaded, Bicount keeps them available locally.';

  @override
  String get settingsProfileSave => 'Save changes';

  @override
  String get settingsDeleteTitle => 'Delete account';

  @override
  String get settingsDeleteDescription => 'Request account deletion and tell us why you are leaving.';

  @override
  String get settingsDeleteConfirmTitle => 'Delete this account?';

  @override
  String get settingsDeleteConfirmDescription => 'We will ask for a short reason before sending the deletion request.';

  @override
  String get settingsDeleteConfirmCta => 'Continue';

  @override
  String get settingsDeleteSheetTitle => 'Delete account request';

  @override
  String get settingsDeleteSheetDescription => 'Help us understand why you want to leave Bicount.';

  @override
  String get settingsDeleteReasonLabel => 'Main reason';

  @override
  String get settingsDeleteDetailsLabel => 'Extra details';

  @override
  String get settingsDeleteDetailsHint => 'Add any detail that can help us improve or process your request';

  @override
  String get settingsDeleteReasonMissingFeatures => 'Missing features';

  @override
  String get settingsDeleteReasonTooExpensive => 'Too expensive';

  @override
  String get settingsDeleteReasonPrivacy => 'Privacy concerns';

  @override
  String get settingsDeleteReasonTooComplex => 'Too complex';

  @override
  String get settingsDeleteReasonNotUseful => 'Not useful enough';

  @override
  String get settingsDeleteReasonOther => 'Other';

  @override
  String get settingsDeleteSubmit => 'Send deletion request';

  @override
  String get settingsSignOutTitle => 'Sign out';

  @override
  String get settingsSignOutDescription => 'Disconnect this device from your Bicount account.';

  @override
  String get settingsProfileUpdatedSuccess => 'Profile updated successfully.';

  @override
  String get settingsProRequestedSuccess => 'Your Bicount Pro request has been sent.';

  @override
  String get settingsSignedOutSuccess => 'You have been signed out.';

  @override
  String get settingsDeleteRequestedSuccess => 'Your account deletion request has been submitted.';

  @override
  String get analysisOverview => 'Overview';

  @override
  String get analysisOverviewDescription => 'Track your flow, spot your recurring costs, and keep the useful signals close.';

  @override
  String get analysisUnableToLoad => 'Unable to load analysis';

  @override
  String get analysisCashflowTrend => 'Cashflow trend';

  @override
  String get analysisIncomeMix => 'Income sources';

  @override
  String get analysisExpenseMix => 'Expense mix';

  @override
  String get analysisSubscriptions => 'Subscriptions';

  @override
  String get analysisNetFlow => 'Net flow';

  @override
  String get analysisIncome => 'Income';

  @override
  String get analysisExpenses => 'Expenses';

  @override
  String get analysisActive => 'Active';

  @override
  String get analysisMonthlyLoad => 'Monthly load';

  @override
  String get analysisNext7Days => 'Next 7 days';

  @override
  String get analysisUpcomingCharges => 'Upcoming charges';

  @override
  String get analysisRecurringChargesTitle => 'Recurring charges';

  @override
  String get analysisRecurringChargesDescription => 'Review the plans that keep leaving your balance and manage them before they drift.';

  @override
  String get analysisRecurringIncomesTitle => 'Recurring incomes';

  @override
  String get analysisRecurringIncomesDescription => 'Track your repeating income sources and open the full follow-up when one needs attention.';

  @override
  String get analysisRecurringIncomesUpcoming => 'Upcoming incomes';

  @override
  String get analysisNoActiveSubscriptions => 'No active subscriptions scheduled yet.';

  @override
  String get analysisPeriodAll => 'All';

  @override
  String get analysisBreakdownAddFunds => 'Add funds';

  @override
  String get analysisBreakdownReceivedTransfers => 'Inbound transfers';

  @override
  String get analysisBreakdownExpenses => 'Expenses';

  @override
  String get analysisBreakdownSubscriptions => 'Subscriptions';

  @override
  String get analysisBreakdownOther => 'Other';

  @override
  String get friendsTitle => 'Contacts';

  @override
  String get friendDetailTitle => 'Contact details';

  @override
  String get friendsDirectoryIntro => 'Tap a contact to review the live transaction history or link a local profile to a real account.';

  @override
  String get friendsDirectoryEmpty => 'Create a transaction with someone and they will appear here. When they join Bicount, open their detail screen to share and link the profile.';

  @override
  String get friendsSearchHint => 'Search a contact…';

  @override
  String get friendsSearchEmpty => 'No contact matches your search.';

  @override
  String get friendsTotal => 'Total';

  @override
  String get friendsLinked => 'Linked';

  @override
  String get friendsToLink => 'To link';

  @override
  String get friendInviteLandingTitle => 'Contact invite';

  @override
  String get friendInvitationsTitle => 'Contact invitations';

  @override
  String friendLinkTitle(Object name) {
    return 'Link $name';
  }

  @override
  String get friendScreenIntro => 'Scan an invite, review pending links, and track shared profiles in real time.';

  @override
  String get friendLinkIntro => 'Share this local contact profile when the person has created a Bicount account so the backend can link both profiles together.';

  @override
  String friendShareProfileTitle(Object name) {
    return 'Share $name profile';
  }

  @override
  String get friendShareProfileDescription => 'Generate a QR code or a link for this specific contact profile.';

  @override
  String friendShareMessage(Object name, Object url) {
    return 'Join me on Bicount and link the profile for $name: $url';
  }

  @override
  String get friendMyProfile => 'my Bicount profile';

  @override
  String get friendScanInvite => 'Scan invite';

  @override
  String get friendScanQrTitle => 'Scan invitation QR code';

  @override
  String get friendPendingRequests => 'Pending requests';

  @override
  String get friendIncomingEmpty => 'No incoming invitations for now.';

  @override
  String get friendSentInvitations => 'Sent invitations';

  @override
  String get friendSentEmpty => 'You have not shared a contact profile yet.';

  @override
  String get friendCurrentFriends => 'Active contacts';

  @override
  String get friendCurrentEmpty => 'Your accepted contacts will show up here in real time.';

  @override
  String get friendInvitePreview => 'Invitation preview';

  @override
  String friendProfileToLink(Object name) {
    return 'Profile to link: $name';
  }

  @override
  String friendInviteExpiresOn(Object date) {
    return 'This invite expires on $date.';
  }

  @override
  String get friendShareGenerate => 'Generate invite';

  @override
  String get friendShareRefresh => 'Refresh link';

  @override
  String get friendShareLink => 'Share link';

  @override
  String get friendShareScanQr => 'Scan QR';

  @override
  String get friendInvitationLinkCopied => 'Invitation link copied.';

  @override
  String get friendInvitationReady => 'Invitation ready to share.';

  @override
  String get friendInvitationNotFound => 'This invitation was not found.';

  @override
  String get friendInvitationAccepted => 'Invitation accepted.';

  @override
  String get friendInvitationRejected => 'Invitation rejected.';

  @override
  String get friendInvitationPreviewOnlineRequired => 'Connect to the internet to load this invitation.';

  @override
  String get friendInvitationAcceptOnlineRequired => 'Connect to the internet to accept this invitation.';

  @override
  String get friendInvitationRejectOnlineRequired => 'Connect to the internet to reject this invitation.';

  @override
  String get friendInvitationAcceptSignInRequired => 'Sign in to accept this invitation.';

  @override
  String get friendInvitationRejectSignInRequired => 'Sign in to reject this invitation.';

  @override
  String get friendInvitationLoadFailed => 'Unable to load this invitation right now.';

  @override
  String get friendInvitationAcceptFailed => 'Unable to accept this invitation right now.';

  @override
  String get friendInvitationRejectFailed => 'Unable to reject this invitation right now.';

  @override
  String friendProfileShared(Object name) {
    return 'Profile shared: $name';
  }

  @override
  String friendSharedBy(Object status, Object sender) {
    return '$status · shared by $sender';
  }

  @override
  String get friendLinkedAccount => 'Linked account';

  @override
  String get friendLocalFriend => 'Local contact';

  @override
  String get friendLinkHint => 'This contact is still local to your account. Use the share button to link it when the person has created a Bicount profile.';

  @override
  String get friendGiven => 'Paid out';

  @override
  String get friendReceived => 'Collected';

  @override
  String get friendNet => 'Net balance';

  @override
  String get friendSharedTransactions => 'Shared operations';

  @override
  String get friendTransactionsEmpty => 'Transactions with this contact will appear here in real time.';

  @override
  String get friendUnableToReadInvite => 'Unable to read this invitation.';

  @override
  String get friendEditTitle => 'Edit contact';

  @override
  String get friendEditDescription => 'Update the local name and avatar used for this contact.';

  @override
  String get friendProfileUpdated => 'Contact updated.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusUnsubscribed => 'Unsubscribed';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get transactionNoTransactionsFound => 'No transactions found';

  @override
  String get transactionToday => 'Today';

  @override
  String get transactionYesterday => 'Yesterday';

  @override
  String get transactionFilterAll => 'All';

  @override
  String get transactionFilterIncome => 'Income';

  @override
  String get transactionFilterExpense => 'Expense';

  @override
  String get transactionFilterSubscription => 'Subscription';

  @override
  String get transactionFilterSalary => 'Salary';

  @override
  String get transactionFilterOther => 'Other';

  @override
  String get transactionFilterPersonal => 'Personal';

  @override
  String get transactionExpenseTitle => 'Add expense';

  @override
  String get transactionIncomeTitle => 'Add income';

  @override
  String get transactionEditTitle => 'Edit transaction';

  @override
  String get transactionNewSubscriptionTitle => 'New subscription';

  @override
  String get transactionAddFundsTitle => 'Add funds to your account';

  @override
  String get transactionSavedSuccess => 'Transaction saved successfully.';

  @override
  String get transactionDeletedSuccess => 'Transaction deleted successfully.';

  @override
  String get transactionUpdatedSuccess => 'Transaction updated successfully.';

  @override
  String get transactionDeleteConfirmTitle => 'Delete this transaction?';

  @override
  String get transactionDeleteConfirmDescription => 'This action removes the transaction from your history and syncs the deletion when possible.';

  @override
  String get transactionDeleteConfirmCta => 'Delete transaction';

  @override
  String get transactionDuplicateBeneficiary => 'This beneficiary is already in the split.';

  @override
  String get transactionEditSingleBeneficiaryOnly => 'Edit this transaction with one beneficiary only.';

  @override
  String get transactionAddAtLeastOneBeneficiary => 'Add at least one beneficiary.';

  @override
  String get transactionIncomeSenderCannotBeCurrentUser => 'Income sender cannot be you. Income always uses the current user as beneficiary.';

  @override
  String get transactionEnterValidAmount => 'Enter a valid amount.';

  @override
  String get transactionPreviewEnterValidTotal => 'Enter a valid total amount to preview the split.';

  @override
  String get transactionSplitMethod => 'Split method';

  @override
  String get transactionSplitDetails => 'Split details';

  @override
  String get transactionSplitEqually => 'Split equally';

  @override
  String get transactionSplitModeEqual => 'Equal';

  @override
  String get transactionSplitModePercentage => 'Percentage';

  @override
  String get transactionSplitModeCustom => 'Custom';

  @override
  String get transactionSplitHelperEqual => 'Bicount splits the total amount equally for every beneficiary.';

  @override
  String get transactionSplitHelperPercentage => 'Set a percentage for each beneficiary. The total must reach 100%.';

  @override
  String get transactionSplitHelperCustom => 'Set the exact amount received by each beneficiary.';

  @override
  String get transactionSetPercentageReceived => 'Set the percentage received.';

  @override
  String get transactionSetExactAmountReceived => 'Set the exact amount received.';

  @override
  String get transferEnterTransactionName => 'Enter transaction name';

  @override
  String get transferPaidBy => 'Paid by';

  @override
  String get transferEnterSenderName => 'Enter sender name';

  @override
  String get transferItsMePayer => 'It\'s me paying';

  @override
  String get transferBeneficiaries => 'Beneficiaries';

  @override
  String get transferEnterBeneficiaryName => 'Enter beneficiary name';

  @override
  String get transferBeneficiariesHint => 'Add as many receivers as you want. Use Me if you are also receiving a share.';

  @override
  String get subscriptionIntro => 'Register a recurring payment such as streaming services, internet, gym, software, or any repetitive expense.';

  @override
  String get subscriptionName => 'Subscription name';

  @override
  String get subscriptionNameHint => 'e.g. Netflix, Spotify...';

  @override
  String get subscriptionFrequencyHint => 'Choose the frequency';

  @override
  String get subscriptionStartDate => 'Start date';

  @override
  String get subscriptionNextPaymentDifferent => 'The next payment will be on a different date.';

  @override
  String get subscriptionNextBillingDate => 'Next billing date';

  @override
  String get subscriptionEditTitle => 'Edit subscription';

  @override
  String get subscriptionSavedSuccess => 'Subscription saved successfully!';

  @override
  String get subscriptionUpdatedSuccess => 'Subscription updated successfully.';

  @override
  String get subscriptionDeletedSuccess => 'Subscription deleted successfully.';

  @override
  String get subscriptionSearchPrompt => 'Search by subscription name or note.';

  @override
  String get subscriptionSearchEmpty => 'No subscription matches your search.';

  @override
  String get subscriptionNextBilling => 'Next billing';

  @override
  String get subscriptionBillingStop => 'Billing stop';

  @override
  String get subscriptionCumulativeExpenses => 'Cumulative expenses';

  @override
  String get subscriptionSubscribedOn => 'Subscribed on';

  @override
  String get subscriptionUnsubscribe => 'Unsubscribe';

  @override
  String get subscriptionUnsubscribeSuccess => 'Subscription cancelled successfully.';

  @override
  String get subscriptionDeleteConfirmTitle => 'Delete this subscription?';

  @override
  String get subscriptionDeleteConfirmDescription => 'This action removes the subscription and its linked generated entries from your history.';

  @override
  String get subscriptionDeleteConfirmCta => 'Delete subscription';

  @override
  String get accountFundingIntro => 'Record a one-time deposit or set up a recurring income like salary so your balance stays up to date.';

  @override
  String get accountFundingEnterSource => 'Enter source of funds';

  @override
  String get accountFundingSavedSuccess => 'Account funding transaction added successfully';

  @override
  String get accountFundingUpdatedSuccess => 'Account funding updated successfully';

  @override
  String get accountFundingDeletedSuccess => 'Account funding deleted successfully.';

  @override
  String get accountFundingRecurringSavedSuccess => 'Recurring income saved successfully';

  @override
  String get accountFundingDeleteConfirmTitle => 'Delete this added fund?';

  @override
  String get accountFundingDeleteConfirmDescription => 'This action removes the added fund from your history and updates your projections.';

  @override
  String get accountFundingDeleteConfirmCta => 'Delete added fund';

  @override
  String get accountFundingEditTitle => 'Edit added funds';

  @override
  String get accountFundingTypeTitle => 'Income type';

  @override
  String get accountFundingTypeHint => 'Choose an income type';

  @override
  String get accountFundingTypeSalary => 'Salary';

  @override
  String get accountFundingTypeOther => 'Other income';

  @override
  String get accountFundingRepeatLabel => 'Repeat this income automatically';

  @override
  String get accountFundingFrequencyHint => 'Choose how often it repeats';

  @override
  String get accountFundingFirstCreditDate => 'First credit date';

  @override
  String get salaryConfirmBeforeCountingTitle => 'Confirm each salary before counting it';

  @override
  String get salaryConfirmBeforeCountingHelper => 'Use this when your employer can pay late and you only want confirmed money to affect your balance.';

  @override
  String get salaryReminderToggleTitle => 'Remind me on payday';

  @override
  String get salaryReminderToggleHelper => 'Bicount will ask if the salary has been received when the due date arrives.';

  @override
  String get salaryTrackingTitle => 'Recurring fundings';

  @override
  String get salaryEmptyState => 'Create a recurring funding from Add funds to follow expected payments and confirmed credits.';

  @override
  String get salaryAttentionSectionTitle => 'Needs confirmation';

  @override
  String get salaryPlansTitle => 'Recurring plans';

  @override
  String get salaryRecentPaymentsTitle => 'Recent recorded payments';

  @override
  String get salaryOverdueTitle => 'Arrears';

  @override
  String get salaryDueTodayTitle => 'Due today';

  @override
  String get salaryNextPaydayTitle => 'Next expected';

  @override
  String get salaryModeConfirm => 'Confirm first';

  @override
  String get salaryModeAutomatic => 'Automatic';

  @override
  String get salaryStatusUpcoming => 'Upcoming';

  @override
  String get salaryStatusDueToday => 'Due today';

  @override
  String get salaryStatusOverdue => 'Overdue';

  @override
  String get salaryStatusReceived => 'Received';

  @override
  String salaryExpectedOn(Object date) {
    return 'Expected on $date';
  }

  @override
  String salaryReceivedOn(Object date) {
    return 'Received on $date';
  }

  @override
  String salaryNextPaydayValue(Object date) {
    return 'Next expected: $date';
  }

  @override
  String salaryReminderStatusValue(Object status) {
    return 'Reminders: $status';
  }

  @override
  String salaryArrearsValue(Object amount) {
    return 'Pending: $amount';
  }

  @override
  String get salaryConfirmPaymentCta => 'Confirm payment received';

  @override
  String get salaryKeepAutomaticCta => 'Stop reminders and keep automatic credits';

  @override
  String get salaryAutomaticModeHelper => 'This payment will be counted now and future recurring credits will rely on the automatic backend flow.';

  @override
  String get salaryReminderDisabledHelper => 'Reminders are already disabled for this salary.';

  @override
  String get salaryPaymentConfirmedSuccess => 'Recurring payment confirmed successfully.';

  @override
  String get salaryAutomaticModeEnabledSuccess => 'Recurring tracking switched back to automatic mode.';

  @override
  String get salaryHomeCardTitle => 'Recurring follow-up';

  @override
  String salaryHomeCardAttention(Object amount) {
    return 'Pending amount: $amount';
  }

  @override
  String salaryHomeCardNext(Object date) {
    return 'Next recurring funding on $date';
  }

  @override
  String salaryHomeCardCount(Object count) {
    return '$count payments need attention';
  }

  @override
  String salaryPlansCount(Object count) {
    return '$count active recurring plans';
  }

  @override
  String get runtimeSalaryConfirmFailed => 'Unable to confirm this salary payment right now.';

  @override
  String get runtimeSalaryTrackingSaveFailed => 'Unable to update this recurring tracking right now.';

  @override
  String get recurringChargesTitle => 'Charges';

  @override
  String get recurringIncomesTitle => 'Recurring incomes';

  @override
  String get recurringChargesIntro => 'Keep an eye on the recurring charges that hit your balance, review their pace, and stop or update them when the context changes.';

  @override
  String get recurringIncomesIntro => 'Follow your recurring incomes in one place, update them when the amount changes, and keep the schedule aligned with reality.';

  @override
  String get recurringChargesEmpty => 'No recurring charge is active yet.';

  @override
  String get recurringIncomesEmpty => 'No recurring income is active yet.';

  @override
  String get recurringPlanRecordedTotalLabel => 'Recorded total';

  @override
  String get recurringPlanRecordedCountLabel => 'Recorded payments';

  @override
  String get recurringPlanTerminateCta => 'Stop this plan';

  @override
  String get recurringPlanDeleteConfirmTitle => 'Delete this recurring plan?';

  @override
  String get recurringIncomeDeleteWarning => 'This will remove the recurring income plan and its linked generated payments on this device. Continue only if you really want to discard the follow-up.';

  @override
  String get recurringChargeDeleteWarning => 'This will remove the recurring charge plan and its linked generated payments on this device. Continue only if you really want to discard the follow-up.';

  @override
  String get recurringPlanDeleteConfirmCta => 'Delete plan';

  @override
  String get recurringPlanUpdatedSuccess => 'Recurring plan updated successfully.';

  @override
  String get recurringPlanStoppedSuccess => 'Recurring plan stopped successfully.';

  @override
  String get recurringPlanDeletedSuccess => 'Recurring plan deleted successfully.';

  @override
  String get runtimeRecurringPlanUpdateFailed => 'Unable to update this recurring plan right now.';

  @override
  String get runtimeRecurringPlanTerminateFailed => 'Unable to stop this recurring plan right now.';

  @override
  String get runtimeRecurringPlanDeleteFailed => 'Unable to delete this recurring plan right now.';

  @override
  String get runtimeRecurringSalaryConfirmFailed => 'Unable to confirm this recurring salary right now.';

  @override
  String get runtimeRecurringSalaryUpdateFailed => 'Unable to update this recurring salary right now.';

  @override
  String get transactionTypeTransfer => 'Transfer';

  @override
  String get transactionTypeSalary => 'Salary';

  @override
  String get transactionTypeSubscription => 'Subscription';

  @override
  String get transactionTypeAddFund => 'Add funds';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeOther => 'Other';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyQuarterly => 'Quarterly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get frequencyOneTime => 'One time';

  @override
  String get runtimeSplitPercentagePositive => 'Every beneficiary needs a percentage greater than zero.';

  @override
  String get runtimeSplitPercentagesTotal => 'Percentages must add up to 100%.';

  @override
  String get runtimeSplitAmountPositive => 'Every beneficiary needs an amount greater than zero.';

  @override
  String get runtimeSplitMismatch => 'The split does not match the total amount. Check the individual amounts.';

  @override
  String get recurringToggleTitle => 'Set as recurring';

  @override
  String get recurringToggleSubtitleExpense => 'This amount will be debited from your balance on a recurring basis.';

  @override
  String get recurringToggleSubtitleIncome => 'This amount will be credited to your balance on a recurring basis.';

  @override
  String get recurringFrequencyLabel => 'Repeat every';

  @override
  String get recurringTypeSubscription => 'Subscription';

  @override
  String get recurringTypeOther => 'Other recurring';

  @override
  String get recurringTypeSalary => 'Salary';

  @override
  String get recurringTypeOtherIncome => 'Other recurring income';

  @override
  String get recurringTypeLabel => 'Category';
}
