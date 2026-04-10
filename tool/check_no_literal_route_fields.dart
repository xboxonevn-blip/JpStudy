import 'dart:io';

final routeFieldPatterns = <RegExp>[
  RegExp(r'''\broute\s*:\s*['"]\/'''),
  RegExp(r'''\binitialRoute\s*:\s*['"]\/'''),
  RegExp(r'''\blastRoute\s*[:=]\s*['"]\/'''),
];

bool isIgnoredRouteFieldPath(String rawPath) {
  final normalized = rawPath.replaceAll('\\', '/');
  return normalized.startsWith('lib/app/navigation/') ||
      normalized.endsWith('.g.dart') ||
      normalized.endsWith('.freezed.dart');
}

List<String> findLiteralRouteFields({String root = 'lib'}) {
  final failures = <String>[];
  final libDir = Directory(root);
  if (!libDir.existsSync()) {
    return ['Missing $root/ directory.'];
  }

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (isIgnoredRouteFieldPath(entity.path)) continue;
    final lines = entity.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//')) continue;
      if (routeFieldPatterns.any((pattern) => pattern.hasMatch(line))) {
        final normalizedPath = entity.path.replaceAll('\\', '/');
        failures.add('$normalizedPath:${index + 1}: ${line.trim()}');
      }
    }
  }
  return failures;
}

void main() {
  final failures = findLiteralRouteFields();
  if (failures.isEmpty) {
    stdout.writeln('No literal route fields found outside lib/app/navigation.');
    return;
  }

  stderr.writeln('Found literal route fields outside lib/app/navigation:');
  for (final failure in failures) {
    stderr.writeln(failure);
  }
  exitCode = 1;
}
