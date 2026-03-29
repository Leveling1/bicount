import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguagePreferenceCard extends StatelessWidget {
  const LanguagePreferenceCard({
    super.key,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.onTap,
  });

  final String title;
  final String description;
  final String currentValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.marginMedium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentValue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(CupertinoIcons.chevron_right, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
