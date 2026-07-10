enum NotifiableAction { debtRecorded, accountLinked, salaryRecorded }

extension NotifiableActionX on NotifiableAction {
  static const String storagePrefix = 'notif_perm_';
  static const String fcmTokenStorageKey = 'notif_last_fcm_token';

  String get storageKey {
    switch (this) {
      case NotifiableAction.debtRecorded:
        return '${storagePrefix}debt_recorded';
      case NotifiableAction.accountLinked:
        return '${storagePrefix}account_linked';
      case NotifiableAction.salaryRecorded:
        return '${storagePrefix}salary_recorded';
    }
  }
}
