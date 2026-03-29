import 'package:bicount/core/constants/app_config.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthLegalLinks extends StatelessWidget {
  const AuthLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final linkStyle = style?.copyWith(
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 0,
      children: [
        Text(context.l10n.authLegalByContinuing, style: style),
        _InlineLink(
          label: context.l10n.authConsumerTerms,
          style: linkStyle,
          url: AppConfig.consumerTermsUrl,
        ),
        Text(context.l10n.authLegalAnd, style: style),
        _InlineLink(
          label: context.l10n.authUsagePolicy,
          style: linkStyle,
          url: AppConfig.usagePolicyUrl,
        ),
        Text(context.l10n.authLegalAcknowledge, style: style),
        _InlineLink(
          label: context.l10n.authPrivacyPolicy,
          style: linkStyle,
          url: AppConfig.privacyPolicyUrl,
        ),
      ],
    );
  }
}

class _InlineLink extends StatelessWidget {
  const _InlineLink({
    required this.label,
    required this.style,
    required this.url,
  });

  final String label;
  final TextStyle? style;
  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _open(url),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(label, style: style),
    );
  }

  Future<void> _open(String rawUrl) async {
    final uri = Uri.parse(rawUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
