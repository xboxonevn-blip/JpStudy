import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English count copy avoids raw plural-risk templates', () {
    final lib = Directory('lib');
    final pattern = RegExp(
      r'\$count (items|terms|lessons|questions|strokes|due)'
      r'|\$[a-zA-Z]+Count (items|terms|lessons|questions|decks)'
      r'|\$\{[^}]+\} (items|terms|lessons|questions|decks|prompts)',
    );

    final hits = <String>[];
    for (final file in lib.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i += 1) {
        if (pattern.hasMatch(lines[i])) {
          hits.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
