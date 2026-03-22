class ProUpgradeRequestEntity {
  const ProUpgradeRequestEntity({
    required this.requestId,
    required this.contactEmail,
    required this.organizationName,
    required this.useCase,
  });

  final String requestId;
  final String contactEmail;
  final String organizationName;
  final String useCase;
}
