// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ficha_treino_dao.dart';

// ignore_for_file: type=lint
mixin _$FichaTreinoDaoMixin on DatabaseAccessor<AppDatabase> {
  $FichasTreinoTable get fichasTreino => attachedDatabase.fichasTreino;
  $GruposMuscularesTable get gruposMusculares =>
      attachedDatabase.gruposMusculares;
  $ExerciciosTable get exercicios => attachedDatabase.exercicios;
  $FichasExerciciosTable get fichasExercicios =>
      attachedDatabase.fichasExercicios;
  $FichasExerciciosSeriesTable get fichasExerciciosSeries =>
      attachedDatabase.fichasExerciciosSeries;
  FichaTreinoDaoManager get managers => FichaTreinoDaoManager(this);
}

class FichaTreinoDaoManager {
  final _$FichaTreinoDaoMixin _db;
  FichaTreinoDaoManager(this._db);
  $$FichasTreinoTableTableManager get fichasTreino =>
      $$FichasTreinoTableTableManager(_db.attachedDatabase, _db.fichasTreino);
  $$GruposMuscularesTableTableManager get gruposMusculares =>
      $$GruposMuscularesTableTableManager(
        _db.attachedDatabase,
        _db.gruposMusculares,
      );
  $$ExerciciosTableTableManager get exercicios =>
      $$ExerciciosTableTableManager(_db.attachedDatabase, _db.exercicios);
  $$FichasExerciciosTableTableManager get fichasExercicios =>
      $$FichasExerciciosTableTableManager(
        _db.attachedDatabase,
        _db.fichasExercicios,
      );
  $$FichasExerciciosSeriesTableTableManager get fichasExerciciosSeries =>
      $$FichasExerciciosSeriesTableTableManager(
        _db.attachedDatabase,
        _db.fichasExerciciosSeries,
      );
}
