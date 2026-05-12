import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../core/app_language.dart';
import '../core/language_provider.dart';
import 'database_reset_native.dart'
    if (dart.library.js_interop) 'database_reset_web.dart'
    as reset_impl;

class DatabaseResetDialog extends ConsumerWidget {
  const DatabaseResetDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const DatabaseResetDialog(),
    );
  }

  static Future<bool> resetDatabase() async {
    if (kIsWeb) {
      return false;
    }
    return reset_impl.resetDatabaseFiles();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;

    return AlertDialog(
      title: Text(language.databaseResetTitle),
      content: Text(
        kIsWeb
            ? language.databaseResetWebMessage
            : language.databaseResetWarningMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(language.cancelLabel),
        ),
        if (!kIsWeb)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: palette.error),
            onPressed: () async {
              final success = await resetDatabase();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? language.databaseResetSuccessMessage
                          : language.databaseResetMissingMessage,
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            child: Text(language.deleteAllDataLabel),
          ),
      ],
    );
  }
}
