import 'package:bicount/app/bicount_app.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrapBicountApp();
  await BicountHomeWidgetService.instance.initialize();
  runApp(const MyApp());
}
