import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import: only used on non-web platforms
import 'database_reset_native.dart' if (dart.library.js_interop) 'database_reset_web.dart' as reset_impl;

/// Reset Database Utility Widget
/// Call this from Settings or Debug menu
class DatabaseResetDialog extends StatelessWidget {
  const DatabaseResetDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const DatabaseResetDialog(),
    );
  }

  static Future<bool> resetDatabase() async {
    if (kIsWeb) {
      // On web, we can't delete files. Show message to clear browser storage.
      return false;
    }
    return reset_impl.resetDatabaseFiles();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Database'),
      content: Text(
        kIsWeb
            ? 'On web, please clear your browser\'s site data to reset the database.'
            : 'This will DELETE ALL your progress, including:\n'
                '• Learned terms\n'
                '• SRS review data\n'
                '• Custom term edits\n'
                '• Stars and bookmarks\n\n'
                'The app will restart with fresh data.\n\n'
                'Are you sure?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!kIsWeb)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await resetDatabase();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '✅ Database reset! Please restart the app.'
                          : '⚠️ Database not found or already deleted.',
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            child: const Text('Delete All Data'),
          ),
      ],
    );
  }
}
