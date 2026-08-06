// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercicio_dao.dart';

// ignore_for_file: type=lint
mixin _$ExercicioDaoMixin on DatabaseAccessor<AppDatabase> {
  $GruposMuscularesTable get gruposMusculares =>
      attachedDatabase.gruposMusculares;
  $ExerciciosTable get exercicios => attachedDatabase.exercicios;
  ExercicioDaoManager get managers => ExercicioDaoManager(this);
}

class ExercicioDaoManager {
  final _$ExercicioDaoMixin _db;
  ExercicioDaoManager(this._db);
  $$GruposMuscularesTableTableManager get gruposMusculares =>
      $$GruposMuscularesTableTableManager(
        _db.attachedDatabase,
        _db.gruposMusculares,
      );
  $$ExerciciosTableTableManager get exercicios =>
      $$ExerciciosTableTableManager(_db.attachedDatabase, _db.exercicios);
}
