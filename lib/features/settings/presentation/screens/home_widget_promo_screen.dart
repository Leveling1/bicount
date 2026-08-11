import 'package:bicount/core/home_widget/bicount_home_widget_service.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Encourages the user to add the Bicount home screen widget. On Android
/// (API 26+, launcher permitting) it can request the pin directly; iOS has
/// no such API, so it always falls back to step-by-step instructions there.
class HomeWidgetPromoScreen extends StatefulWidget {
  const HomeWidgetPromoScreen({super.key});

  @override
  State<HomeWidgetPromoScreen> createState() => _HomeWidgetPromoScreenState();
}

class _HomeWidgetPromoScreenState extends State<HomeWidgetPromoScreen> {
  bool _isRequesting = false;
  bool _pinSupported = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final supported = await BicountHomeWidgetService.instance
        .isPinWidgetSupported();
    if (!mounted) {
      return;
    }
    setState(() => _pinSupported = supported);
  }

  Future<void> _handleAddPressed() async {
    setState(() => _isRequesting = true);
    try {
      await BicountHomeWidgetService.instance.requestPinWidget();
      if (!mounted) {
        return;
      }
      NotificationHelper.showSuccessNotification(
        context,
        context.l10n.homeWidgetPromoAddedSuccess,
      );
    } catch (_) {
      if (mounted) {
        NotificationHelper.showFailureNotification(
          context,
          context.l10n.homeWidgetPromoAddedFailure,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.settingsWidgetTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimens.paddingAllMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppDimens.spacerLarge,
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.widgets_outlined,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              AppDimens.spacerLarge,
              Text(
                l10n.homeWidgetPromoTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              AppDimens.spacerMedium,
              Text(
                l10n.homeWidgetPromoDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppDimens.spacerExtraLarge,
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BenefitRow(
                      icon: Icons.account_balance_wallet_outlined,
                      text: l10n.homeWidgetPromoBenefitBalance,
                    ),
                    _BenefitRow(
                      icon: Icons.bar_chart_rounded,
                      text: l10n.homeWidgetPromoBenefitChart,
                    ),
                    _BenefitRow(
                      icon: Icons.add_circle_outline,
                      text: l10n.homeWidgetPromoBenefitQuickAdd,
                    ),
                  ],
                ),
              ),
              AppDimens.spacerExtraLarge,
              if (!isIos && _pinSupported)
                CustomButton(
                  text: l10n.homeWidgetPromoAddCta,
                  loading: _isRequesting,
                  onPressed: _handleAddPressed,
                )
              else
                _ManualInstructions(isIos: isIos),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          AppDimens.spacerWidthMedium,
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ManualInstructions extends StatelessWidget {
  const _ManualInstructions({required this.isIos});

  final bool isIos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final steps = isIos
        ? [
            l10n.homeWidgetPromoStepIos1,
            l10n.homeWidgetPromoStepIos2,
            l10n.homeWidgetPromoStepIos3,
          ]
        : [
            l10n.homeWidgetPromoStepAndroid1,
            l10n.homeWidgetPromoStepAndroid2,
            l10n.homeWidgetPromoStepAndroid3,
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeWidgetPromoManualTitle,
          style: theme.textTheme.titleSmall,
        ),
        AppDimens.spacerMedium,
        for (var index = 0; index < steps.length; index++)
          _StepRow(number: index + 1, text: steps[index]),
        AppDimens.spacerLarge,
        CustomOutlinedButton(
          text: l10n.homeWidgetPromoGotIt,
          loading: false,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppDimens.spacerWidthMedium,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
