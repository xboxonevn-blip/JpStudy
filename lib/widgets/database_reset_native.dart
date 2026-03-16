import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<bool> resetDatabaseFiles() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'jpstudy.sqlite'));

    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  } catch (e) {
    debugPrint('Error resetting database: $e');
    return false;
  }
}
