import 'dart:async';

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/whats_new/data/repositories/whats_new_repository_impl.dart';
import 'package:bicount/features/whats_new/domain/repositories/whats_new_repository.dart';
import 'package:bicount/features/whats_new/presentation/whats_new_release.dart';
import 'package:bicount/features/whats_new/presentation/widgets/whats_new_dialog.dart';
import 'package:flutter/material.dart';

class WhatsNewPrompt extends StatefulWidget {
  const WhatsNewPrompt({
    super.key,
    required this.enabled,
    required this.child,
    this.release = currentWhatsNewRelease,
    this.repository = const WhatsNewRepositoryImpl(),
  });

  final bool enabled;
  final Widget child;
  final WhatsNewRelease? release;
  final WhatsNewRepository repository;

  @override
  State<WhatsNewPrompt> createState() => _WhatsNewPromptState();
}

class _WhatsNewPromptState extends State<WhatsNewPrompt> {
  bool _checking = false;
  String? _handledReleaseId;

  @override
  Widget build(BuildContext context) {
    final release = widget.release;
    if (release != null &&
        widget.enabled &&
        ModalRoute.isCurrentOf(context) == true &&
        !_checking &&
        _handledReleaseId != release.id) {
      _checking = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_showIfNeeded(release));
      });
    }
    return widget.child;
  }

  Future<void> _showIfNeeded(WhatsNewRelease release) async {
    final repository = widget.repository;
    try {
      if (await repository.wasDismissed(release.id)) {
        _handledReleaseId = release.id;
        return;
      }
      if (!mounted ||
          !widget.enabled ||
          widget.release?.id != release.id ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }

      if (release.localizedEntries(context.l10n).isEmpty) {
        _handledReleaseId = release.id;
        return;
      }
      final dismissed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WhatsNewDialog(release: release),
      );
      if (dismissed == true) {
        _handledReleaseId = release.id;
        await repository.markDismissed(release.id);
      }
    } catch (error) {
      debugPrint('Could not load or save the release announcement: $error');
    } finally {
      _checking = false;
    }
  }
}
