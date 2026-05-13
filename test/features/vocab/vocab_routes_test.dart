import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/routes/vocab_routes.dart';

void main() {
  test('parseVocabHajimeteChapterId accepts chapterId and id aliases', () {
    expect(parseVocabHajimeteChapterId({'chapterId': '3'}), 3);
    expect(parseVocabHajimeteChapterId({'id': '2'}), 2);
    expect(parseVocabHajimeteChapterId({'chapterId': 'bad', 'id': '4'}), 1);
    expect(parseVocabHajimeteChapterId({}), 1);
  });
}
