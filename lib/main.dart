import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bicount',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: Text("data"))),
    );
  }
}
