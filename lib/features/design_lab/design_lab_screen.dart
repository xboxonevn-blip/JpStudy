import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

enum LabStage { discover, visual, validate }

class DesignLabScreen extends ConsumerStatefulWidget {
  const DesignLabScreen({super.key});

  @override
  ConsumerState<DesignLabScreen> createState() => _DesignLabScreenState();
}

class _DesignLabScreenState extends ConsumerState<DesignLabScreen> {
  LabStage _stage = LabStage.discover;
  final Set<int> _checkedTaskIds = {1, 2};

  String _tr(AppLanguage language, String en, String vi, String ja) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr(language, 'Design Lab', 'Phòng thí nghiệm thiết kế', 'デザインラボ')),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FAFF), Color(0xFFF3F6FF), Color(0xFFEFFBFF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 920;
              final content = <Widget>[
                _heroCard(context, language),
                const SizedBox(height: 16),
                _stageSwitch(context, language),
                const SizedBox(height: 16),
                _stageCanvas(context, language),
                const SizedBox(height: 16),
                _progressChecklist(context, language),
              ];

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: content.sublist(0, 3),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                        children: content.sublist(3),
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: content,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [palette.ink, const Color(0xFF1E3A8A)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(language, 'Live UI/UX Workflow', 'Quy trình UI/UX trực tiếp', 'ライブ UI/UX ワークフロー'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _tr(
              language,
              'Use this screen to review wireframe -> visual -> validation flow before shipping a real screen.',
              'Dùng màn hình này để rà luồng wireframe -> visual -> validation trước khi đưa màn hình thật vào app.',
              'この画面で wireframe -> visual -> validation の流れを確認してから本番画面へ反映します。',
            ),
            style: const TextStyle(color: Color(0xFFD9E7FF), height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _stageSwitch(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(language, 'Current Stage', 'Giai đoạn hiện tại', '現在のステージ'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SegmentedButton<LabStage>(
            segments: [
              ButtonSegment(
                value: LabStage.discover,
                icon: Icon(Icons.grid_view_rounded),
                label: Text(_tr(language, 'Discover', 'Khám phá', '発見')),
              ),
              ButtonSegment(
                value: LabStage.visual,
                icon: Icon(Icons.palette_outlined),
                label: Text(_tr(language, 'Visual', 'Hình ảnh', 'ビジュアル')),
              ),
              ButtonSegment(
                value: LabStage.validate,
                icon: Icon(Icons.task_alt_outlined),
                label: Text(_tr(language, 'Validate', 'Kiểm tra', '検証')),
              ),
            ],
            selected: {_stage},
            onSelectionChanged: (value) {
              setState(() => _stage = value.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _stageCanvas(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    switch (_stage) {
      case LabStage.discover:
        return _panel(
          context: context,
          title: _tr(language, 'Wireframe Snapshot', 'Ảnh chụp wireframe', 'ワイヤーフレームのスナップショット'),
          subtitle: _tr(language, 'Block-level layout before visual polish.', 'Bố cục ở mức khối trước khi polish giao diện.', 'ビジュアル調整前のブロックレベルのレイアウトです。'),
          child: Column(
            children: [
              _skeletonBlock(context, height: 36),
              const SizedBox(height: 12),
              _skeletonBlock(context, height: 92),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _skeletonBlock(context, height: 110)),
                  const SizedBox(width: 12),
                  Expanded(child: _skeletonBlock(context, height: 110)),
                ],
              ),
            ],
          ),
        );
      case LabStage.visual:
        return _panel(
          context: context,
          title: _tr(language, 'Visual Direction', 'Định hướng hình ảnh', 'ビジュアル方針'),
          subtitle: _tr(language, 'Color, spacing, and card rhythm review.', 'Rà màu sắc, khoảng cách và nhịp điệu thẻ.', '色・余白・カードのリズムを確認します。'),
          child: Column(
            children: [
              Container(
                height: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEDD5), Color(0xFFFDE68A)],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _swatchCard(_tr(language, 'Primary', 'Chính', 'メイン'), palette.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _swatchCard(_tr(language, 'Accent', 'Nhấn', 'アクセント'), palette.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _swatchCard(_tr(language, 'Neutral', 'Trung tính', 'ニュートラル'), palette.ink),
                  ),
                ],
              ),
            ],
          ),
        );
      case LabStage.validate:
        return _panel(
          context: context,
          title: _tr(language, 'Validation Notes', 'Ghi chú kiểm tra', '検証メモ'),
          subtitle: _tr(language, 'Quick quality readout before merge.', 'Tóm tắt chất lượng nhanh trước khi merge.', 'マージ前の品質チェックを素早く確認します。'),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(label: _tr(language, 'Tap targets >= 44px', 'Vùng chạm >= 44px', 'タップ領域 >= 44px'), ok: true),
              _MetricChip(label: _tr(language, 'Text contrast pass', 'Độ tương phản chữ đạt', '文字コントラスト合格'), ok: true),
              _MetricChip(label: _tr(language, 'Scroll behavior checked', 'Đã kiểm tra cuộn', 'スクロール挙動確認済み'), ok: true),
              _MetricChip(label: _tr(language, 'Animation intensity reviewed', 'Đã rà cường độ animation', 'アニメーション強度を確認済み'), ok: false),
              _MetricChip(label: _tr(language, 'QA walkthrough pass', 'Walkthrough QA đạt', 'QA ウォークスルー合格'), ok: false),
            ],
          ),
        );
    }
  }

  Widget _progressChecklist(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    final tasks = [
      (1, _tr(language, 'Wireframe approved in team review', 'Wireframe đã được duyệt trong buổi review', 'ワイヤーフレームがレビューで承認済み')),
      (2, _tr(language, 'Visual style tokenized (color/spacing/type)', 'Visual style đã token hóa (màu/khoảng cách/chữ)', 'ビジュアルスタイルをトークン化済み（色・余白・文字）')),
      (3, _tr(language, 'Prototype tested on desktop + mobile', 'Prototype đã test trên desktop + mobile', 'プロトタイプを desktop + mobile で確認済み')),
      (4, _tr(language, 'Feedback log written in docs/uiux-progress.md', 'Đã ghi log phản hồi trong docs/uiux-progress.md', 'docs/uiux-progress.md にフィードバックを記録済み')),
      (5, _tr(language, 'Ready for handoff to production screen', 'Sẵn sàng bàn giao sang màn hình production', '本番画面への引き継ぎ準備完了')),
    ];
    return _panel(
      context: context,
      title: _tr(language, 'Process Checklist', 'Checklist quy trình', 'プロセスチェックリスト'),
      subtitle: _tr(language, 'Track each iteration in one place.', 'Theo dõi từng iteration ở một nơi.', '各イテレーションを一箇所で管理します。'),
      child: Column(
        children: [
          for (final (id, label) in tasks)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checkedTaskIds.contains(id),
              title: Text(label),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _checkedTaskIds.add(id);
                  } else {
                    _checkedTaskIds.remove(id);
                  }
                });
              },
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _tr(language, 'Next: update docs/uiux-progress.md and docs/uiux-review-checklist.md', 'Tiếp theo: cập nhật docs/uiux-progress.md và docs/uiux-review-checklist.md', '次: docs/uiux-progress.md と docs/uiux-review-checklist.md を更新'),
              style: TextStyle(
                color: palette.ink.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: palette.ink.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _skeletonBlock(BuildContext context, {required double height}) {
    final palette = context.appPalette;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _swatchCard(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final bg = ok ? palette.success.withValues(alpha: 0.18) : palette.error.withValues(alpha: 0.1);
    final fg = ok ? palette.success : palette.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
