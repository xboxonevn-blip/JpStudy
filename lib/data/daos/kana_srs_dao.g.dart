// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kana_srs_dao.dart';

// ignore_for_file: type=lint
mixin _$KanaSrsDaoMixin on DatabaseAccessor<AppDatabase> {
  $KanaSrsStateTable get kanaSrsState => attachedDatabase.kanaSrsState;
  KanaSrsDaoManager get managers => KanaSrsDaoManager(this);
}

class KanaSrsDaoManager {
  final _$KanaSrsDaoMixin _db;
  KanaSrsDaoManager(this._db);
  $$KanaSrsStateTableTableManager get kanaSrsState =>
      $$KanaSrsStateTableTableManager(_db.attachedDatabase, _db.kanaSrsState);
}
