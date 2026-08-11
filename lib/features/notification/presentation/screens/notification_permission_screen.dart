import 'package:bicount/core/constants/animation_file_path.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.primaryReason,
    required this.enableLabel,
    required this.skipLabel,
    required this.onEnablePressed,
    this.otherReasonsTitle,
    this.otherReasons = const [],
  });

  final IconData icon;
  final String title;
  final String primaryReason;
  final String enableLabel;
  final String skipLabel;
  final String? otherReasonsTitle;
  final List<String> otherReasons;

  /// Triggers the OS permission request and resolves once the user has
  /// made their choice in the native system dialog. This screen only
  /// closes after that resolves, so it stays visible for as long as the
  /// system dialog is up instead of closing before the user has decided.
  final Future<bool> Function() onEnablePressed;

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _isRequestingOsPermission = false;

  Future<void> _handleEnablePressed() async {
    setState(() => _isRequestingOsPermission = true);
    final granted = await widget.onEnablePressed();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(granted);
  }

  void _handleSkipPressed() {
    if (_isRequestingOsPermission) {
      return;
    }
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.paddingAllMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: DotLottieView(
                          sourceType: 'asset',
                          source: AnimationFilePath.notification,
                          autoplay: true,
                          loop: true,
                          mode: 'bounce',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: theme.textTheme.headlineSmall!.fontSize!,
                            height: theme.textTheme.headlineSmall!.fontSize!,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              size: theme.textTheme.headlineSmall!.fontSize!,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          AppDimens.spacerWidthMedium,
                          Flexible(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      AppDimens.spacerMedium,
                      Container(
                        width: double.infinity,
                        padding: AppDimens.paddingAllMedium,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadiusMedium,
                          ),
                        ),
                        child: Text(
                          widget.primaryReason,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.otherReasonsTitle != null &&
                          widget.otherReasons.isNotEmpty) ...[
                        AppDimens.spacerExtraLarge,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.otherReasonsTitle!,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        AppDimens.spacerMediumSmall,
                        ...widget.otherReasons.map(
                          (reason) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: AppDimens.iconSizeSmall,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                AppDimens.spacerWidthSmall,
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              AppDimens.spacerMedium,
              CustomButton(
                text: widget.enableLabel,
                loading: _isRequestingOsPermission,
                onPressed: _handleEnablePressed,
              ),
              AppDimens.spacerSmall,
              CustomOutlinedButton(
                text: widget.skipLabel,
                loading: false,
                onPressed: _handleSkipPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
