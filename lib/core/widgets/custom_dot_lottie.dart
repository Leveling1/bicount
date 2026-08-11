import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';

class CustomDotLottie extends StatelessWidget {
  const CustomDotLottie({super.key, this.size = 200, required this.filePath});

  final double size;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DotLottieView(
        sourceType: 'asset',
        source: filePath,
        autoplay: true,
        loop: true,
        mode: 'bounce',
      ),
    );
  }
}
