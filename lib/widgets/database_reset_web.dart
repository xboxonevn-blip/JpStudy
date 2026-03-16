Future<bool> resetDatabaseFiles() async {
  // On web, database reset is handled by clearing browser storage.
  return false;
}
