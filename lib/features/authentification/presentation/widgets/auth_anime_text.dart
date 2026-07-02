import 'package:flutter/material.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/typing_anime_text.dart';

class AuthAnimeText extends StatefulWidget {
  const AuthAnimeText({super.key});

  @override
  State<AuthAnimeText> createState() => _AuthAnimeTextState();
}

class _AuthAnimeTextState extends State<AuthAnimeText> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double dynamicFontSize = (screenWidth * 0.05).clamp(18.0, 28.0);

    final TextStyle defaultStyle = TextStyle(
      fontSize: dynamicFontSize,
      fontWeight: FontWeight.w600,
      color: Theme
          .of(context)
          .primaryColor,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(context.l10n.authUnifiedTitle, style: defaultStyle),
        const SizedBox(width: 5.0),
        TypingAnimeText(
          textStyle: defaultStyle,
          texts: [
            context.l10n.authUnifiedTitle1,
            context.l10n.authUnifiedTitle2,
            context.l10n.authUnifiedTitle3,
            context.l10n.authUnifiedTitle4,
          ],
        ),
      ],
    );
  }
}
