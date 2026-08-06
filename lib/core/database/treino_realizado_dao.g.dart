// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treino_realizado_dao.dart';

// ignore_for_file: type=lint
mixin _$TreinoRealizadoDaoMixin on DatabaseAccessor<AppDatabase> {
  $FichasTreinoTable get fichasTreino => attachedDatabase.fichasTreino;
  $GruposMuscularesTable get gruposMusculares =>
      attachedDatabase.gruposMusculares;
  $ExerciciosTable get exercicios => attachedDatabase.exercicios;
  $FichasExerciciosTable get fichasExercicios =>
      attachedDatabase.fichasExercicios;
  $FichasExerciciosSeriesTable get fichasExerciciosSeries =>
      attachedDatabase.fichasExerciciosSeries;
  $TreinosRealizadosTable get treinosRealizados =>
      attachedDatabase.treinosRealizados;
  $ExerciciosRealizadosTable get exerciciosRealizados =>
      attachedDatabase.exerciciosRealizados;
  $SeriesRealizadasTable get seriesRealizadas =>
      attachedDatabase.seriesRealizadas;
  TreinoRealizadoDaoManager get managers => TreinoRealizadoDaoManager(this);
}

class TreinoRealizadoDaoManager {
  final _$TreinoRealizadoDaoMixin _db;
  TreinoRealizadoDaoManager(this._db);
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
  $$TreinosRealizadosTableTableManager get treinosRealizados =>
      $$TreinosRealizadosTableTableManager(
        _db.attachedDatabase,
        _db.treinosRealizados,
      );
  $$ExerciciosRealizadosTableTableManager get exerciciosRealizados =>
      $$ExerciciosRealizadosTableTableManager(
        _db.attachedDatabase,
        _db.exerciciosRealizados,
      );
  $$SeriesRealizadasTableTableManager get seriesRealizadas =>
      $$SeriesRealizadasTableTableManager(
        _db.attachedDatabase,
        _db.seriesRealizadas,
      );
}
