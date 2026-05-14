import 'dart:io';

import 'package:jpstudy/core/research/content_link_graph.dart';

void main(List<String> args) {
  final root = Directory(
    _optionalValue(args, '--content-root') ?? 'assets/data/content',
  );
  final report = ContentLinkGraphBuilder.scan(root);
  stdout.writeln(report.toMarkdown(contentRoot: root.path));
}

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
