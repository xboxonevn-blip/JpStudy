import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: Icons.forum_rounded,
              title: _heroTitle(language),
              subtitle: _heroSubtitle(language),
              primaryLabel: _profileLabel(language),
              onPrimaryTap: () => context.openMe(),
              secondaryLabel: _dataLabel(language),
              onSecondaryTap: () => context.openMeData(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _shortcutsLabel(language),
                    caption: _shortcutsCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final item in _shortcuts(language)) ...[
                    AppCompactRow(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      status: item.status == null
                          ? null
                          : AppStatusChip(label: item.status!, tone: item.tone),
                      onTap: () => item.onTap(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 820;
                final roadmap = _RoadmapCard(language: language);
                final metrics = _CommunityMetaCard(language: language);
                if (stacked) {
                  return Column(
                    children: [
                      roadmap,
                      const SizedBox(height: AppSpacing.md),
                      metrics,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: roadmap),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 2, child: metrics),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _connectTitle(language),
                    caption: _connectCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final item in _connectItems(language)) ...[
                    AppCompactRow(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      status: AppStatusChip(
                        label: item.status,
                        tone: item.tone,
                      ),
                      onTap: () => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(item.feedback))),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _roadmapTitle(language),
            caption: _roadmapCaption(language),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in _roadmapItems(language)) ...[
            AppCompactRow(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              status: AppStatusChip(label: item.status, tone: item.tone),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _CommunityMetaCard extends StatelessWidget {
  const _CommunityMetaCard({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _metaTitle(language),
            caption: _metaCaption(language),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppMetricPill(label: _versionLabel(language), value: 'v2'),
              AppMetricPill(
                label: _focusLabel(language),
                value: _focusValue(language),
              ),
              AppMetricPill(
                label: _modeLabel(language),
                value: _modeValue(language),
              ),
              AppMetricPill(
                label: _feedbackLabel(language),
                value: _feedbackValue(language),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<_ShortcutItem> _shortcuts(AppLanguage language) => [
  _ShortcutItem(
    Icons.person_rounded,
    _profileTitle(language),
    _profileSubtitle(language),
    (context) => context.openMe(),
  ),
  _ShortcutItem(
    Icons.storage_rounded,
    _storageTitle(language),
    _storageSubtitle(language),
    (context) => context.openMeData(),
  ),
  _ShortcutItem(
    Icons.palette_rounded,
    _designLabTitle(language),
    _designLabSubtitle(language),
    (context) => context.openDesignLab(),
    status: _labStatus(language),
    tone: AppStatusTone.neutral,
  ),
];

List<_RoadmapItem> _roadmapItems(AppLanguage language) => switch (language) {
  AppLanguage.en => const [
    _RoadmapItem(
      Icons.check_circle_rounded,
      'Shell and navigation refresh',
      'Completed foundation for the 10-section information architecture.',
      'Done',
      AppStatusTone.success,
    ),
    _RoadmapItem(
      Icons.draw_rounded,
      'Kanji workspace and radicals',
      'Expanded study-first kanji experience with draw search and 214 radicals.',
      'Live',
      AppStatusTone.primary,
    ),
    _RoadmapItem(
      Icons.groups_rounded,
      'Community loops',
      'Invite cards, challenge rooms, and social proof surfaces are next.',
      'Next',
      AppStatusTone.warning,
    ),
  ],
  AppLanguage.vi => const [
    _RoadmapItem(
      Icons.check_circle_rounded,
      'Làm mới shell và điều hướng',
      'Đã hoàn thành nền tảng cho kiến trúc thông tin 10 mục.',
      'Xong',
      AppStatusTone.success,
    ),
    _RoadmapItem(
      Icons.draw_rounded,
      'Workspace Kanji và bộ thủ',
      'Mở rộng trải nghiệm học kanji với draw search và 214 bộ thủ.',
      'Đang chạy',
      AppStatusTone.primary,
    ),
    _RoadmapItem(
      Icons.groups_rounded,
      'Vòng lặp cộng đồng',
      'Invite card, challenge room và social proof là bước tiếp theo.',
      'Tiếp theo',
      AppStatusTone.warning,
    ),
  ],
  AppLanguage.ja => const [
    _RoadmapItem(
      Icons.check_circle_rounded,
      'shell と navigation の刷新',
      '10セクション情報設計の土台を完了しました。',
      '完了',
      AppStatusTone.success,
    ),
    _RoadmapItem(
      Icons.draw_rounded,
      'Kanji workspace と部首',
      'draw search と 214 部首で kanji 体験を広げました。',
      '稼働中',
      AppStatusTone.primary,
    ),
    _RoadmapItem(
      Icons.groups_rounded,
      'community loop',
      'invite card、challenge room、social proof が次です。',
      '次',
      AppStatusTone.warning,
    ),
  ],
};

List<_ConnectItem> _connectItems(AppLanguage language) => switch (language) {
  AppLanguage.en => const [
    _ConnectItem(
      Icons.feedback_rounded,
      'Send feedback',
      'Bundle UX notes, bug reports, and feature requests in one surface.',
      'Open',
      AppStatusTone.success,
      'Feedback intake will be wired to a real channel later.',
    ),
    _ConnectItem(
      Icons.campaign_rounded,
      'Invite a friend',
      'Prepare a lightweight referral path without changing the app shell.',
      'Soon',
      AppStatusTone.warning,
      'Referral flow is still local placeholder content.',
    ),
    _ConnectItem(
      Icons.groups_rounded,
      'Community room',
      'Reserve a future home for live learners, sprint rooms, and announcements.',
      'Planned',
      AppStatusTone.neutral,
      'Community links will be enabled in a later release.',
    ),
  ],
  AppLanguage.vi => const [
    _ConnectItem(
      Icons.feedback_rounded,
      'Gửi phản hồi',
      'Gom góp ý UX, bug report và feature request vào một chỗ.',
      'Mở',
      AppStatusTone.success,
      'Kênh nhận phản hồi thật sẽ được nối sau.',
    ),
    _ConnectItem(
      Icons.campaign_rounded,
      'Mời bạn bè',
      'Chuẩn bị lối giới thiệu nhẹ mà không đổi app shell.',
      'Sớm',
      AppStatusTone.warning,
      'Flow giới thiệu hiện vẫn là placeholder local.',
    ),
    _ConnectItem(
      Icons.groups_rounded,
      'Phòng cộng đồng',
      'Chừa sẵn nơi cho người học trực tiếp, sprint room và thông báo.',
      'Kế hoạch',
      AppStatusTone.neutral,
      'Link cộng đồng sẽ được bật ở bản sau.',
    ),
  ],
  AppLanguage.ja => const [
    _ConnectItem(
      Icons.feedback_rounded,
      'フィードバック送信',
      'UX メモ、bug report、feature request を1か所にまとめます。',
      '受付中',
      AppStatusTone.success,
      'feedback 導線は後で実チャネルへ接続します。',
    ),
    _ConnectItem(
      Icons.campaign_rounded,
      '友達を招待',
      'app shell を変えずに紹介導線を準備します。',
      '近日',
      AppStatusTone.warning,
      '紹介 flow はまだローカル placeholder です。',
    ),
    _ConnectItem(
      Icons.groups_rounded,
      'コミュニティルーム',
      '学習者の live room、sprint room、announcement の居場所を確保します。',
      '予定',
      AppStatusTone.neutral,
      'community link は後続リリースで有効になります。',
    ),
  ],
};

String _title(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Community & Settings',
  AppLanguage.vi => 'Giới thiệu & Cộng đồng',
  AppLanguage.ja => '紹介・コミュニティ',
};
String _heroTitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'One calm place for profile, settings, and community touchpoints',
  AppLanguage.vi => 'Một nơi gọn cho hồ sơ, cài đặt và các điểm chạm cộng đồng',
  AppLanguage.ja => 'プロフィール・設定・community 導線を1か所にまとめる',
};
String _heroSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'This screen now works like a real control center instead of only being a list of links.',
  AppLanguage.vi =>
    'Màn này giờ hoạt động như một control center thật thay vì chỉ là danh sách link.',
  AppLanguage.ja => '単なるリンク一覧ではなく、実際の control center として機能する構成にしました。',
};
String _profileLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open profile',
  AppLanguage.vi => 'Mở hồ sơ',
  AppLanguage.ja => 'プロフィールを開く',
};
String _dataLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Data tools',
  AppLanguage.vi => 'Công cụ dữ liệu',
  AppLanguage.ja => 'データツール',
};
String _shortcutsLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Core shortcuts',
  AppLanguage.vi => 'Lối tắt chính',
  AppLanguage.ja => '主要ショートカット',
};
String _shortcutsCaption(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Keep the most useful owner-facing tools together.',
  AppLanguage.vi => 'Gom các công cụ chủ app dùng nhiều nhất vào một chỗ.',
  AppLanguage.ja => 'オーナー向けツールを使いやすくひとまとめにします。',
};
String _profileTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Profile and history',
  AppLanguage.vi => 'Hồ sơ và lịch sử',
  AppLanguage.ja => 'プロフィールと履歴',
};
String _profileSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Review progress snapshots, challenges, and personal bests.',
  AppLanguage.vi => 'Xem snapshot tiến độ, challenge và thành tích cá nhân.',
  AppLanguage.ja => '進捗、challenge、自己ベストを確認します。',
};
String _storageTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Data and resets',
  AppLanguage.vi => 'Dữ liệu và reset',
  AppLanguage.ja => 'データとリセット',
};
String _storageSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Manage backups, imports, and local study data safely.',
  AppLanguage.vi => 'Quản lý backup, import và dữ liệu local an toàn.',
  AppLanguage.ja => 'backup、import、ローカル学習データを安全に管理します。',
};
String _designLabTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Design lab',
  AppLanguage.vi => 'Phòng thí nghiệm UI',
  AppLanguage.ja => 'デザインラボ',
};
String _designLabSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Inspect visual experiments and keep the app style coherent.',
  AppLanguage.vi => 'Xem thử nghiệm giao diện và giữ style app đồng nhất.',
  AppLanguage.ja => '見た目の実験を確認し、アプリの一貫性を保ちます。',
};
String _labStatus(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Internal',
  AppLanguage.vi => 'Nội bộ',
  AppLanguage.ja => '内部',
};
String _roadmapTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'JP Study flow roadmap',
  AppLanguage.vi => 'Lộ trình JP Study flow',
  AppLanguage.ja => 'JP Studyフローロードマップ',
};
String _roadmapCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Short product roadmap so this page feels like a living hub.',
  AppLanguage.vi =>
    'Roadmap ngắn để trang này có cảm giác là một hub đang sống.',
  AppLanguage.ja => 'このページが生きた hub に見えるよう短い roadmap を置いています。',
};
String _metaTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'App meta',
  AppLanguage.vi => 'Thông tin app',
  AppLanguage.ja => 'アプリ情報',
};
String _metaCaption(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Light metadata blocks instead of dead empty space.',
  AppLanguage.vi => 'Các block metadata nhẹ thay cho khoảng trống vô nghĩa.',
  AppLanguage.ja => '空白を減らすための軽い metadata block です。',
};
String _versionLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Version',
  AppLanguage.vi => 'Phiên bản',
  AppLanguage.ja => 'バージョン',
};
String _focusLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Focus',
  AppLanguage.vi => 'Trọng tâm',
  AppLanguage.ja => 'フォーカス',
};
String _focusValue(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Daily Japanese',
  AppLanguage.vi => 'Nhật ngữ hằng ngày',
  AppLanguage.ja => '毎日の日本語',
};
String _modeLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Mode',
  AppLanguage.vi => 'Chế độ',
  AppLanguage.ja => 'モード',
};
String _modeValue(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Personal study',
  AppLanguage.vi => 'Tự học cá nhân',
  AppLanguage.ja => '個人学習',
};
String _feedbackLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Feedback',
  AppLanguage.vi => 'Phản hồi',
  AppLanguage.ja => 'フィードバック',
};
String _feedbackValue(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Curated inbox',
  AppLanguage.vi => 'Inbox chọn lọc',
  AppLanguage.ja => 'curated inbox',
};
String _connectTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Community touchpoints',
  AppLanguage.vi => 'Điểm chạm cộng đồng',
  AppLanguage.ja => 'community 導線',
};
String _connectCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Prepared surfaces for feedback, referrals, and future social loops.',
  AppLanguage.vi =>
    'Các bề mặt được chuẩn bị cho feedback, referral và social loop sau này.',
  AppLanguage.ja => 'feedback、referral、将来の social loop 向けの準備済み surface です。',
};

class _ShortcutItem {
  const _ShortcutItem(
    this.icon,
    this.title,
    this.subtitle,
    this.onTap, {
    this.status,
    this.tone = AppStatusTone.neutral,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onTap;
  final String? status;
  final AppStatusTone tone;
}

class _RoadmapItem {
  const _RoadmapItem(
    this.icon,
    this.title,
    this.subtitle,
    this.status,
    this.tone,
  );

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppStatusTone tone;
}

class _ConnectItem {
  const _ConnectItem(
    this.icon,
    this.title,
    this.subtitle,
    this.status,
    this.tone,
    this.feedback,
  );

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppStatusTone tone;
  final String feedback;
}
