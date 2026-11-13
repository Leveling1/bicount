part of 'transaction_detail_content.dart';

extension on TransactionDetailContent {
  List<Widget> _detailRows(
    BuildContext context,
    TransactionEntity data,
    String formattedDate,
    String formattedTime,
    String sender,
    String beneficiary,
  ) => [
    DetailsCard(
      child: Column(
        children: [
          TransactionDetailRow(
            title: context.l10n.commonDate,
            content: formattedDate,
          ),
          const SizedBox(height: 8),
          TransactionDetailRow(
            title: context.l10n.commonTime,
            content: formattedTime,
          ),
        ],
      ),
    ),
    DetailsCard(
      child: Column(
        children: [
          TransactionDetailRow(
            title: context.l10n.commonSender,
            content: sender,
          ),
          const SizedBox(height: 8),
          TransactionDetailRow(
            title: context.l10n.commonBeneficiary,
            content: beneficiary,
          ),
        ],
      ),
    ),
    if (debt != null) _buildDebtProgress(context, debt!),
    DetailsCard(
      child: Column(
        children: [
          TransactionDetailRow(
            title: context.l10n.commonFrequency,
            content: context.frequencyLabel(data.frequency ?? 0),
          ),
          if (data.note.isNotEmpty) const SizedBox(height: 8),
          if (data.note.isNotEmpty)
            TransactionDetailRow(
              title: context.l10n.commonNote,
              content: data.note,
            ),
        ],
      ),
    ),
  ];
}
