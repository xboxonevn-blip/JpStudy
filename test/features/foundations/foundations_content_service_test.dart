import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/foundations/services/foundations_content_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads kana chart with expected imported counts', () async {
    final service = FoundationsContentService();

    final chart = await service.loadKanaChart();

    expect(chart.hiragana.entries, hasLength(71));
    expect(chart.hiragana.compounds, hasLength(33));
    expect(chart.katakana.entries, hasLength(71));
    expect(chart.katakana.compounds, hasLength(33));
  });

  test('loads han viet rules with citations', () async {
    final service = FoundationsContentService();

    final ruleSet = await service.loadHanVietRules();

    expect(ruleSet.rules, hasLength(32));
    expect(ruleSet.sources, hasLength(5));
    expect(ruleSet.rules.first.examples, isNotEmpty);
  });
}
