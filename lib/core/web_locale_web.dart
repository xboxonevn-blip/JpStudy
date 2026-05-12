import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/web_locale.dart';
import 'package:web/web.dart' as web;

void syncHtmlLang(AppLanguage language) {
  web.document.documentElement?.setAttribute(
    'lang',
    htmlLangForLanguage(language),
  );
}
