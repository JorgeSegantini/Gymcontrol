import 'package:drift/drift.dart';

@DataClassName('BibliotecaMetadataRegistro')
class BibliotecaMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get versao => integer()();

  TextColumn get dataVersao => text().withLength(min: 1, max: 30)();

  DateTimeColumn get instaladoEm =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get hash => text().nullable()();

  IntColumn get quantidadeGrupos => integer().withDefault(const Constant(0))();

  IntColumn get quantidadeCategoriasEquipamentos =>
      integer().withDefault(const Constant(0))();

  IntColumn get quantidadeEquipamentos =>
      integer().withDefault(const Constant(0))();

  IntColumn get quantidadePadroesMotores =>
      integer().withDefault(const Constant(0))();

  IntColumn get quantidadeMovimentos =>
      integer().withDefault(const Constant(0))();

  IntColumn get quantidadeVariacoes =>
      integer().withDefault(const Constant(0))();

  IntColumn get quantidadeNiveis => integer().withDefault(const Constant(0))();

  IntColumn get quantidadeTags => integer().withDefault(const Constant(0))();

  IntColumn get quantidadeAliases => integer().withDefault(const Constant(0))();

  IntColumn get quantidadeExercicios =>
      integer().withDefault(const Constant(0))();
}

abstract class BibliotecaCatalogoBase extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get codigo => text().withLength(min: 1, max: 20).unique()();

  TextColumn get nome => text().withLength(min: 1, max: 150)();

  TextColumn get nomeNormalizado => text().withLength(min: 1, max: 150)();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BibliotecaGrupoMuscular')
class BibliotecaGruposMusculares extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaCategoriaEquipamento')
class BibliotecaCategoriasEquipamentos extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaPadraoMotor')
class BibliotecaPadroesMotores extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaMovimento')
class BibliotecaMovimentos extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaVariacao')
class BibliotecaVariacoes extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaNivel')
class BibliotecaNiveis extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaTag')
class BibliotecaTags extends BibliotecaCatalogoBase {}

@DataClassName('BibliotecaEquipamento')
class BibliotecaEquipamentos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get codigo => text().withLength(min: 1, max: 20).unique()();

  TextColumn get categoriaCodigo => text().references(
    BibliotecaCategoriasEquipamentos,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get nome => text().withLength(min: 1, max: 150)();

  TextColumn get nomeNormalizado => text().withLength(min: 1, max: 150)();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BibliotecaAlias')
class BibliotecaAliases extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get codigo => text().withLength(min: 1, max: 20).unique()();

  TextColumn get nome => text().withLength(min: 1, max: 150)();

  TextColumn get nomeNormalizado => text().withLength(min: 1, max: 150)();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BibliotecaExercicio')
class BibliotecaExercicios extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get codigo => text().withLength(min: 1, max: 20).unique()();

  TextColumn get nome => text().withLength(min: 1, max: 150)();

  TextColumn get nomeNormalizado => text().withLength(min: 1, max: 150)();

  TextColumn get movimentoCodigo => text().nullable().references(
    BibliotecaMovimentos,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get variacaoCodigo => text().nullable().references(
    BibliotecaVariacoes,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get padraoMotorCodigo => text().nullable().references(
    BibliotecaPadroesMotores,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get nivelCodigo => text().nullable().references(
    BibliotecaNiveis,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get descricao => text().nullable()();

  TextColumn get instrucoesJson => text().nullable()();

  TextColumn get dicasJson => text().nullable()();

  TextColumn get errosComunsJson => text().nullable()();

  BoolColumn get unilateral => boolean().withDefault(const Constant(false))();

  BoolColumn get usaPesoCorporal =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get usaMaquina => boolean().withDefault(const Constant(false))();

  TextColumn get velocidadeExecucao =>
      text().withLength(min: 1, max: 30).nullable()();

  IntColumn get descansoPadraoSegundos => integer().nullable()();

  IntColumn get popularidade => integer().withDefault(const Constant(0))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BibliotecaExercicioGrupo')
class BibliotecaExerciciosGrupos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get exercicioCodigo => text().references(
    BibliotecaExercicios,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get grupoCodigo => text().references(
    BibliotecaGruposMusculares,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get tipoParticipacao => text().withLength(min: 1, max: 20)();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {exercicioCodigo, grupoCodigo},
  ];
}

@DataClassName('BibliotecaExercicioEquipamento')
class BibliotecaExerciciosEquipamentos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get exercicioCodigo => text().references(
    BibliotecaExercicios,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get equipamentoCodigo => text().references(
    BibliotecaEquipamentos,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  BoolColumn get obrigatorio => boolean().withDefault(const Constant(true))();

  IntColumn get ordem => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {exercicioCodigo, equipamentoCodigo},
  ];
}

@DataClassName('BibliotecaExercicioTag')
class BibliotecaExerciciosTags extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get exercicioCodigo => text().references(
    BibliotecaExercicios,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get tagCodigo => text().references(
    BibliotecaTags,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  @override
  List<Set<Column>> get uniqueKeys => [
    {exercicioCodigo, tagCodigo},
  ];
}

@DataClassName('BibliotecaExercicioAlias')
class BibliotecaExerciciosAliases extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get exercicioCodigo => text().references(
    BibliotecaExercicios,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get aliasCodigo => text().references(
    BibliotecaAliases,
    #codigo,
    onDelete: KeyAction.restrict,
  )();

  @override
  List<Set<Column>> get uniqueKeys => [
    {exercicioCodigo, aliasCodigo},
  ];
}
