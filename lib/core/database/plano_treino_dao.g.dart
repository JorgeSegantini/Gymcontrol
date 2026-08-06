// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plano_treino_dao.dart';

// ignore_for_file: type=lint
mixin _$PlanoTreinoDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlanosTreinoTable get planosTreino => attachedDatabase.planosTreino;
  $FichasTreinoTable get fichasTreino => attachedDatabase.fichasTreino;
  $PlanosTreinoItensTable get planosTreinoItens =>
      attachedDatabase.planosTreinoItens;
  $TreinosRealizadosTable get treinosRealizados =>
      attachedDatabase.treinosRealizados;
  $PlanosTreinoExecucoesTable get planosTreinoExecucoes =>
      attachedDatabase.planosTreinoExecucoes;
  PlanoTreinoDaoManager get managers => PlanoTreinoDaoManager(this);
}

class PlanoTreinoDaoManager {
  final _$PlanoTreinoDaoMixin _db;
  PlanoTreinoDaoManager(this._db);
  $$PlanosTreinoTableTableManager get planosTreino =>
      $$PlanosTreinoTableTableManager(_db.attachedDatabase, _db.planosTreino);
  $$FichasTreinoTableTableManager get fichasTreino =>
      $$FichasTreinoTableTableManager(_db.attachedDatabase, _db.fichasTreino);
  $$PlanosTreinoItensTableTableManager get planosTreinoItens =>
      $$PlanosTreinoItensTableTableManager(
        _db.attachedDatabase,
        _db.planosTreinoItens,
      );
  $$TreinosRealizadosTableTableManager get treinosRealizados =>
      $$TreinosRealizadosTableTableManager(
        _db.attachedDatabase,
        _db.treinosRealizados,
      );
  $$PlanosTreinoExecucoesTableTableManager get planosTreinoExecucoes =>
      $$PlanosTreinoExecucoesTableTableManager(
        _db.attachedDatabase,
        _db.planosTreinoExecucoes,
      );
}
