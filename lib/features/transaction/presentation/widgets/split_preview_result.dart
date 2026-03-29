import '../../domain/entities/create_transaction_request_entity.dart';

class SplitPreviewResult {
  const SplitPreviewResult({
    required this.resolvedSplits,
    required this.sharesByKey,
    this.errorMessage,
  });

  final List<ResolvedTransactionSplitEntity> resolvedSplits;
  final Map<String, ResolvedTransactionSplitEntity> sharesByKey;
  final String? errorMessage;
}
