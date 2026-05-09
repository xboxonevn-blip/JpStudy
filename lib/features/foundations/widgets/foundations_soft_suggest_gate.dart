import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FoundationsSoftSuggestSurface { vocab, grammar, kanji }

class FoundationsSoftSuggestGate extends ConsumerStatefulWidget {
  const FoundationsSoftSuggestGate({
    super.key,
    required this.surface,
    required this.child,
  });

  final FoundationsSoftSuggestSurface surface;
  final Widget child;

  @override
  ConsumerState<FoundationsSoftSuggestGate> createState() =>
      _FoundationsSoftSuggestGateState();
}

class _FoundationsSoftSuggestGateState
    extends ConsumerState<FoundationsSoftSuggestGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybeShow());
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _maybeShow() async {
    if (_checked || !mounted) return;
    _checked = true;
    if (WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    )) {
      return;
    }
    await ref.read(foundationsProgressProvider.notifier).loadFromDao();
    final progress = ref.read(foundationsProgressProvider);
    if (progress.percentComplete >= 0.30) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'foundations.softSuggest.${widget.surface.name}.shown';
    if (prefs.getBool(key) ?? false) return;
    if (!mounted) return;

    final language = ref.read(appLanguageProvider);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(language.softSuggestFoundationsTitle),
        content: Text(language.softSuggestFoundationsBody),
        actions: [
          TextButton(
            onPressed: () async {
              await prefs.setBool(key, true);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (mounted) context.openFoundations();
            },
            child: Text(language.softSuggestGoFoundationsLabel),
          ),
          TextButton(
            onPressed: () async {
              await prefs.setBool(key, true);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: Text(language.softSuggestContinueLabel),
          ),
        ],
      ),
    );
    await prefs.setBool(key, true);
  }
}
