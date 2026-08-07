// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medida_corporal_dao.dart';

// ignore_for_file: type=lint
mixin _$MedidaCorporalDaoMixin on DatabaseAccessor<AppDatabase> {
  $MedidasCorporaisTable get medidasCorporais =>
      attachedDatabase.medidasCorporais;
  MedidaCorporalDaoManager get managers => MedidaCorporalDaoManager(this);
}

class MedidaCorporalDaoManager {
  final _$MedidaCorporalDaoMixin _db;
  MedidaCorporalDaoManager(this._db);
  $$MedidasCorporaisTableTableManager get medidasCorporais =>
      $$MedidasCorporaisTableTableManager(
        _db.attachedDatabase,
        _db.medidasCorporais,
      );
}
