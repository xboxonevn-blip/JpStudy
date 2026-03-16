/// Stub implementations for dart:io types on web.
/// These allow code to compile on web even if the features are
/// guarded by kIsWeb checks at runtime.
library;

class File {
  File(this.path);
  final String path;
  File get parent => File(path);
  bool existsSync() => false;
  Future<void> create({bool recursive = false}) async {}
  Future<String> readAsString() async => '';
  Future<void> writeAsString(String contents, {bool flush = false}) async {}
  Future<bool> exists() async => false;
  Future<void> delete() async {}
  DateTime lastModifiedSync() => DateTime.fromMillisecondsSinceEpoch(0);
}

class Directory {
  Directory(this.path);
  final String path;
  bool existsSync() => false;
  void createSync({bool recursive = false}) {}
  Future<void> create({bool recursive = false}) async {}
  List<dynamic> listSync() => [];
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;
  static bool get isWindows => false;
}
