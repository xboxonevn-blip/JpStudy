import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// A reusable error state widget for AsyncValue.when(error:) handlers.
///
/// Shows an error icon, message, and optional retry button.
/// Use instead of empty `Container()` or `SizedBox.shrink()` in error states.
class ErrorStateWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final message = customMessage ?? _friendlyMessage(error);
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
              color: const Color(0xFFFEE2E2),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: iconSize,
              color: const Color(0xFFEF4444),
            ),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
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

  String _friendlyMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'No internet connection. Please try again.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
