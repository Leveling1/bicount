import 'package:bicount/core/utils/formated_text.dart';
import 'package:flutter/material.dart';

class TransactionDetailRow extends StatelessWidget {
  const TransactionDetailRow({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Text(
            FormatedText().capitalizeFirstLetter(title),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Flexible(
          flex: 2,
          child: Text(
            FormatedText().capitalizeFirstLetter(content),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
