import 'package:flutter/material.dart';

class FriendScreenIntro extends StatelessWidget {
  const FriendScreenIntro({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
