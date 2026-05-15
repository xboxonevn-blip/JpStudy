import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content JSON stays UTF-8 without known mojibake artifacts', () {
    final files = Directory('assets/data/content')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(files, isNotEmpty);

    for (final file in files) {
      final raw = file.readAsStringSync();
      jsonDecode(raw);

      expect(raw, isNot(contains('Ã')), reason: file.path);
      expect(raw, isNot(contains('â€')), reason: file.path);
      expect(raw, isNot(contains(r'\u00c3')), reason: file.path);
      expect(raw, isNot(contains(r'\ufffd')), reason: file.path);
      expect(raw, isNot(contains('�')), reason: file.path);
      expect(raw, isNot(contains('??')), reason: file.path);

      for (final fragment in _knownQuestionMarkArtifacts) {
        expect(raw, isNot(contains(fragment)), reason: file.path);
      }
    }
  });
}

const _knownQuestionMarkArtifacts = [
  'xu?t hi?n',
  'trong t? JLPT',
  'Ng??i',
  'Nh?n ?',
  'b?n d?ch',
  'h?ng h?c',
  'tr?c tr?c',
  'h??ng d?n',
  'Th?i ??',
  '?i?u Ki?n',
  '?i?u Tra',
];
