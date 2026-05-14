import 'dart:io';

class VietnameseI18nAuditRunner {
  const VietnameseI18nAuditRunner._();

  static VietnameseI18nAuditReport scan({
    required File appLanguageFile,
    required Directory libRoot,
    required Directory contentRoot,
    required Directory docsRoot,
  }) {
    final appLanguage = _scanAppLanguage(appLanguageFile);
    final hardcoded = _scanHardcodedVietnamese(
      libRoot,
      excludedFile: appLanguageFile,
    );
    final decodeErrors = <VietnameseI18nHit>[];
    final mojibake = <VietnameseI18nHit>[
      ..._scanMojibake(
        libRoot,
        rootName: 'lib',
        extensions: const ['.dart'],
        decodeErrorHits: decodeErrors,
      ),
      ..._scanMojibake(
        contentRoot,
        rootName: 'content',
        extensions: const ['.json'],
        decodeErrorHits: decodeErrors,
      ),
      ..._scanMojibake(
        docsRoot,
        rootName: 'docs',
        extensions: const ['.md'],
        decodeErrorHits: decodeErrors,
      ),
    ];
    return VietnameseI18nAuditReport(
      appLanguage: appLanguage,
      hardcodedVietnameseHits: hardcoded,
      mojibakeHits: mojibake,
      decodeErrorHits: decodeErrors,
    );
  }
}

class VietnameseI18nAuditReport {
  const VietnameseI18nAuditReport({
    required this.appLanguage,
    required this.hardcodedVietnameseHits,
    required this.mojibakeHits,
    required this.decodeErrorHits,
  });

  final AppLanguageAudit appLanguage;
  final List<VietnameseI18nHit> hardcodedVietnameseHits;
  final List<VietnameseI18nHit> mojibakeHits;
  final List<VietnameseI18nHit> decodeErrorHits;

  Map<String, int> get hardcodedVietnameseByFile =>
      _countByFile(hardcodedVietnameseHits);

  Map<String, int> get mojibakeByRoot {
    final counts = <String, int>{};
    for (final hit in mojibakeHits) {
      counts.update(hit.root, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Map<String, int> get mojibakeByFile => _countByFile(mojibakeHits);

  String toMarkdown({
    required String appLanguagePath,
    required String libRootPath,
    required String contentRootPath,
    required String docsRootPath,
  }) {
    return [
      '# Vietnamese I18n Audit',
      '',
      'App language: `$appLanguagePath`',
      'Lib root: `$libRootPath`',
      'Content root: `$contentRootPath`',
      'Docs root: `$docsRootPath`',
      '',
      '| Locale | Localized returns |',
      '|---|---:|',
      for (final locale in const ['en', 'vi', 'ja'])
        '| $locale | ${appLanguage.localizedReturns[locale] ?? 0} |',
      '',
      '| Metric | Count |',
      '|---|---:|',
      '| App language lines | ${appLanguage.lineCount} |',
      '| Empty localized returns | ${appLanguage.emptyLocalizedReturns} |',
      '| TODO/draft localized returns | ${appLanguage.todoLocalizedReturns} |',
      '| Hardcoded Vietnamese lines | ${hardcodedVietnameseHits.length} |',
      '| Mojibake hits | ${mojibakeHits.length} |',
      '| Decode error files | ${decodeErrorHits.length} |',
      '',
      '| Mojibake root | Hits |',
      '|---|---:|',
      for (final entry in _sortedEntries(mojibakeByRoot))
        '| ${entry.key} | ${entry.value} |',
      '',
      '| Top hardcoded Vietnamese files | Hits |',
      '|---|---:|',
      for (final entry in _topEntries(hardcodedVietnameseByFile, limit: 10))
        '| ${entry.key} | ${entry.value} |',
      '',
      '| Top mojibake files | Hits |',
      '|---|---:|',
      for (final entry in _topEntries(mojibakeByFile, limit: 10))
        '| ${entry.key} | ${entry.value} |',
      '',
      '| Decode error files | Root |',
      '|---|---|',
      for (final hit in decodeErrorHits) '| ${hit.filePath} | ${hit.root} |',
    ].join('\n');
  }
}

class AppLanguageAudit {
  const AppLanguageAudit({
    required this.lineCount,
    required this.localizedReturns,
    required this.emptyLocalizedReturns,
    required this.todoLocalizedReturns,
  });

  final int lineCount;
  final Map<String, int> localizedReturns;
  final int emptyLocalizedReturns;
  final int todoLocalizedReturns;
}

class VietnameseI18nHit {
  const VietnameseI18nHit({
    required this.root,
    required this.filePath,
    required this.lineNumber,
    required this.text,
  });

  final String root;
  final String filePath;
  final int lineNumber;
  final String text;
}

AppLanguageAudit _scanAppLanguage(File file) {
  final counts = {'en': 0, 'vi': 0, 'ja': 0};
  var emptyReturns = 0;
  var todoReturns = 0;
  String? currentLocale;
  final lines = file.existsSync() ? file.readAsLinesSync() : const <String>[];
  final casePattern = RegExp(r'case AppLanguage\.(en|vi|ja):');
  final emptyReturnPattern = RegExp(r'''return\s+(['"])\\?\1\s*;''');

  for (final line in lines) {
    final caseMatch = casePattern.firstMatch(line);
    if (caseMatch != null) {
      currentLocale = caseMatch.group(1);
      continue;
    }
    if (currentLocale == null || !line.contains('return')) continue;
    counts.update(currentLocale, (value) => value + 1, ifAbsent: () => 1);
    final lower = line.toLowerCase();
    if (emptyReturnPattern.hasMatch(line)) {
      emptyReturns++;
    }
    if (lower.contains('todo') ||
        lower.contains('draft') ||
        lower.contains('placeholder') ||
        lower.contains('cần duyệt')) {
      todoReturns++;
    }
    currentLocale = null;
  }

  return AppLanguageAudit(
    lineCount: lines.length,
    localizedReturns: counts,
    emptyLocalizedReturns: emptyReturns,
    todoLocalizedReturns: todoReturns,
  );
}

List<VietnameseI18nHit> _scanHardcodedVietnamese(
  Directory root, {
  required File excludedFile,
}) {
  final excludedPath = _normalizePath(excludedFile.path);
  final hits = <VietnameseI18nHit>[];
  for (final file in _files(root, const ['.dart'])) {
    final path = _normalizePath(file.path);
    if (path == excludedPath || path.endsWith('/core/app_language.dart')) {
      continue;
    }
    if (path.contains('/core/research/')) continue;
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (_hasMojibake(line)) continue;
      if (!_vietnamesePattern.hasMatch(line)) continue;
      hits.add(
        VietnameseI18nHit(
          root: 'lib',
          filePath: _normalizePath(file.path),
          lineNumber: index + 1,
          text: line.trim(),
        ),
      );
    }
  }
  return hits;
}

List<VietnameseI18nHit> _scanMojibake(
  Directory root, {
  required String rootName,
  required List<String> extensions,
  required List<VietnameseI18nHit> decodeErrorHits,
}) {
  final hits = <VietnameseI18nHit>[];
  for (final file in _files(root, extensions)) {
    final path = _normalizePath(file.path);
    if (_isIntentionalMojibakeReferenceFile(path)) continue;
    final List<String> lines;
    try {
      lines = file.readAsLinesSync();
    } on FileSystemException catch (error) {
      decodeErrorHits.add(
        VietnameseI18nHit(
          root: rootName,
          filePath: path,
          lineNumber: 0,
          text: error.message,
        ),
      );
      continue;
    }
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (_isIntentionalMojibakeReferenceLine(line)) continue;
      if (!_hasMojibake(line)) continue;
      hits.add(
        VietnameseI18nHit(
          root: rootName,
          filePath: path,
          lineNumber: index + 1,
          text: line.trim(),
        ),
      );
    }
  }
  return hits;
}

List<File> _files(Directory root, List<String> extensions) {
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => extensions.any(file.path.endsWith))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

Map<String, int> _countByFile(List<VietnameseI18nHit> hits) {
  final counts = <String, int>{};
  for (final hit in hits) {
    counts.update(hit.filePath, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}

List<MapEntry<String, int>> _topEntries(
  Map<String, int> counts, {
  int limit = 10,
}) {
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.compareTo(b.key);
    });
  return entries.take(limit).toList();
}

List<MapEntry<String, int>> _sortedEntries(Map<String, int> counts) {
  final entries = counts.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return entries;
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

bool _hasMojibake(String line) {
  return _mojibakePatterns.any((pattern) => pattern.hasMatch(line));
}

bool _isIntentionalMojibakeReferenceFile(String path) {
  return path == 'lib/core/research/vietnamese_i18n_audit.dart' ||
      path.endsWith('/lib/core/research/vietnamese_i18n_audit.dart') ||
      path.contains('docs/research/D3-vietnamese/');
}

bool _isIntentionalMojibakeReferenceLine(String line) {
  return line.contains('markers =') || line.contains('mojibake marker');
}

final _vietnamesePattern = RegExp(
  r'[ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠƯàáâãèéêìíòóôõùúăđĩũơưẠ-ỹ]',
);

final _mojibakePatterns = <RegExp>[
  RegExp(r'Ã[\u00A1-\u00BF]'),
  RegExp(r'Â[\u00A1-\u00BF]'),
  RegExp('â€'),
  RegExp('â†'),
  RegExp('â‰'),
  RegExp('âœ'),
  RegExp('â”'),
  RegExp('�'),
];
