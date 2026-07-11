import 'package:url_launcher/url_launcher.dart';

Future<void> open(String rawUrl) async {
  final uri = Uri.parse(rawUrl);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
