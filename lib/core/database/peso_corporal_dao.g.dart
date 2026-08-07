// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peso_corporal_dao.dart';

// ignore_for_file: type=lint
mixin _$PesoCorporalDaoMixin on DatabaseAccessor<AppDatabase> {
  $PesosCorporaisTable get pesosCorporais => attachedDatabase.pesosCorporais;
  PesoCorporalDaoManager get managers => PesoCorporalDaoManager(this);
}

class PesoCorporalDaoManager {
  final _$PesoCorporalDaoMixin _db;
  PesoCorporalDaoManager(this._db);
  $$PesosCorporaisTableTableManager get pesosCorporais =>
      $$PesosCorporaisTableTableManager(
        _db.attachedDatabase,
        _db.pesosCorporais,
      );
}
