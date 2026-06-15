import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controller,
    required this.validateCode,
    required this.submit,
    required this.loading,
    required this.isSuccess,
    required this.isError,
    this.onSuccessAnimationFinished,
  });

  final TextEditingController controller;
  final String? Function(String?) validateCode;
  final void Function() submit;
  final bool loading;
  final bool isSuccess;
  final bool isError;
  final VoidCallback? onSuccessAnimationFinished;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final int _length = 6;

  bool _isLocalSuccess = false;
  bool _showCheckMark = false;
  bool _ignoreErrorVisually = false; // 🎯 Permet d'annuler visuellement l'erreur en local
  List<String> _displayDigits = [];

  late AnimationController _checkmarkAnimationController;
  late AnimationController _loadingRotationController;

  @override
  void initState() {
    super.initState();
    _displayDigits = List.generate(_length, (_) => "");
    widget.controller.addListener(_onTextChanged);

    _checkmarkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loadingRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _checkmarkAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onSuccessAnimationFinished != null) {
          widget.onSuccessAnimationFinished!();
        }
      }
    });

    if (widget.loading) {
      _loadingRotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.loading && !_loadingRotationController.isAnimating) {
      _loadingRotationController.repeat();
    } else if (!widget.loading && _loadingRotationController.isAnimating) {
      _loadingRotationController.stop();
    }

    if (widget.isSuccess && !oldWidget.isSuccess) {
      _triggerSuccessAnimation();
    }

    // 🎯 Si le parent envoie une nouvelle erreur (différente de l'ancienne), on réactive l'affichage de l'erreur
    if (widget.isError && !oldWidget.isError) {
      setState(() {
        _ignoreErrorVisually = false;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _checkmarkAnimationController.dispose();
    _loadingRotationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (_isLocalSuccess) return;

    setState(() {
      for (int i = 0; i < _length; i++) {
        _displayDigits[i] = i < text.length ? text[i] : "";
      }

      // 🎯 Si l'utilisateur efface un chiffre (longueur < 6), on masque l'erreur visuellement en local
      if (text.length < _length) {
        _ignoreErrorVisually = true;
      }
    });
  }

  void _triggerSuccessAnimation() async {
    setState(() {
      _isLocalSuccess = true;
    });
    _focusNode.unfocus(); 

    await Future.delayed(const Duration(milliseconds: 550));
    
    if (!mounted) return;
    setState(() {
      _showCheckMark = true;
    });

    _checkmarkAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColorNormal = Theme.of(context)
            .elevatedButtonTheme
            .style
            ?.backgroundColor
            ?.resolve({})
            ?.withValues(alpha: 0.7) ??
        Colors.grey;

    final Color errorColor = Theme.of(context).colorScheme.error;
    double totalWidth = (_length * 50) + ((_length - 1) * 8);

    // 🎯 Détermine si on doit afficher l'état d'erreur visuel actuel
    final showAnError = widget.isError && !_ignoreErrorVisually;

    return Center(
      child: GestureDetector(
        onTap: () {
          if (!_isLocalSuccess && !widget.loading) _focusNode.requestFocus();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                width: totalWidth,
                height: 50,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: _length,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(counterText: ""),
                  enabled: !widget.loading && !_isLocalSuccess,
                ),
              ),
            ),

            SizedBox(
              height: 50,
              width: totalWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(_length, (index) {
                    double xAlignment = _isLocalSuccess
                        ? 0.0
                        : -1.0 + (index * (2.0 / (_length - 1)));

                    final currentLength = widget.controller.text.length;
                    
                    bool isCurrentBoxFocused = _focusNode.hasFocus && 
                        (currentLength == index || (currentLength == _length && index == _length - 1));

                    return AnimatedAlign(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment(xAlignment, 0.0),
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isLocalSuccess
                                    ? Colors.green
                                    : (showAnError
                                        ? errorColor
                                        : (isCurrentBoxFocused
                                            ? borderColorNormal
                                            : borderColorNormal.withValues(alpha: 0.4))),
                                width: isCurrentBoxFocused ? 1.8 : 1.2,
                              ),
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    scale: _isLocalSuccess ? 0.0 : 1.0,
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 150),
                                      opacity: _isLocalSuccess 
                                          ? 0.0 
                                          : (widget.loading ? 0.4 : 1.0),
                                      child: Text(
                                        _displayDigits[index],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: showAnError
                                              ? errorColor
                                              : Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 🎯 Le curseur prend la couleur rouge (errorColor) s'il y a une erreur
                                  if (isCurrentBoxFocused && !widget.loading)
                                    _BlinkingCursor(
                                      color: showAnError ? errorColor : borderColorNormal, 
                                      isOnTheRight: currentLength == _length,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          if (widget.loading && !_isLocalSuccess)
                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _loadingRotationController,
                                builder: (context, child) {
                                  return SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CustomPaint(
                                      painter: LoadingBorderPainter(
                                        animationValue: _loadingRotationController.value,
                                        color: borderColorNormal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  if (_showCheckMark)
                    AnimatedBuilder(
                      animation: _checkmarkAnimationController,
                      builder: (context, child) {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomPaint(
                            painter: AnimatedCheckmarkPainter(
                              _checkmarkAnimationController.value,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingBorderPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  LoadingBorderPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    paint.shader = SweepGradient(
      colors: [
        color.withValues(alpha: 0.0), 
        color,                       
        color.withValues(alpha: 0.0), 
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(animationValue * 2 * 3.141592653589793),
    ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant LoadingBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class AnimatedCheckmarkPainter extends CustomPainter {
  final double value;
  AnimatedCheckmarkPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    double startX = size.width * 0.28;
    double startY = size.height * 0.50;
    double midX = size.width * 0.44;
    double midY = size.height * 0.66;
    double endX = size.width * 0.72;
    double endY = size.height * 0.36;

    path.moveTo(startX, startY);
    path.lineTo(midX, midY);
    path.lineTo(endX, endY);

    final totalPath = Path();
    for (final metric in path.computeMetrics()) {
      totalPath.addPath(
        metric.extractPath(0.0, metric.length * value),
        Offset.zero,
      );
    }
    canvas.drawPath(totalPath, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedCheckmarkPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final bool isOnTheRight;
  const _BlinkingCursor({required this.color, this.isOnTheRight = false});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isOnTheRight ? const Alignment(0.6, 0.0) : Alignment.center,
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          width: 2.2,
          height: 20,
          color: widget.color,
        ),
      ),
    );
  }
}