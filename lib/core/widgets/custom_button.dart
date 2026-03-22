import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/icon_links.dart';
import '../themes/app_dimens.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.loading,
  });
  final VoidCallback onPressed;
  final WidgetStatesController statesController = WidgetStatesController();
  final String text;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? LoadingAnimationWidget.horizontalRotatingDots(
                color: Theme.of(context).cardColor,
                size: 50,
              )
            : Text(text),
      ),
    );
  }
}

class CustomGoogleAuthButton extends StatelessWidget {

  final bool isLogin;
  final bool isLoading;
  final VoidCallback onPressed;
  const CustomGoogleAuthButton({
    super.key,
    this.isLogin = false,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? LoadingAnimationWidget.horizontalRotatingDots(
          color: Theme.of(context).cardColor,
          size: 50,
        )
            : Row(
          key: const ValueKey('content'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(IconLinks.googleIcon),
            ),
            AppDimens.spacerWidthMedium,
            Flexible(
              child: Text(
                isLogin
                    ? 'Continue with Google'
                    : 'Create a Google account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

