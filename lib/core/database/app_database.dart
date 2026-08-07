import 'package:drift/drift.dart';

import 'biblioteca_tables.dart';
import 'database_connection.dart';
import 'exercicio_dao.dart';
import 'ficha_treino_dao.dart';
import 'grupo_muscular_dao.dart';
import 'medida_corporal_dao.dart';
import 'plano_treino_dao.dart';
import 'peso_corporal_dao.dart';
import 'treino_realizado_dao.dart';
import 'treino_tables.dart';

part 'app_database.g.dart';

enum OrigemGrupoMuscular { biblioteca, personalizado }

enum TipoExercicio { musculacao, cardio, mobilidade, alongamento }

enum OrigemExercicio { biblioteca, personalizado }

enum EquipamentoExercicio {
  barra,
  halteres,
  maquina,
  polia,
  smith,
  pesoCorporal,
  kettlebell,
  elastico,
  bolaSuica,
  trx,
  banco,
  outro,
}

enum NivelDificuldadeExercicio { iniciante, intermediario, avancado }

enum VelocidadeExecucao { controlada, explosiva, lenta }

enum TipoSerie {
  normal,
  aquecimento,
  dropSet,
  restPause,
  biSet,
  triSet,
  cluster,
  isometrica,
}

enum SituacaoPlanoTreino { ativo, pausado, encerrado }

enum TipoPlanoTreinoItem { treino, descanso, cardio, mobilidade, personalizado }

enum SituacaoPlanoTreinoExecucao {
  prevista,
  iniciada,
  concluida,
  pulada,
  substituida,
}

@DataClassName('GrupoMuscular')
class GruposMusculares extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text().withLength(min: 1, max: 100).unique()();

  TextColumn get origem =>
      text().withDefault(const Constant('personalizado'))();

  TextColumn get codigoBiblioteca =>
      text().withLength(min: 1, max: 100).nullable()();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Exercicio')
class Exercicios extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get grupoMuscularId => integer().references(
    GruposMusculares,
    #id,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get nome => text().withLength(min: 1, max: 150)();

  TextColumn get nomeCurto => text().withLength(min: 1, max: 100).nullable()();

  TextColumn get tipo => text().withDefault(const Constant('musculacao'))();

  TextColumn get origem =>
      text().withDefault(const Constant('personalizado'))();

  TextColumn get codigoBiblioteca =>
      text().withLength(min: 1, max: 100).nullable().unique()();

  TextColumn get equipamento => text().withDefault(const Constant('outro'))();

  TextColumn get nivelDificuldade =>
      text().withDefault(const Constant('iniciante'))();

  TextColumn get velocidadeExecucao =>
      text().withDefault(const Constant('controlada'))();

  TextColumn get familia => text().withLength(min: 1, max: 100).nullable()();

  TextColumn get variante => text().withLength(min: 1, max: 100).nullable()();

  IntColumn get popularidade => integer().withDefault(const Constant(0))();

  TextColumn get instrucoes => text().nullable()();

  TextColumn get dicas => text().nullable()();

  TextColumn get errosComuns => text().nullable()();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {grupoMuscularId, nome},
  ];
}

@DataClassName('FichaTreino')
class FichasTreino extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text().withLength(min: 1, max: 100).unique()();

  TextColumn get descricao => text().withLength(min: 1, max: 1000).nullable()();

  IntColumn get corArgb => integer().withDefault(const Constant(0xFF1976D2))();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('FichaExercicio')
class FichasExercicios extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get fichaTreinoId =>
      integer().references(FichasTreino, #id, onDelete: KeyAction.cascade)();

  IntColumn get exercicioId =>
      integer().references(Exercicios, #id, onDelete: KeyAction.restrict)();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  TextColumn get observacoes => text().nullable()();

  IntColumn get rirPlanejado => integer().nullable()();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {fichaTreinoId, exercicioId},
  ];
}

@DataClassName('FichaExercicioSerie')
class FichasExerciciosSeries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get fichaExercicioId => integer().references(
    FichasExercicios,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  TextColumn get tipoSerie => text().withDefault(const Constant('normal'))();

  IntColumn get repeticoesMinimas => integer().nullable()();

  IntColumn get repeticoesMaximas => integer().nullable()();

  IntColumn get cargaPlanejadaGramas => integer().nullable()();

  IntColumn get incrementoCargaGramas => integer().nullable()();

  IntColumn get descansoSegundos => integer().withDefault(const Constant(0))();

  IntColumn get tempoExecucaoSegundos => integer().nullable()();

  TextColumn get observacoes => text().nullable()();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PlanoTreino')
class PlanosTreino extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text().withLength(min: 1, max: 120)();

  TextColumn get descricao => text().withLength(min: 1, max: 1000).nullable()();

  TextColumn get objetivo => text().withLength(min: 1, max: 250).nullable()();

  TextColumn get situacao => text().withDefault(const Constant('pausado'))();

  IntColumn get corArgb => integer().withDefault(const Constant(0xFF1976D2))();

  TextColumn get icone =>
      text().withDefault(const Constant('fitness_center'))();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  BoolColumn get favorito => boolean().withDefault(const Constant(false))();

  // Mantido temporariamente para preservar bancos criados na versão 10.
  // As regras novas usam o campo situacao.
  BoolColumn get ativo => boolean().withDefault(const Constant(false))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PlanoTreinoItem')
class PlanosTreinoItens extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planoTreinoId =>
      integer().references(PlanosTreino, #id, onDelete: KeyAction.cascade)();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  TextColumn get codigo => text().withLength(min: 1, max: 20).nullable()();

  TextColumn get nome => text().withLength(min: 1, max: 120)();

  TextColumn get descricao => text().withLength(min: 1, max: 500).nullable()();

  TextColumn get tipo => text().withDefault(const Constant('treino'))();

  IntColumn get fichaTreinoId => integer().nullable().references(
    FichasTreino,
    #id,
    onDelete: KeyAction.setNull,
  )();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {planoTreinoId, ordem},
  ];
}

@DataClassName('PlanoTreinoExecucao')
class PlanosTreinoExecucoes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planoTreinoId =>
      integer().references(PlanosTreino, #id, onDelete: KeyAction.restrict)();

  IntColumn get planoTreinoItemId => integer().references(
    PlanosTreinoItens,
    #id,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get treinoRealizadoId => integer().nullable().references(
    TreinosRealizados,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get fichaPlanejadaId => integer().nullable().references(
    FichasTreino,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get fichaExecutadaId => integer().nullable().references(
    FichasTreino,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get codigoItemSnapshot =>
      text().withLength(min: 1, max: 20).nullable()();

  TextColumn get nomeItemSnapshot => text().withLength(min: 1, max: 120)();

  TextColumn get tipoItemSnapshot => text().withLength(min: 1, max: 30)();

  DateTimeColumn get dataReferencia => dateTime()();

  TextColumn get situacao => text().withDefault(const Constant('prevista'))();

  TextColumn get observacoes =>
      text().withLength(min: 1, max: 1000).nullable()();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PesoCorporal')
class PesosCorporais extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get data => dateTime().unique()();

  IntColumn get pesoGramas => integer()();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MedidaCorporal')
class MedidasCorporais extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get data => dateTime().unique()();

  IntColumn get pescocoMilimetros => integer().nullable()();

  IntColumn get ombrosMilimetros => integer().nullable()();

  IntColumn get peitoMilimetros => integer().nullable()();

  IntColumn get cinturaMilimetros => integer().nullable()();

  IntColumn get abdomenMilimetros => integer().nullable()();

  IntColumn get quadrilMilimetros => integer().nullable()();

  IntColumn get bracoDireitoMilimetros => integer().nullable()();

  IntColumn get bracoEsquerdoMilimetros => integer().nullable()();

  IntColumn get coxaDireitaMilimetros => integer().nullable()();

  IntColumn get coxaEsquerdaMilimetros => integer().nullable()();

  IntColumn get panturrilhaDireitaMilimetros => integer().nullable()();

  IntColumn get panturrilhaEsquerdaMilimetros => integer().nullable()();

  TextColumn get observacoes =>
      text().withLength(min: 1, max: 1000).nullable()();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    GruposMusculares,
    Exercicios,
    FichasTreino,
    FichasExercicios,
    FichasExerciciosSeries,
    TreinosRealizados,
    ExerciciosRealizados,
    SeriesRealizadas,
    PlanosTreino,
    PlanosTreinoItens,
    PlanosTreinoExecucoes,
    PesosCorporais,
    MedidasCorporais,
    BibliotecaMetadata,
    BibliotecaGruposMusculares,
    BibliotecaCategoriasEquipamentos,
    BibliotecaEquipamentos,
    BibliotecaPadroesMotores,
    BibliotecaMovimentos,
    BibliotecaVariacoes,
    BibliotecaNiveis,
    BibliotecaTags,
    BibliotecaAliases,
    BibliotecaExercicios,
    BibliotecaExerciciosGrupos,
    BibliotecaExerciciosEquipamentos,
    BibliotecaExerciciosTags,
    BibliotecaExerciciosAliases,
  ],
  daos: [
    GrupoMuscularDao,
    ExercicioDao,
    FichaTreinoDao,
    TreinoRealizadoDao,
    PlanoTreinoDao,
    PesoCorporalDao,
    MedidaCorporalDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(abrirConexaoBanco());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(fichasTreino);
          await migrator.createTable(fichasExercicios);
        }

        if (from == 2 && to >= 3) {
          await migrator.addColumn(
            fichasExercicios,
            fichasExercicios.observacoes,
          );
          await migrator.addColumn(fichasExercicios, fichasExercicios.ativo);
        }

        if (from < 4) {
          await migrator.createTable(fichasExerciciosSeries);
        }

        if (from >= 2 && from < 5) {
          await migrator.addColumn(fichasTreino, fichasTreino.corArgb);
        }

        if (from < 6) {
          await migrator.addColumn(
            fichasExercicios,
            fichasExercicios.rirPlanejado,
          );
        }

        if (from < 7) {
          await migrator.createTable(treinosRealizados);
          await migrator.createTable(exerciciosRealizados);
          await migrator.createTable(seriesRealizadas);
        }

        if (from < 8) {
          await migrator.addColumn(gruposMusculares, gruposMusculares.origem);
          await migrator.addColumn(
            gruposMusculares,
            gruposMusculares.codigoBiblioteca,
          );
        }

        if (from < 9) {
          await migrator.addColumn(exercicios, exercicios.nomeCurto);
          await migrator.addColumn(exercicios, exercicios.popularidade);
        }

        if (from < 10) {
          await migrator.createTable(planosTreino);
          await migrator.createTable(planosTreinoItens);
          await migrator.createTable(planosTreinoExecucoes);
        }

        if (from == 10 && to >= 11) {
          await migrator.addColumn(planosTreino, planosTreino.situacao);
          await migrator.addColumn(planosTreino, planosTreino.corArgb);
          await migrator.addColumn(planosTreino, planosTreino.icone);
          await migrator.addColumn(planosTreino, planosTreino.ordem);
          await migrator.addColumn(planosTreino, planosTreino.favorito);
        }

        if (from < 12) {
          await migrator.createTable(pesosCorporais);
        }

        if (from < 13) {
          await migrator.createTable(medidasCorporais);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
