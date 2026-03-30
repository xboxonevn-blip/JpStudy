import 'package:jpstudy/data/models/vocab_item.dart';

class VocabMatchSessionArgs {
  const VocabMatchSessionArgs({
    required this.items,
    required this.title,
  });

  final List<VocabItem> items;
  final String title;
}
