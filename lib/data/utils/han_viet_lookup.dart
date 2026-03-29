import 'dart:convert';

import 'package:flutter/services.dart';

class HanVietLookupResult {
  const HanVietLookupResult({this.hanViet, this.meaningVi});

  final String? hanViet;
  final String? meaningVi;
}

class HanVietLookup {
  HanVietLookup._();

  static Future<_HanVietData>? _cache;

  static Future<HanVietLookupResult> resolve({
    required String term,
    String? explicitHanViet,
    String? explicitMeaningVi,
  }) async {
    final data = await (_cache ??= _load());
    final override = data.termOverrides[term];
    final hanViet = _firstNonEmpty([
      explicitHanViet,
      override?['hanViet'],
      _composeHanViet(term, data.charLookup),
    ]);
    final meaningVi = _firstNonEmpty([
      override?['meaningVi'],
      explicitMeaningVi,
    ]);
    return HanVietLookupResult(hanViet: hanViet, meaningVi: meaningVi);
  }

  static String? _composeHanViet(String term, Map<String, String> charLookup) {
    final parts = <String>[];
    for (final rune in term.runes) {
      final char = String.fromCharCode(rune);
      final reading = charLookup[char];
      if (reading != null && reading.trim().isNotEmpty) {
        parts.add(reading.trim());
      }
    }
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static Future<_HanVietData> _load() async {
    final charLookup = <String, String>{};
    final termOverrides = <String, Map<String, String>>{};

    Future<void> loadJson(
      String path,
      void Function(dynamic json) apply,
    ) async {
      try {
        final raw = await rootBundle.loadString(path);
        apply(json.decode(raw));
      } catch (_) {}
    }

    await loadJson('assets/data/support/kanji/decomposition.json', (jsonValue) {
      if (jsonValue is! Map) return;
      for (final entry in jsonValue.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is! Map) continue;
        final hanViet = (value['hanViet'] ?? '').toString().trim();
        if (hanViet.isNotEmpty) {
          charLookup.putIfAbsent(key, () => hanViet);
        }
      }
    });

    await loadJson('assets/data/support/kanji/hanviet_supplemental_n3.json', (
      jsonValue,
    ) {
      if (jsonValue is! Map) return;
      for (final entry in jsonValue.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          final hanViet = (value['hanViet'] ?? '').toString().trim();
          if (hanViet.isNotEmpty) {
            charLookup[key] = hanViet;
          }
        }
      }
    });

    await loadJson('assets/data/support/kanji/hanviet_term_overrides_n3.json', (
      jsonValue,
    ) {
      if (jsonValue is! Map) return;
      for (final entry in jsonValue.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is! Map) continue;
        final mapped = <String, String>{};
        final hanViet = (value['hanViet'] ?? '').toString().trim();
        final meaningVi = (value['meaningVi'] ?? '').toString().trim();
        if (hanViet.isNotEmpty) mapped['hanViet'] = hanViet;
        if (meaningVi.isNotEmpty) mapped['meaningVi'] = meaningVi;
        if (mapped.isNotEmpty) termOverrides[key] = mapped;
      }
    });

    return _HanVietData(charLookup: charLookup, termOverrides: termOverrides);
  }
}

class _HanVietData {
  const _HanVietData({required this.charLookup, required this.termOverrides});

  final Map<String, String> charLookup;
  final Map<String, Map<String, String>> termOverrides;
}
