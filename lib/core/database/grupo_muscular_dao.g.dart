// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grupo_muscular_dao.dart';

// ignore_for_file: type=lint
mixin _$GrupoMuscularDaoMixin on DatabaseAccessor<AppDatabase> {
  $GruposMuscularesTable get gruposMusculares =>
      attachedDatabase.gruposMusculares;
  GrupoMuscularDaoManager get managers => GrupoMuscularDaoManager(this);
}

class GrupoMuscularDaoManager {
  final _$GrupoMuscularDaoMixin _db;
  GrupoMuscularDaoManager(this._db);
  $$GruposMuscularesTableTableManager get gruposMusculares =>
      $$GruposMuscularesTableTableManager(
        _db.attachedDatabase,
        _db.gruposMusculares,
      );
}
