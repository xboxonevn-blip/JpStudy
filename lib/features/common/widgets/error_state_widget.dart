import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';

class ErrorStateWidget extends ConsumerWidget {
  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;
    final message = customMessage ?? _friendlyMessage(language, error);
    final double iconSize = compact ? 28 : 40;
    final double titleSize = compact ? 12 : 14;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl,
            vertical: AppSpacing.xxl,
          );

    return Semantics(
      liveRegion: true,
      label: message,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 44 : 64,
              height: compact ? 44 : 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.error.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: iconSize,
                color: palette.error,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: palette.ink.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(language.retryLabel),
                style: TextButton.styleFrom(
                  foregroundColor: palette.info,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _friendlyMessage(AppLanguage language, Object error) {
    final message = error.toString();
    if (message.contains('SocketException') || message.contains('Connection')) {
      return language.noInternetErrorLabel;
    }
    if (message.contains('TimeoutException')) {
      return language.timeoutErrorLabel;
    }
    return language.genericErrorLabel;
  }
}
