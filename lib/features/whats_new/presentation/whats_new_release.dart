import 'package:bicount/l10n/app_localizations.dart';

class WhatsNewRelease {
  const WhatsNewRelease({required this.id, required this.localizedEntries});

  // Assign a new, stable ID to each release announcement.
  final String id;
  final List<WhatsNewEntry> Function(AppLocalizations) localizedEntries;
}

class WhatsNewEntry {
  const WhatsNewEntry({required this.title, required this.description});

  final String title;
  final String description;
}

// Set this once the release copy is ready in both app languages.
const WhatsNewRelease? currentWhatsNewRelease = null;
