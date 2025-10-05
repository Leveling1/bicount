import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final void Function(double, bool)? onHeightChanged;

  const ExpandableText(
      this.text, {
        super.key,
        this.trimLines = 2,
        this.onHeightChanged,
      });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _showMoreButton = false; // Nouveau booléen pour contrôler l'affichage du bouton
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Vérifier le débordement après que le widget est construit
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTextOverflow());
  }

  void _checkTextOverflow() {
    final RenderBox? box = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final textPainter = TextPainter(
        text: TextSpan(text: widget.text, style: Theme.of(context).textTheme.bodyMedium), // Utilisez le style de votre texte
        maxLines: widget.trimLines,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: box.size.width);
      setState(() {
        // Afficher le bouton si le texte peint dépasse le nombre de lignes maximal
        _showMoreButton = textPainter.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      key: _textKey, // Clé pour obtenir la largeur du conteneur
      softWrap: true,
      overflow: TextOverflow.fade,
      maxLines: _expanded ? null : widget.trimLines,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            // Supprimez le minHeight problématique, utilisez plutôt la contrainte
            constraints: BoxConstraints(
              minHeight: 0,
            ),
            child: textWidget,
          ),
        ),
        // Afficher le bouton uniquement si nécessaire
        if (_showMoreButton)
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
              // Re-vérifier le débordement après expansion/réduction
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (widget.onHeightChanged != null) {
                  final RenderBox? box = _textKey.currentContext?.findRenderObject() as RenderBox?;
                  if (box != null) {
                    widget.onHeightChanged!(box.size.height, _expanded);
                  }
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? "Show less" : "Show more",
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
}