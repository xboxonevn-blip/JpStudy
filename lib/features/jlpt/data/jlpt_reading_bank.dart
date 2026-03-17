import 'package:jpstudy/features/immersion/services/shared_reading_library.dart';

import '../models/jlpt_reading_models.dart';

const SharedReadingLibrary _sharedReadingLibrary = SharedReadingLibrary();

Future<List<JlptReadingPassage>> loadJlptReadingBank() {
  return _sharedReadingLibrary.loadJlptPassages();
}
