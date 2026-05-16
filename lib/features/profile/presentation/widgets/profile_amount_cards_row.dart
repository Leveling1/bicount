import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class ProfileAmountCardsRow extends StatelessWidget {
  const ProfileAmountCardsRow({
    super.key,
    required this.leftTitle,
    required this.leftIcon,
    required this.leftValue,
    required this.leftColor,
    required this.rightTitle,
    required this.rightIcon,
    required this.rightValue,
    required this.rightColor,
  });

  final String leftTitle;
  final String leftIcon;
  final double leftValue;
  final Color leftColor;
  final String rightTitle;
  final String rightIcon;
  final double rightValue;
  final Color rightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: InfoCardAmount(
            icon: leftIcon,
            title: leftTitle,
            value: leftValue,
            color: leftColor,
          ),
        ),
        const SizedBox(width: AppDimens.marginMedium),
        Flexible(
          child: InfoCardAmount(
            icon: rightIcon,
            title: rightTitle,
            value: rightValue,
            color: rightColor,
          ),
        ),
      ],
    );
  }
}
