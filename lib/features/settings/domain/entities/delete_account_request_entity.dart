class DeleteAccountRequestEntity {
  const DeleteAccountRequestEntity({
    required this.requestId,
    required this.reasonCode,
    required this.details,
  });

  final String requestId;
  final String reasonCode;
  final String details;
}
