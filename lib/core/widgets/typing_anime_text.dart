import 'dart:async';
import 'package:flutter/material.dart';

class TypingAnimeText extends StatefulWidget {
  final List<String>? texts;
  final TextStyle? textStyle;

  const TypingAnimeText({super.key, this.texts, this.textStyle});

  @override
  State<TypingAnimeText> createState() => _TypingAnimeTextState();
}

class _TypingAnimeTextState extends State<TypingAnimeText> {
  late List<String> _texts;
  int _textIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  Timer? _timer;

  final ValueNotifier<String> _currentText = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _texts =
        widget.texts ??
        [
          'Gerez vos comptes facilement.',
          'Suivez vos depenses a deux.',
          'Bicount s\'occupe des calculs.',
        ];
    _startAnimation();
  }

  void _startAnimation() {
    final duration = Duration(milliseconds: _isDeleting ? 40 : 80);

    _timer = Timer(duration, () {
      final currentFullText = _texts[_textIndex];

      if (!_isDeleting) {
        _charIndex++;
        _currentText.value = currentFullText.substring(0, _charIndex);

        if (_charIndex == currentFullText.length) {
          _isDeleting = true;
          _timer = Timer(const Duration(milliseconds: 1500), _startAnimation);
          return;
        }
      } else {
        _charIndex--;
        _currentText.value = currentFullText.substring(0, _charIndex);

        if (_charIndex == 0) {
          _isDeleting = false;
          _textIndex = (_textIndex + 1) % _texts.length;
          _timer = Timer(const Duration(milliseconds: 300), _startAnimation);
          return;
        }
      }

      _startAnimation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _currentText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).primaryColor,
    );

    final TextStyle finalStyle = widget.textStyle ?? defaultStyle;

    return SizedBox(
      // Augmenté à 64.0 pour laisser l'espace vertical nécessaire aux 2 lignes
      height: 64.0,
      child: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: _currentText,
          builder: (context, textValue, child) {
            // RichText permet au texte de se couper sur 2 lignes de manière responsive
            return RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: textValue,
                style: finalStyle,
                children: [
                  // WidgetSpan permet d'injecter ton curseur rond directement dans le flux du texte
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _BlinkingCursor(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 24.0,
        // Réduit légèrement pour être plus harmonieux à la fin d'un mot
        height: 24.0,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        margin: const EdgeInsets.only(left: 4.0),
      ),
    );
  }
}
