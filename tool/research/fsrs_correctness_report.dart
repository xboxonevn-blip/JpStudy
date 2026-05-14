import 'dart:io';

import 'package:jpstudy/core/research/fsrs_correctness_audit.dart';

void main() {
  stdout.writeln(FsrsCorrectnessAuditor.inspect().toMarkdown());
}
