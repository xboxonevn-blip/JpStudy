import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

/// Visual login dialog matching the agreed design. Auth handlers are stubs
/// today (show a "coming soon" snackbar) and will be wired to the chosen
/// backend in a follow-up.
class LoginDialog extends ConsumerStatefulWidget {
  const LoginDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LoginDialog(),
    );
  }

  @override
  ConsumerState<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _comingSoon(AppLanguage language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(language.comingSoonLabel),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleEmailSubmit(AppLanguage language) {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(language.loginEmptyFieldLabel)),
      );
      return;
    }
    _comingSoon(language);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: BoxDecoration(
            color: palette.elevated,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(language, theme, palette),
              const SizedBox(height: AppSpacing.lg),
              _GoogleSignInButton(
                label: language.signInWithGoogleLabel,
                onPressed: () => _comingSoon(language),
                palette: palette,
              ),
              const SizedBox(height: AppSpacing.md),
              _OrDivider(label: language.orDividerLabel, palette: palette),
              const SizedBox(height: AppSpacing.md),
              _LoginField(
                controller: _emailController,
                label: language.loginEmailLabel,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                palette: palette,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LoginField(
                controller: _passwordController,
                label: language.loginPasswordLabel,
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                palette: palette,
                trailing: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: palette.ink.withValues(alpha: 0.55),
                    size: 20,
                  ),
                  splashRadius: 18,
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handleEmailSubmit(language),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.info,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(language.loginSubmitLabel),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                language.loginManualAccountFooterLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.ink.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppLanguage language,
    ThemeData theme,
    AppThemePalette palette,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.loginDialogTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                language.loginDialogSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.ink.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          color: palette.ink.withValues(alpha: 0.6),
          splashRadius: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.onPressed,
    required this.palette,
  });

  final String label;
  final VoidCallback onPressed;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: palette.elevated,
          foregroundColor: palette.ink,
          side: BorderSide(color: palette.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleGlyph(),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight inline "G" glyph so the dialog renders without depending on
/// google_sign_in's branded asset until the real SDK is wired in.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFFEA4335),
            Color(0xFFFBBC04),
            Color(0xFF34A853),
            Color(0xFF4285F4),
            Color(0xFFEA4335),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: const Text(
          'G',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4),
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label, required this.palette});

  final String label;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: palette.outlineSoft, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: palette.ink.withValues(alpha: 0.45),
            ),
          ),
        ),
        Expanded(child: Divider(color: palette.outlineSoft, thickness: 1)),
      ],
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.palette,
    this.obscureText = false,
    this.keyboardType,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final AppThemePalette palette;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: palette.ink, fontSize: 14),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: palette.ink.withValues(alpha: 0.45),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: palette.ink.withValues(alpha: 0.55),
          size: 20,
        ),
        suffixIcon: trailing,
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.info, width: 1.5),
        ),
      ),
    );
  }
}
