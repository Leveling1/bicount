import 'package:flutter/material.dart';

class TitleIconButtomRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? onPressed;
  const TitleIconButtomRow({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(5),
              splashColor: Colors.transparent,
              highlightColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(8.0), // 👈 espace cliquable
                child: Icon(
                  icon,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
