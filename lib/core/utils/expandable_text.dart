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

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      softWrap: true,
      textAlign: TextAlign.justify,
      overflow: TextOverflow.fade,
      maxLines: _expanded ? null : widget.trimLines,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        if (_shouldShowMore(widget.text))
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? "Voir moins" : "Voir plus",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Vérifie si le texte dépasse la limite
  bool _shouldShowMore(String text) {
    return text.length > widget.trimLines * 50;
  }
}
