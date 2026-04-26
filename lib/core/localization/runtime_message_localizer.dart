import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

String localizeRuntimeMessage(BuildContext context, String message) {
  final normalized = message.trim();

  switch (normalized) {
    case 'Unable to read this invitation.':
      return context.l10n.friendUnableToReadInvite;
    case 'This invitation was not found.':
      return context.l10n.friendInvitationNotFound;
    case 'Connect to the internet to load this invitation.':
      return context.l10n.friendInvitationPreviewOnlineRequired;
    case 'Connect to the internet to accept this invitation.':
      return context.l10n.friendInvitationAcceptOnlineRequired;
    case 'Connect to the internet to reject this invitation.':
      return context.l10n.friendInvitationRejectOnlineRequired;
    case 'Sign in to accept this invitation.':
      return context.l10n.friendInvitationAcceptSignInRequired;
    case 'Sign in to reject this invitation.':
      return context.l10n.friendInvitationRejectSignInRequired;
    case 'Unable to load this invitation right now.':
      return context.l10n.friendInvitationLoadFailed;
    case 'Unable to accept this invitation right now.':
      return context.l10n.friendInvitationAcceptFailed;
    case 'Unable to reject this invitation right now.':
      return context.l10n.friendInvitationRejectFailed;
    case 'Invitation ready to share.':
      return context.l10n.friendInvitationReady;
    case 'Invitation accepted.':
      return context.l10n.friendInvitationAccepted;
    case 'Invitation rejected.':
      return context.l10n.friendInvitationRejected;
    case 'Invitation link copied.':
      return context.l10n.friendInvitationLinkCopied;
    case 'This beneficiary is already in the split.':
      return context.l10n.transactionDuplicateBeneficiary;
    case 'Add at least one beneficiary.':
      return context.l10n.transactionAddAtLeastOneBeneficiary;
    case 'Enter a valid amount.':
      return context.l10n.transactionEnterValidAmount;
    case 'Enter a valid total amount to preview the split.':
      return context.l10n.transactionPreviewEnterValidTotal;
    case 'Unable to save this friend right now.':
    case 'An error occurred while saving your new friend.':
      return context.l10n.runtimeFriendSaveFailed;
    case 'The transaction could not be saved.':
      return context.l10n.runtimeTransactionSaveFailed;
    case 'Unable to delete this transaction right now.':
      return context.l10n.runtimeTransactionDeleteFailed;
    case 'Unable to update this transaction right now.':
      return context.l10n.runtimeTransactionUpdateFailed;
    case 'Unable to delete this subscription right now.':
      return context.l10n.runtimeSubscriptionDeleteFailed;
    case 'Unable to save this subscription right now.':
      return context.l10n.runtimeSubscriptionSaveFailed;
    case 'Unable to update this subscription right now.':
      return context.l10n.runtimeSubscriptionUnsubscribeFailed;
    case 'Unable to update this recurring plan right now.':
      return context.l10n.runtimeRecurringPlanUpdateFailed;
    case 'Unable to stop this recurring plan right now.':
      return context.l10n.runtimeRecurringPlanTerminateFailed;
    case 'Unable to delete this recurring plan right now.':
      return context.l10n.runtimeRecurringPlanDeleteFailed;
    case 'Unable to delete this account funding right now.':
      return context.l10n.runtimeAccountFundingDeleteFailed;
    case 'Unable to save this account funding right now.':
    case 'Unable to update this account funding right now.':
      return context.l10n.runtimeAccountFundingSaveFailed;
    case 'Unable to confirm this recurring salary right now.':
      return context.l10n.runtimeRecurringSalaryConfirmFailed;
    case 'Unable to update this recurring salary right now.':
      return context.l10n.runtimeRecurringSalaryUpdateFailed;
    case 'Unable to confirm this salary payment right now.':
      return context.l10n.runtimeSalaryConfirmFailed;
    case 'Unable to update this salary tracking right now.':
      return context.l10n.runtimeSalaryTrackingSaveFailed;
    case 'Unable to save your profile right now.':
      return context.l10n.runtimeProfileSaveFailed;
    case 'Unable to load the exchange rate for this record date.':
    case 'Unable to load the latest exchange rates right now.':
      return context.l10n.runtimeCurrencyRateLoadFailed;
    case 'Connect to update this reference currency first.':
      return context.l10n.runtimeCurrencyOnlineSelectionRequired;
    case 'Unable to request Bicount Pro right now.':
      return context.l10n.runtimeProRequestFailed;
    case 'Unable to delete your account right now.':
      return context.l10n.runtimeDeleteAccountFailed;
    case 'An unexpected error occurred.':
    case 'Authentication failure':
    case 'uknown failure':
      return context.l10n.runtimeUnexpectedError;
    case 'Enter an amount greater than zero.':
      return context.l10n.validationAmountGreaterThanZero;
    case 'Every beneficiary needs a percentage greater than zero.':
      return context.l10n.runtimeSplitPercentagePositive;
    case 'Percentages must add up to 100%.':
      return context.l10n.runtimeSplitPercentagesTotal;
    case 'Every beneficiary needs an amount greater than zero.':
      return context.l10n.runtimeSplitAmountPositive;
    case 'The split does not match the total amount. Check the individual amounts.':
      return context.l10n.runtimeSplitMismatch;
    case 'Edit this transaction with one beneficiary only.':
      return context.l10n.transactionEditSingleBeneficiaryOnly;
    case 'An error occurred during the sign in.':
    case 'Sign in failed':
    case 'Exception: Sign in failed':
      return context.l10n.authGenericSignInError;
    case 'An error occurred during registration.':
    case 'Sign up failed':
    case 'Exception: Sign up failed':
      return context.l10n.authGenericSignUpError;
    case 'An error occurred during sign out.':
      return context.l10n.authGenericSignOutError;
    case 'Google sign-in failed.':
    case 'Echec de la connexion avec Google.':
    case 'Echec de l\'authentification avec Google':
      return context.l10n.authGoogleFailed;
    case 'No Google ID token found.':
    case 'Google did not return the email needed for Bicount.':
    case 'Aucun jeton d\'identification trouve.':
    case 'Email non fourni par Google':
      return context.l10n.authGoogleMissingEmail;
    case 'Google sign-in timed out. Please try again.':
    case 'Delai de connexion depasse. Veuillez reessayer.':
      return context.l10n.authGoogleTimeout;
    case 'Google sign-in cancelled.':
    case 'Connexion Google annulee':
      return context.l10n.authGoogleCancelled;
  }

  if (normalized.toLowerCase().contains('reseau') ||
      normalized.toLowerCase().contains('network')) {
    return context.l10n.authNetworkError;
  }

  if (normalized.startsWith('Error fetching ')) {
    return context.l10n.runtimeDataLoadFailed;
  }

  return message;
}
