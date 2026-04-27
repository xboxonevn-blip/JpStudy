import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int _selectedPlan = 1;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final plans = _plans(language);
    final selected = plans[_selectedPlan];

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: Icons.diamond_rounded,
              title: _heroTitle(language),
              subtitle: _heroSubtitle(language),
              status: AppStatusChip(
                label: _saveBadge(language, selected.badge),
                tone: AppStatusTone.primary,
              ),
              primaryLabel: _upgradeLabel(language),
              onPrimaryTap: () => _snack(context, _checkoutSoon(language, selected.name)),
              secondaryLabel: _compareLabel(language),
              onSecondaryTap: () {},
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _plansTitle(language),
                    caption: _plansCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (var index = 0; index < plans.length; index++)
                        ChoiceChip(
                          label: Text(plans[index].name),
                          selected: _selectedPlan == index,
                          onSelected: (_) => setState(() => _selectedPlan = index),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth > 760;
                      final children = [
                        _PlanSummaryCard(plan: selected, language: language),
                        _BenefitSummaryCard(plan: selected, language: language),
                      ];
                      if (!twoColumns) {
                        return Column(
                          children: [
                            for (final child in children) ...[
                              child,
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: children[0]),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: children[1]),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: _featureTitle(language),
              caption: _featureCaption(language),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in _features(language)) ...[
              AppCompactRow(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                status: AppStatusChip(label: item.status, tone: item.tone),
                onTap: () => _snack(context, item.subtitle),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _compareMatrixTitle(language),
                    caption: _compareMatrixCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final row in _matrix(language, selected)) ...[
                    AppCompactRow(
                      icon: row.icon,
                      title: row.title,
                      subtitle: row.subtitle,
                      status: AppStatusChip(label: row.status, tone: row.tone),
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

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.plan, required this.language});

  final _PlanItem plan;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: plan.name,
            caption: plan.price,
            actionLabel: _ctaLabel(language),
            onActionTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_checkoutSoon(language, plan.name))),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          for (final point in plan.points) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(point)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _BenefitSummaryCard extends StatelessWidget {
  const _BenefitSummaryCard({required this.plan, required this.language});

  final _PlanItem plan;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _fitTitle(language),
            caption: _fitCaption(language, plan.fit),
          ),
          const SizedBox(height: AppSpacing.md),
          AppMetricPill(label: _trialLabel(language), value: plan.trial),
          const SizedBox(height: AppSpacing.sm),
          AppMetricPill(label: _billingLabel(language), value: plan.billing),
          const SizedBox(height: AppSpacing.lg),
          AppProgressStrip(value: plan.valueScore, label: _valueLabel(language)),
          const SizedBox(height: AppSpacing.md),
          AppProgressStrip(
            value: plan.intensityScore,
            label: _intensityLabel(language),
          ),
        ],
      ),
    );
  }
}

List<_PremiumFeature> _features(AppLanguage language) => switch (language) {
      AppLanguage.en => const [
          _PremiumFeature(Icons.library_books_rounded, 'Full reading library', 'Unlock longer reading sets, guided comprehension, and richer sample banks.', 'Content', AppStatusTone.primary),
          _PremiumFeature(Icons.insights_rounded, 'Advanced analytics', 'See weekly weak-point trends, retention breakdowns, and coach-style recovery ideas.', 'Insight', AppStatusTone.success),
          _PremiumFeature(Icons.fact_check_rounded, 'Unlimited mock exams', 'Run exam prep blocks without soft caps and keep retry history longer.', 'Exam', AppStatusTone.warning),
          _PremiumFeature(Icons.offline_bolt_rounded, 'Offline packs', 'Keep focused study bundles ready for commute sessions and low-connection time.', 'New', AppStatusTone.neutral),
        ],
      AppLanguage.vi => const [
          _PremiumFeature(Icons.library_books_rounded, 'Thư viện đọc đầy đủ', 'Mở khóa bài đọc dài hơn, hướng dẫn hiểu bài và ngân hàng mẫu phong phú hơn.', 'Nội dung', AppStatusTone.primary),
          _PremiumFeature(Icons.insights_rounded, 'Phân tích nâng cao', 'Xem xu hướng điểm yếu theo tuần, retention và gợi ý phục hồi kiểu coach.', 'Insight', AppStatusTone.success),
          _PremiumFeature(Icons.fact_check_rounded, 'Thi thử không giới hạn', 'Chạy block luyện thi không bị soft cap và giữ lịch sử retry lâu hơn.', 'Thi cử', AppStatusTone.warning),
          _PremiumFeature(Icons.offline_bolt_rounded, 'Gói offline', 'Giữ sẵn các bundle tập trung cho lúc di chuyển hoặc mạng yếu.', 'Mới', AppStatusTone.neutral),
        ],
      AppLanguage.ja => const [
          _PremiumFeature(Icons.library_books_rounded, '読解ライブラリ拡張', '長文セット、理解ガイド、サンプルバンクをより豊かに使えます。', 'コンテンツ', AppStatusTone.primary),
          _PremiumFeature(Icons.insights_rounded, '高度な分析', '週間の弱点傾向、保持率、回復のヒントを確認できます。', '分析', AppStatusTone.success),
          _PremiumFeature(Icons.fact_check_rounded, '模試回数無制限', '模試ブロックを上限なく回し、再挑戦履歴も長く残せます。', '試験', AppStatusTone.warning),
          _PremiumFeature(Icons.offline_bolt_rounded, 'オフラインパック', '通学や通信不安定な時間向けに集中パックを保持します。', '新着', AppStatusTone.neutral),
        ],
    };

List<_PlanItem> _plans(AppLanguage language) => switch (language) {
      AppLanguage.en => const [
          _PlanItem('Starter', '4.99 / mo', '7 days', 'Monthly billing', 'Light', 0.58, 0.38, 'Best for trying premium after your daily streak is stable.', 0, [
            'Long-form reading and premium sample decks',
            'Exam retries with longer history',
            'Basic analytics upgrades',
          ]),
          _PlanItem('Pro', '49.00 / year', '14 days', 'Yearly billing', 'Balanced', 0.92, 0.72, 'Best value if you use the roadmap, memory hub, and exams every week.', 18, [
            'Everything in Starter plus deeper analytics',
            'Priority access to new study flows',
            'Unlimited mock blocks and archive retention',
          ]),
          _PlanItem('Coach', '79.00 / year', '14 days', 'Yearly billing', 'High', 1, 0.9, 'Best for heavy learners who want full exam cadence and active-learning packs.', 28, [
            'Everything in Pro plus premium challenge tracks',
            'Larger offline packs and coach reports',
            'Expanded community events and advanced labs',
          ]),
        ],
      AppLanguage.vi => const [
          _PlanItem('Starter', '119k / tháng', '7 ngày', 'Thanh toán theo tháng', 'Nhẹ', 0.58, 0.38, 'Hợp khi muốn thử premium sau khi đã ổn định streak hằng ngày.', 0, [
            'Bài đọc dài và deck mẫu cao cấp',
            'Retry đề thi với lịch sử dài hơn',
            'Nâng cấp analytics cơ bản',
          ]),
          _PlanItem('Pro', '1.190k / năm', '14 ngày', 'Thanh toán theo năm', 'Cân bằng', 0.92, 0.72, 'Giá trị nhất nếu bạn dùng lộ trình, ghi nhớ và đề thi mỗi tuần.', 18, [
            'Mọi thứ của Starter cộng analytics sâu hơn',
            'Ưu tiên trải nghiệm flow học mới',
            'Mock block không giới hạn và lưu lịch sử lâu hơn',
          ]),
          _PlanItem('Coach', '1.890k / năm', '14 ngày', 'Thanh toán theo năm', 'Cao', 1, 0.9, 'Hợp cho người học nặng muốn cadence thi đầy đủ và active-learning pack.', 28, [
            'Mọi thứ của Pro cộng challenge cao cấp',
            'Offline pack lớn hơn và báo cáo coach',
            'Sự kiện cộng đồng và design lab mở rộng',
          ]),
        ],
      AppLanguage.ja => const [
          _PlanItem('Starter', '¥600 / 月', '7日', '月額課金', 'ライト', 0.58, 0.38, '毎日の学習リズムが安定した後に premium を試すのに向いています。', 0, [
            '長文読解とプレミアムデッキ',
            '模試の再挑戦履歴を長く保持',
            '基本分析の強化',
          ]),
          _PlanItem('Pro', '¥5,900 / 年', '14日', '年額課金', 'バランス', 0.92, 0.72, 'ロードマップ、記憶、試験を毎週使う人に最適です。', 18, [
            'Starter に加えて深い分析',
            '新しい学習フローへの優先アクセス',
            '模試ブロック無制限と長期履歴保持',
          ]),
          _PlanItem('Coach', '¥9,600 / 年', '14日', '年額課金', '高強度', 1, 0.9, '本格学習者向けに試験 cadence と active-learning pack を広げます。', 28, [
            'Pro に加えてプレミアム challenge',
            '大きな offline pack と coach report',
            '拡張 community event と lab',
          ]),
        ],
    };

List<_MatrixRow> _matrix(AppLanguage language, _PlanItem selected) => switch (language) {
      AppLanguage.en => [
          _MatrixRow(Icons.menu_book_rounded, 'Reading depth', 'Short decks on Free, guided reading and long sets on ${selected.name}.', selected.name == 'Starter' ? 'Boosted' : 'Expanded', AppStatusTone.primary),
          _MatrixRow(Icons.analytics_rounded, 'Insights', 'Streak and XP remain free; weak-point trends and retention become much deeper.', selected.name == 'Coach' ? 'Full' : 'Upgraded', AppStatusTone.success),
          _MatrixRow(Icons.flight_takeoff_rounded, 'Study pace', 'Keep the same shell and flow, but remove friction around exams and active sessions.', selected.fit, AppStatusTone.warning),
        ],
      AppLanguage.vi => [
          _MatrixRow(Icons.menu_book_rounded, 'Độ sâu bài đọc', 'Bản Free có deck ngắn; ${selected.name} mở bài đọc dài và hướng dẫn đọc.', selected.name == 'Starter' ? 'Tăng nhẹ' : 'Mở rộng', AppStatusTone.primary),
          _MatrixRow(Icons.analytics_rounded, 'Insight', 'Streak và XP vẫn miễn phí; điểm yếu và retention sâu hơn nhiều.', selected.name == 'Coach' ? 'Đầy đủ' : 'Nâng cấp', AppStatusTone.success),
          _MatrixRow(Icons.flight_takeoff_rounded, 'Nhịp học', 'Giữ nguyên shell và flow, nhưng giảm ma sát quanh đề thi và phiên chủ động.', selected.fit, AppStatusTone.warning),
        ],
      AppLanguage.ja => [
          _MatrixRow(Icons.menu_book_rounded, '読解の深さ', 'Free は短いデッキ中心、${selected.name} では長文と読解ガイドが広がります。', selected.name == 'Starter' ? '強化' : '拡張', AppStatusTone.primary),
          _MatrixRow(Icons.analytics_rounded, '分析', 'streak と XP は無料のまま、弱点傾向と保持率がより深く見えます。', selected.name == 'Coach' ? 'フル' : '強化', AppStatusTone.success),
          _MatrixRow(Icons.flight_takeoff_rounded, '学習テンポ', 'shell と flow はそのままに、試験と active session の摩擦を減らします。', selected.fit, AppStatusTone.warning),
        ],
    };

String _title(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Upgrade',
      AppLanguage.vi => 'Nâng cấp',
      AppLanguage.ja => 'アップグレード',
    };
String _heroTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'JP Study Pro',
      AppLanguage.vi => 'JP Study Pro',
      AppLanguage.ja => 'JP Study Pro',
    };
String _heroSubtitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Keep the same app feel, but unlock stronger reading, deeper analytics, and steadier exam prep.',
      AppLanguage.vi => 'Giữ nguyên cảm giác app, nhưng mở khóa đọc sâu hơn, analytics mạnh hơn và luyện thi ổn định hơn.',
      AppLanguage.ja => 'アプリの雰囲気はそのままに、読解・分析・試験対策をさらに強化します。',
    };
String _upgradeLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Upgrade now',
      AppLanguage.vi => 'Nâng cấp ngay',
      AppLanguage.ja => '今すぐアップグレード',
    };
String _compareLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Compare plans',
      AppLanguage.vi => 'So sánh gói',
      AppLanguage.ja => 'プラン比較',
    };
String _plansTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Choose a plan',
      AppLanguage.vi => 'Chọn gói phù hợp',
      AppLanguage.ja => 'プランを選ぶ',
    };
String _plansCaption(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Unlock the full app — pick the plan that matches your study pace.',
      AppLanguage.vi => 'Mở khóa toàn bộ app — chọn gói phù hợp với tốc độ học của bạn.',
      AppLanguage.ja => 'アプリをフル解放 — 自分の学習ペースに合ったプランを選んでください。',
    };
String _fitTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Best fit',
      AppLanguage.vi => 'Phù hợp nhất',
      AppLanguage.ja => 'おすすめ',
    };
String _fitCaption(AppLanguage language, String fit) => switch (language) {
      AppLanguage.en => '$fit study intensity',
      AppLanguage.vi => 'Cường độ học $fit',
      AppLanguage.ja => '$fit の学習強度',
    };
String _trialLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Trial',
      AppLanguage.vi => 'Dùng thử',
      AppLanguage.ja => '無料体験',
    };
String _billingLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Billing',
      AppLanguage.vi => 'Thanh toán',
      AppLanguage.ja => '課金',
    };
String _valueLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Value coverage',
      AppLanguage.vi => 'Mức độ bao phủ giá trị',
      AppLanguage.ja => '価値カバー率',
    };
String _intensityLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Power for heavy study weeks',
      AppLanguage.vi => 'Sức mạnh cho tuần học nặng',
      AppLanguage.ja => '学習負荷の高い週への強さ',
    };
String _featureTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'What Pro unlocks',
      AppLanguage.vi => 'Pro mở khóa gì',
      AppLanguage.ja => 'Proで広がる内容',
    };
String _featureCaption(AppLanguage language) => switch (language) {
      AppLanguage.en => 'These sections now read like a real product surface instead of an empty upsell.',
      AppLanguage.vi => 'Các phần này giờ có cảm giác là một bề mặt sản phẩm thật thay vì một upsell trống.',
      AppLanguage.ja => '空の upsell ではなく、実際の製品面として読める構成にしています。',
    };
String _compareMatrixTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Free vs selected plan',
      AppLanguage.vi => 'Free so với gói đang chọn',
      AppLanguage.ja => 'Free と選択中プランの比較',
    };
String _compareMatrixCaption(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Simple matrix to help you choose without leaving the screen.',
      AppLanguage.vi => 'Ma trận đơn giản giúp quyết định ngay trên màn này.',
      AppLanguage.ja => '画面を離れずに判断しやすいシンプルな比較です。',
    };
String _ctaLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Select',
      AppLanguage.vi => 'Chọn',
      AppLanguage.ja => '選択',
    };
String _saveBadge(AppLanguage language, int badge) => switch (language) {
      AppLanguage.en => badge > 0 ? 'Save $badge%' : 'Entry',
      AppLanguage.vi => badge > 0 ? 'Tiết kiệm $badge%' : 'Khởi đầu',
      AppLanguage.ja => badge > 0 ? '$badge%お得' : '入門',
    };
String _checkoutSoon(AppLanguage language, String plan) => switch (language) {
      AppLanguage.en => '$plan checkout will be connected later.',
      AppLanguage.vi => 'Checkout cho gói $plan sẽ được nối sau.',
      AppLanguage.ja => '$plan の checkout は後で接続されます。',
    };

class _PremiumFeature {
  const _PremiumFeature(this.icon, this.title, this.subtitle, this.status, this.tone);

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppStatusTone tone;
}

class _PlanItem {
  const _PlanItem(this.name, this.price, this.trial, this.billing, this.fit,
      this.valueScore, this.intensityScore, this.badgeText, this.badge, this.points);

  final String name;
  final String price;
  final String trial;
  final String billing;
  final String fit;
  final double valueScore;
  final double intensityScore;
  final String badgeText;
  final int badge;
  final List<String> points;
}

class _MatrixRow {
  const _MatrixRow(this.icon, this.title, this.subtitle, this.status, this.tone);

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppStatusTone tone;
}
