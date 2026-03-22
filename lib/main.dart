import 'package:bicount/app/bicount_app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrapBicountApp();
  runApp(const MyApp());
}
