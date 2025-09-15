import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText(
      this.text, {
        super.key,
        this.trimLines = 2,
      });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      softWrap: true,
      overflow: TextOverflow.fade,
      maxLines: _expanded ? null : widget.trimLines,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Animation fluide quand on change la taille
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: textWidget,
        ),

        if (_shouldShowMore(widget.text))
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? "Voir moins" : "Voir plus",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _shouldShowMore(String text) {
    // approximation simple : tu peux améliorer avec TextPainter
    return text.length > widget.trimLines * 50;
  }
}
