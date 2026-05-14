import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class WebPerfBudget {
  const WebPerfBudget({
    this.mainDartJsRawBytes,
    this.mainDartJsGzipBytes,
    this.canvaskitWasmRawBytes,
    this.canvaskitWasmGzipBytes,
    this.sqliteWasmRawBytes,
    this.sqliteWasmGzipBytes,
    this.totalBuildRawBytes,
    this.totalAssetsRawBytes,
    this.totalJsonRawBytes,
  });

  final int? mainDartJsRawBytes;
  final int? mainDartJsGzipBytes;
  final int? canvaskitWasmRawBytes;
  final int? canvaskitWasmGzipBytes;
  final int? sqliteWasmRawBytes;
  final int? sqliteWasmGzipBytes;
  final int? totalBuildRawBytes;
  final int? totalAssetsRawBytes;
  final int? totalJsonRawBytes;

  factory WebPerfBudget.fromJson(Map<String, Object?> json) {
    return WebPerfBudget(
      mainDartJsRawBytes: _intValue(json, 'mainDartJsRawBytes'),
      mainDartJsGzipBytes: _intValue(json, 'mainDartJsGzipBytes'),
      canvaskitWasmRawBytes: _intValue(json, 'canvaskitWasmRawBytes'),
      canvaskitWasmGzipBytes: _intValue(json, 'canvaskitWasmGzipBytes'),
      sqliteWasmRawBytes: _intValue(json, 'sqliteWasmRawBytes'),
      sqliteWasmGzipBytes: _intValue(json, 'sqliteWasmGzipBytes'),
      totalBuildRawBytes: _intValue(json, 'totalBuildRawBytes'),
      totalAssetsRawBytes: _intValue(json, 'totalAssetsRawBytes'),
      totalJsonRawBytes: _intValue(json, 'totalJsonRawBytes'),
    );
  }

  static WebPerfBudget fromFile(File file) {
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    return WebPerfBudget.fromJson(decoded);
  }

  static int? _intValue(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    throw FormatException('Budget field $key must be numeric.');
  }
}

class WebPerfMetric {
  const WebPerfMetric({
    required this.label,
    required this.actualBytes,
    required this.budgetBytes,
  });

  final String label;
  final int actualBytes;
  final int? budgetBytes;

  bool get violatesBudget => budgetBytes != null && actualBytes > budgetBytes!;

  String get status {
    if (budgetBytes == null) return 'INFO';
    return violatesBudget ? 'VIOLATION' : 'PASS';
  }
}

class WebPerfBudgetReport {
  const WebPerfBudgetReport({
    required this.buildRoot,
    required this.metrics,
    required this.largestJsonFiles,
  });

  final String buildRoot;
  final List<WebPerfMetric> metrics;
  final List<FileSizeEntry> largestJsonFiles;

  bool get hasViolations => metrics.any((metric) => metric.violatesBudget);

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Web Performance Budget Report')
      ..writeln()
      ..writeln('Build root: `$buildRoot`')
      ..writeln()
      ..writeln('| Metric | Actual bytes | Budget bytes | Status |')
      ..writeln('|---|---:|---:|---|');
    for (final metric in metrics) {
      buffer.writeln(
        '| ${metric.label} | ${metric.actualBytes} | '
        '${metric.budgetBytes ?? 'n/a'} | ${metric.status} |',
      );
    }
    if (largestJsonFiles.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Largest JSON Files')
        ..writeln()
        ..writeln('| File | Bytes |')
        ..writeln('|---|---:|');
      for (final entry in largestJsonFiles) {
        buffer.writeln('| `${entry.path}` | ${entry.bytes} |');
      }
    }
    return buffer.toString();
  }
}

class FileSizeEntry {
  const FileSizeEntry({required this.path, required this.bytes});

  final String path;
  final int bytes;
}

class WebPerfBudgetChecker {
  static WebPerfBudgetReport scan({
    required Directory buildRoot,
    required WebPerfBudget budget,
    int largestJsonLimit = 10,
  }) {
    if (!buildRoot.existsSync()) {
      throw ArgumentError('Build root does not exist: ${buildRoot.path}');
    }

    final mainDartJs = File('${buildRoot.path}/main.dart.js');
    final canvaskitWasm = File('${buildRoot.path}/canvaskit/canvaskit.wasm');
    final sqliteWasm = File('${buildRoot.path}/sqlite3.wasm');
    final assetsRoot = Directory('${buildRoot.path}/assets');
    final allFiles = _filesUnder(buildRoot);
    final jsonFiles = allFiles
        .where((file) => file.path.toLowerCase().endsWith('.json'))
        .toList(growable: false);

    final largestJsonFiles =
        jsonFiles
            .map(
              (file) => FileSizeEntry(
                path: _relativePath(buildRoot, file),
                bytes: file.lengthSync(),
              ),
            )
            .toList()
          ..sort((a, b) => b.bytes.compareTo(a.bytes));

    return WebPerfBudgetReport(
      buildRoot: buildRoot.path,
      largestJsonFiles: largestJsonFiles.take(largestJsonLimit).toList(),
      metrics: [
        WebPerfMetric(
          label: 'main.dart.js raw',
          actualBytes: _fileLength(mainDartJs),
          budgetBytes: budget.mainDartJsRawBytes,
        ),
        WebPerfMetric(
          label: 'main.dart.js gzip',
          actualBytes: _gzipLength(mainDartJs),
          budgetBytes: budget.mainDartJsGzipBytes,
        ),
        WebPerfMetric(
          label: 'canvaskit.wasm raw',
          actualBytes: _fileLength(canvaskitWasm),
          budgetBytes: budget.canvaskitWasmRawBytes,
        ),
        WebPerfMetric(
          label: 'canvaskit.wasm gzip',
          actualBytes: _gzipLength(canvaskitWasm),
          budgetBytes: budget.canvaskitWasmGzipBytes,
        ),
        WebPerfMetric(
          label: 'sqlite3.wasm raw',
          actualBytes: _fileLength(sqliteWasm),
          budgetBytes: budget.sqliteWasmRawBytes,
        ),
        WebPerfMetric(
          label: 'sqlite3.wasm gzip',
          actualBytes: _gzipLength(sqliteWasm),
          budgetBytes: budget.sqliteWasmGzipBytes,
        ),
        WebPerfMetric(
          label: 'total build raw',
          actualBytes: _totalLength(allFiles),
          budgetBytes: budget.totalBuildRawBytes,
        ),
        WebPerfMetric(
          label: 'total assets raw',
          actualBytes: assetsRoot.existsSync()
              ? _totalLength(_filesUnder(assetsRoot))
              : 0,
          budgetBytes: budget.totalAssetsRawBytes,
        ),
        WebPerfMetric(
          label: 'total JSON raw',
          actualBytes: _totalLength(jsonFiles),
          budgetBytes: budget.totalJsonRawBytes,
        ),
      ],
    );
  }

  static List<File> _filesUnder(Directory root) {
    return root
        .listSync(recursive: true)
        .whereType<File>()
        .toList(growable: false);
  }

  static int _totalLength(Iterable<File> files) {
    return files.fold<int>(0, (sum, file) => sum + file.lengthSync());
  }

  static int _fileLength(File file) {
    if (!file.existsSync()) return 0;
    return file.lengthSync();
  }

  static int _gzipLength(File file) {
    if (!file.existsSync()) return 0;
    return gzip.encode(file.readAsBytesSync()).length;
  }

  static String _relativePath(Directory root, File file) {
    return p.relative(file.path, from: root.path).replaceAll(r'\', '/');
  }
}
