import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/web_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _containerWithPrefs(
  Map<String, Object> values,
) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

void main() {
  test('boots from persisted app.locale before first read', () async {
    final container = await _containerWithPrefs({'app.locale': 'ja'});
    addTearDown(container.dispose);

    expect(container.read(appLanguageProvider), AppLanguage.ja);
  });

  test('persists app.locale when language changes', () async {
    final container = await _containerWithPrefs({});
    addTearDown(container.dispose);
    final prefs = container.read(sharedPreferencesProvider);

    await container
        .read(appLanguageProvider.notifier)
        .setLanguage(AppLanguage.vi);

    expect(prefs.getString('app.locale'), 'vi');
    expect(container.read(appLanguageProvider), AppLanguage.vi);
  });

  test('unitMinutesLabel localizes minute units', () {
    expect(AppLanguage.en.unitMinutesLabel(5), '5 min');
    expect(AppLanguage.vi.unitMinutesLabel(5), '5 phút');
    expect(AppLanguage.ja.unitMinutesLabel(5), '5分');
  });

  test('htmlLangForLanguage maps app language to BCP47 language code', () {
    expect(htmlLangForLanguage(AppLanguage.en), 'en');
    expect(htmlLangForLanguage(AppLanguage.vi), 'vi');
    expect(htmlLangForLanguage(AppLanguage.ja), 'ja');
  });

  test('mcqResultAnnouncement localizes correct and wrong results', () {
    expect(
      AppLanguage.vi.mcqResultAnnouncement(isCorrect: true, correctAnswer: '?'),
      '??p ?n ??ng',
    );
    expect(
      AppLanguage.vi.mcqResultAnnouncement(
        isCorrect: false,
        correctAnswer: '?',
      ),
      '??p ?n sai, ??p ?n ??ng l? ?',
    );
  });

  test('analytics consent copy is localized', () {
    expect(AppLanguage.vi.analyticsConsentTitle, contains('JpStudy'));
    expect(AppLanguage.vi.analyticsConsentAcceptLabel, 'Cho ph?p');
    expect(AppLanguage.vi.analyticsConsentDeclineLabel, 'Kh?ng, c?m ?n');
  });

  test('loginManualAccountFooterLabel stays non-personal', () {
    for (final language in AppLanguage.values) {
      final copy = language.loginManualAccountFooterLabel.toLowerCase();
      expect(copy, isNot(contains('message me')));
      expect(copy, isNot(contains('gmail')));
      expect(copy, isNot(contains('issue an account')));
    }
  });
}
