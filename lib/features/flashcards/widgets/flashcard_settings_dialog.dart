import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

import '../models/flashcard_settings.dart';

class FlashcardSettingsDialog extends ConsumerStatefulWidget {
  final FlashcardSettings currentSettings;
  final Function(FlashcardSettings) onSave;

  const FlashcardSettingsDialog({
    super.key,
    required this.currentSettings,
    required this.onSave,
  });

  @override
  ConsumerState<FlashcardSettingsDialog> createState() =>
      _FlashcardSettingsDialogState();
}

class _FlashcardSettingsDialogState extends ConsumerState<FlashcardSettingsDialog> {
  late FlashcardSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings_rounded, color: context.appPalette.primary),
          const SizedBox(width: 12),
          Text(ref.watch(appLanguageProvider).flashcardSettingsTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSwitch(
              title: 'Show Term First',
              subtitle: 'Display Japanese term on front of card',
              value: _settings.showTermFirst,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showTermFirst: value);
                });
              },
            ),
            const Divider(),
            _buildSwitch(
              title: 'Enable Swipe Gestures',
              subtitle: 'Swipe to mark cards as known/need practice',
              value: _settings.enableSwipeGestures,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(enableSwipeGestures: value);
                });
              },
            ),
            const Divider(),
            _buildSwitch(
              title: 'Show Starred Only',
              subtitle: 'Only show bookmarked terms',
              value: _settings.showOnlyStarred,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showOnlyStarred: value);
                });
              },
            ),
            const Divider(),
            _buildSwitch(
              title: 'Shuffle Cards',
              subtitle: 'Randomize card order',
              value: _settings.shuffleCards,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(shuffleCards: value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(ref.watch(appLanguageProvider).cancelLabel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_settings);
            Navigator.of(context).pop();
          },
          child: Text(ref.watch(appLanguageProvider).saveLabel),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: context.appPalette.ink.withValues(alpha: 0.55)),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// Helper function to show dialog
Future<void> showFlashcardSettingsDialog(
  BuildContext context, {
  required FlashcardSettings currentSettings,
  required Function(FlashcardSettings) onSave,
}) {
  return showDialog(
    context: context,
    builder: (context) => FlashcardSettingsDialog(
      currentSettings: currentSettings,
      onSave: onSave,
    ),
  );
}
