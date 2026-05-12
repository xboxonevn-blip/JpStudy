import 'package:jpstudy/core/app_language.dart';

export 'web_locale_stub.dart'
    if (dart.library.js_interop) 'web_locale_web.dart';

String htmlLangForLanguage(AppLanguage language) =>
    language.locale.languageCode;
