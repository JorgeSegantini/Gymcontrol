import 'package:drift/drift.dart';

enum SituacaoTreinoRealizado { emAndamento, concluido, cancelado }

enum SituacaoExercicioRealizado { pendente, emExecucao, concluido, pulado }

enum SituacaoSerieRealizada { pendente, concluida, pulada }

@DataClassName('TreinoRealizado')
class TreinosRealizados extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get fichaTreinoOrigemId => integer().nullable()();

  TextColumn get nomeFichaSnapshot => text().withLength(min: 1, max: 100)();

  TextColumn get descricaoFichaSnapshot => text().nullable()();

  IntColumn get corArgbSnapshot =>
      integer().withDefault(const Constant(0xFF1976D2))();

  TextColumn get situacao =>
      text().withDefault(const Constant('emAndamento'))();

  DateTimeColumn get iniciadoEm => dateTime()();

  DateTimeColumn get finalizadoEm => dateTime().nullable()();

  TextColumn get observacoes => text().nullable()();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ExercicioRealizado')
class ExerciciosRealizados extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get treinoRealizadoId => integer().references(
    TreinosRealizados,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get fichaExercicioOrigemId => integer().nullable()();

  IntColumn get exercicioOrigemId => integer().nullable()();

  TextColumn get nomeExercicioSnapshot => text().withLength(min: 1, max: 150)();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  IntColumn get rirPlanejado => integer().nullable()();

  TextColumn get observacoesPlanejadas => text().nullable()();

  TextColumn get situacao => text().withDefault(const Constant('pendente'))();

  DateTimeColumn get iniciadoEm => dateTime().nullable()();

  DateTimeColumn get finalizadoEm => dateTime().nullable()();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SerieRealizada')
class SeriesRealizadas extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get exercicioRealizadoId => integer().references(
    ExerciciosRealizados,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get fichaExercicioSerieOrigemId => integer().nullable()();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  TextColumn get tipoSerie => text().withDefault(const Constant('normal'))();

  IntColumn get repeticoesMinimasPlanejadas => integer().nullable()();

  IntColumn get repeticoesMaximasPlanejadas => integer().nullable()();

  IntColumn get cargaPlanejadaGramas => integer().nullable()();

  IntColumn get incrementoCargaGramas => integer().nullable()();

  IntColumn get descansoPlanejadoSegundos =>
      integer().withDefault(const Constant(0))();

  IntColumn get tempoExecucaoPlanejadoSegundos => integer().nullable()();

  TextColumn get observacoesPlanejadas => text().nullable()();

  TextColumn get situacao => text().withDefault(const Constant('pendente'))();

  IntColumn get cargaRealizadaGramas => integer().nullable()();

  IntColumn get repeticoesRealizadas => integer().nullable()();

  IntColumn get rirRealizado => integer().nullable()();

  IntColumn get descansoRealizadoSegundos => integer().nullable()();

  IntColumn get tempoExecucaoRealizadoSegundos => integer().nullable()();

  DateTimeColumn get iniciadoEm => dateTime().nullable()();

  DateTimeColumn get finalizadoEm => dateTime().nullable()();

  TextColumn get observacoesRealizadas => text().nullable()();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}
