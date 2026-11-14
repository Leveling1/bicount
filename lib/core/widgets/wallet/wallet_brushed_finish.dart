part of 'wallet_card_face.dart';

class _BrushedFinish extends CustomPainter {
  const _BrushedFinish();

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Paint()..color = const Color(0x0C4F4535);
    final light = Paint()..color = const Color(0x22FFFFFF);
    for (var y = 1.0; y < size.height; y += 2.5) {
      final end = size.width * (.62 + .38 * (1 + math.sin(y * 1.9)) / 2);
      canvas.drawLine(Offset(0, y), Offset(end, y), dark);
      canvas.drawLine(
        Offset(size.width - end, y + 1),
        Offset(size.width, y + 1),
        light,
      );
    }
  }

  @override
  bool shouldRepaint(_BrushedFinish oldDelegate) => false;
}
