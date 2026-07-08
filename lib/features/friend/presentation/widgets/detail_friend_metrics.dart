import 'package:bicount/core/constants/icon_links.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/features/friend/domain/entities/friend_detail_entity.dart';
import 'package:bicount/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class DetailFriendMetrics extends StatelessWidget {
  const DetailFriendMetrics({super.key, required this.detail});

  final FriendDetailEntity detail;

  // Seuil pour décider si une carte doit prendre toute la largeur
  static const double _largeAmountThreshold = 1000000;

  bool _isLarge(double value) => value.abs() >= _largeAmountThreshold;

  @override
  Widget build(BuildContext context) {
    final otherTheme = Theme.of(context).extension<OtherTheme>()!;

    final metrics = [
      _MetricData(
        icon: IconLinks.expense,
        title: context.l10n.friendGiven,
        value: detail.totalGiven,
        color: otherTheme.expense!,
      ),
      _MetricData(
        icon: IconLinks.income,
        title: context.l10n.friendReceived,
        value: detail.totalReceived,
        color: otherTheme.income!,
      ),
    ];

    return Column(children: _buildLayout(context, metrics));
  }

  List<Widget> _buildLayout(BuildContext context, List<_MetricData> metrics) {
    final List<Widget> children = [];
    int i = 0;
    while (i < metrics.length) {
      final current = metrics[i];

      // Si l'élément actuel est "large" ou s'il est le dernier, il prend toute la largeur
      if (_isLarge(current.value) || i == metrics.length - 1) {
        children.add(_buildCard(current));
        i++;
      } else {
        final next = metrics[i + 1];
        // Si le suivant est "large", l'actuel prend toute la largeur
        // et le suivant sera traité à l'itération suivante
        if (_isLarge(next.value)) {
          children.add(_buildCard(current));
          i++;
        } else {
          // Les deux sont assez petits pour être côte à côte
          children.add(
            Row(
              children: [
                Flexible(child: _buildCard(current)),
                const SizedBox(width: AppDimens.marginMedium),
                Flexible(child: _buildCard(next)),
              ],
            ),
          );
          i += 2;
        }
      }
    }
    return children;
  }

  Widget _buildCard(_MetricData data) {
    return SpecialInfoCardAmount(
      icon: data.icon,
      title: data.title,
      value: data.value,
      currencyCode: detail.displayCurrencyCode,
      color: data.color,
    );
  }
}

class _MetricData {
  final String icon;
  final String title;
  final double value;
  final Color color;

  _MetricData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}
