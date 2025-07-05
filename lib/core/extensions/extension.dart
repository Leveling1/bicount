import 'package:flutter/material.dart';

///[ForMediaQuery] extension  on [BuildContext] to get info about width and height of [context]
extension ForMediaQuery on BuildContext {
  Size get mediaQuery => MediaQuery.sizeOf(this);
  double get height => mediaQuery.height;
  double get width => mediaQuery.width;
  ScaffoldMessengerState get scaffoldMessage => ScaffoldMessenger.of(this);
}
