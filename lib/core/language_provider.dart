import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jpstudy/core/app_language.dart';

final appLanguageProvider = StateProvider<AppLanguage>(
  (ref) => kIsWeb ? AppLanguage.vi : AppLanguage.en,
);


