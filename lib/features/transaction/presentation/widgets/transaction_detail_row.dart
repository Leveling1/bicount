import 'package:bicount/core/utils/formated_text.dart';
import 'package:flutter/material.dart';

class TransactionDetailRow extends StatelessWidget {
  const TransactionDetailRow({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.capitalizeContent = true,
  });

  final String title;
  final String content;
  final Widget? trailing;
  final bool capitalizeContent;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final displayContent = capitalizeContent
        ? FormatedText().capitalizeFirstLetter(content)
        : content;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Text(
            FormatedText().capitalizeFirstLetter(title),
            style: style,
          ),
        ),
        Flexible(
          flex: 2,
          child: trailing == null
              ? Text(displayContent, style: style)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        displayContent,
                        style: style,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ),
        ),
      ],
    );
  }
}
