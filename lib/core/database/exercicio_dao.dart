import 'package:drift/drift.dart';

import 'app_database.dart';
import 'dados_exercicio.dart';

part 'exercicio_dao.g.dart';

@DriftAccessor(tables: [Exercicios])
class ExercicioDao extends DatabaseAccessor<AppDatabase>
    with _$ExercicioDaoMixin {
  ExercicioDao(super.database);

  Stream<List<Exercicio>> observarTodos() {
    return (select(exercicios)..orderBy([
          (tabela) => OrderingTerm.desc(tabela.popularidade),
          (tabela) => OrderingTerm.asc(tabela.ordem),
          (tabela) => OrderingTerm.asc(tabela.nome),
        ]))
        .watch();
  }

  Stream<List<Exercicio>> observarAtivos() {
    return (select(exercicios)
          ..where((tabela) => tabela.ativo.equals(true))
          ..orderBy([
            (tabela) => OrderingTerm.desc(tabela.popularidade),
            (tabela) => OrderingTerm.asc(tabela.ordem),
            (tabela) => OrderingTerm.asc(tabela.nome),
          ]))
        .watch();
  }

  Stream<List<Exercicio>> observarBiblioteca({bool incluirInativos = false}) {
    final consulta = select(exercicios)
      ..where(
        (tabela) =>
            tabela.origem.equals(OrigemExercicio.biblioteca.name) &
            (incluirInativos
                ? const Constant(true)
                : tabela.ativo.equals(true)),
      )
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.grupoMuscularId),
        (tabela) => OrderingTerm.desc(tabela.popularidade),
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.nome),
      ]);

    return consulta.watch();
  }

  Stream<List<Exercicio>> observarPersonalizados({
    bool incluirInativos = true,
  }) {
    final consulta = select(exercicios)
      ..where(
        (tabela) =>
            tabela.origem.equals(OrigemExercicio.personalizado.name) &
            (incluirInativos
                ? const Constant(true)
                : tabela.ativo.equals(true)),
      )
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.nome),
      ]);

    return consulta.watch();
  }

  Stream<List<Exercicio>> observarPorGrupoMuscular(
    int grupoMuscularId, {
    bool incluirInativos = true,
  }) {
    final consulta = select(exercicios)
      ..where(
        (tabela) =>
            tabela.grupoMuscularId.equals(grupoMuscularId) &
            (incluirInativos
                ? const Constant(true)
                : tabela.ativo.equals(true)),
      )
      ..orderBy([
        (tabela) => OrderingTerm.desc(tabela.popularidade),
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.nome),
      ]);

    return consulta.watch();
  }

  Future<List<Exercicio>> pesquisar(
    String termo, {
    OrigemExercicio? origem,
    int? grupoMuscularId,
    EquipamentoExercicio? equipamento,
    NivelDificuldadeExercicio? nivelDificuldade,
    VelocidadeExecucao? velocidadeExecucao,
    bool incluirInativos = false,
  }) {
    final textoPesquisa = termo.trim().toLowerCase();
    final consulta = select(exercicios);

    consulta.where((tabela) {
      Expression<bool> filtro = incluirInativos
          ? const Constant(true)
          : tabela.ativo.equals(true);

      if (textoPesquisa.isNotEmpty) {
        final padrao = '%$textoPesquisa%';

        filtro =
            filtro &
            (tabela.nome.lower().like(padrao) |
                tabela.nomeCurto.lower().like(padrao) |
                tabela.familia.lower().like(padrao) |
                tabela.variante.lower().like(padrao) |
                tabela.codigoBiblioteca.lower().like(padrao));
      }

      if (origem != null) {
        filtro = filtro & tabela.origem.equals(origem.name);
      }

      if (grupoMuscularId != null) {
        filtro = filtro & tabela.grupoMuscularId.equals(grupoMuscularId);
      }

      if (equipamento != null) {
        filtro = filtro & tabela.equipamento.equals(equipamento.name);
      }

      if (nivelDificuldade != null) {
        filtro = filtro & tabela.nivelDificuldade.equals(nivelDificuldade.name);
      }

      if (velocidadeExecucao != null) {
        filtro =
            filtro & tabela.velocidadeExecucao.equals(velocidadeExecucao.name);
      }

      return filtro;
    });

    consulta.orderBy([
      (tabela) => OrderingTerm.desc(tabela.popularidade),
      (tabela) => OrderingTerm.asc(tabela.ordem),
      (tabela) => OrderingTerm.asc(tabela.nome),
    ]);

    return consulta.get();
  }

  Future<Exercicio?> obterPorId(int id) {
    return (select(
      exercicios,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<Exercicio?> obterPorCodigoBiblioteca(String codigo) {
    return (select(exercicios)..where(
          (tabela) =>
              tabela.codigoBiblioteca.equals(codigo.trim().toLowerCase()),
        ))
        .getSingleOrNull();
  }

  Future<int> cadastrar({
    required int grupoMuscularId,
    required String nome,
    required TipoExercicio tipo,
    String? instrucoes,
    required int ordem,
  }) {
    final dados = DadosExercicio(
      grupoMuscularId: grupoMuscularId,
      nome: nome,
      nomeCurto: nome,
      tipo: tipo,
      equipamento: EquipamentoExercicio.outro,
      nivelDificuldade: NivelDificuldadeExercicio.iniciante,
      velocidadeExecucao: VelocidadeExecucao.controlada,
      instrucoes: instrucoes,
      ordem: ordem,
    );

    return cadastrarPersonalizado(dados);
  }

  Future<bool> editar({
    required int id,
    required int grupoMuscularId,
    required String nome,
    required TipoExercicio tipo,
    String? instrucoes,
    required int ordem,
  }) async {
    final quantidadeAlterada =
        await (update(
          exercicios,
        )..where((tabela) => tabela.id.equals(id))).write(
          ExerciciosCompanion(
            grupoMuscularId: Value(grupoMuscularId),
            nome: Value(nome.trim()),
            nomeCurto: Value(nome.trim()),
            tipo: Value(tipo.name),
            instrucoes: Value(_normalizarTextoOpcional(instrucoes)),
            ordem: Value(ordem),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return quantidadeAlterada > 0;
  }

  Future<int> cadastrarPersonalizado(DadosExercicio dados) {
    final agora = DateTime.now();

    return into(exercicios).insert(
      ExerciciosCompanion.insert(
        grupoMuscularId: dados.grupoMuscularId,
        nome: dados.nome.trim(),
        nomeCurto: Value(_nomeCurto(dados)),
        tipo: Value(dados.tipo.name),
        origem: Value(OrigemExercicio.personalizado.name),
        codigoBiblioteca: const Value(null),
        equipamento: Value(dados.equipamento.name),
        nivelDificuldade: Value(dados.nivelDificuldade.name),
        velocidadeExecucao: Value(dados.velocidadeExecucao.name),
        familia: Value(_normalizarTextoOpcional(dados.familia)),
        variante: Value(_normalizarTextoOpcional(dados.variante)),
        popularidade: Value(dados.popularidade),
        instrucoes: Value(_normalizarTextoOpcional(dados.instrucoes)),
        dicas: Value(_normalizarTextoOpcional(dados.dicas)),
        errosComuns: Value(_normalizarTextoOpcional(dados.errosComuns)),
        ordem: Value(dados.ordem),
        criadoEm: Value(agora),
        atualizadoEm: Value(agora),
      ),
    );
  }

  Future<bool> editarPersonalizado({
    required int id,
    required DadosExercicio dados,
  }) async {
    final exercicio = await obterPorId(id);

    if (exercicio == null ||
        converterOrigem(exercicio.origem) != OrigemExercicio.personalizado) {
      return false;
    }

    final quantidadeAlterada =
        await (update(
          exercicios,
        )..where((tabela) => tabela.id.equals(id))).write(
          ExerciciosCompanion(
            grupoMuscularId: Value(dados.grupoMuscularId),
            nome: Value(dados.nome.trim()),
            nomeCurto: Value(_nomeCurto(dados)),
            tipo: Value(dados.tipo.name),
            equipamento: Value(dados.equipamento.name),
            nivelDificuldade: Value(dados.nivelDificuldade.name),
            velocidadeExecucao: Value(dados.velocidadeExecucao.name),
            familia: Value(_normalizarTextoOpcional(dados.familia)),
            variante: Value(_normalizarTextoOpcional(dados.variante)),
            popularidade: Value(dados.popularidade),
            instrucoes: Value(_normalizarTextoOpcional(dados.instrucoes)),
            dicas: Value(_normalizarTextoOpcional(dados.dicas)),
            errosComuns: Value(_normalizarTextoOpcional(dados.errosComuns)),
            ordem: Value(dados.ordem),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return quantidadeAlterada > 0;
  }

  Future<int> cadastrarOuAtualizarBiblioteca(DadosExercicio dados) async {
    final codigo = _normalizarCodigoBiblioteca(dados.codigoBiblioteca);
    final existente = await obterPorCodigoBiblioteca(codigo);
    final agora = DateTime.now();

    if (existente == null) {
      return into(exercicios).insert(
        ExerciciosCompanion.insert(
          grupoMuscularId: dados.grupoMuscularId,
          nome: dados.nome.trim(),
          nomeCurto: Value(_nomeCurto(dados)),
          tipo: Value(dados.tipo.name),
          origem: Value(OrigemExercicio.biblioteca.name),
          codigoBiblioteca: Value(codigo),
          equipamento: Value(dados.equipamento.name),
          nivelDificuldade: Value(dados.nivelDificuldade.name),
          velocidadeExecucao: Value(dados.velocidadeExecucao.name),
          familia: Value(_normalizarTextoOpcional(dados.familia)),
          variante: Value(_normalizarTextoOpcional(dados.variante)),
          popularidade: Value(dados.popularidade),
          instrucoes: Value(_normalizarTextoOpcional(dados.instrucoes)),
          dicas: Value(_normalizarTextoOpcional(dados.dicas)),
          errosComuns: Value(_normalizarTextoOpcional(dados.errosComuns)),
          ordem: Value(dados.ordem),
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );
    }

    await (update(
      exercicios,
    )..where((tabela) => tabela.id.equals(existente.id))).write(
      ExerciciosCompanion(
        grupoMuscularId: Value(dados.grupoMuscularId),
        nome: Value(dados.nome.trim()),
        nomeCurto: Value(_nomeCurto(dados)),
        tipo: Value(dados.tipo.name),
        origem: Value(OrigemExercicio.biblioteca.name),
        codigoBiblioteca: Value(codigo),
        equipamento: Value(dados.equipamento.name),
        nivelDificuldade: Value(dados.nivelDificuldade.name),
        velocidadeExecucao: Value(dados.velocidadeExecucao.name),
        familia: Value(_normalizarTextoOpcional(dados.familia)),
        variante: Value(_normalizarTextoOpcional(dados.variante)),
        popularidade: Value(dados.popularidade),
        instrucoes: Value(_normalizarTextoOpcional(dados.instrucoes)),
        dicas: Value(_normalizarTextoOpcional(dados.dicas)),
        errosComuns: Value(_normalizarTextoOpcional(dados.errosComuns)),
        ativo: const Value(true),
        ordem: Value(dados.ordem),
        atualizadoEm: Value(agora),
      ),
    );

    return existente.id;
  }

  Future<bool> salvarAnotacoesPessoais({
    required int id,
    String? anotacoesPessoais,
  }) async {
    final quantidadeAlterada =
        await (update(
          exercicios,
        )..where((tabela) => tabela.id.equals(id))).write(
          ExerciciosCompanion(
            anotacoesPessoais: Value(
              _normalizarTextoOpcional(anotacoesPessoais),
            ),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return quantidadeAlterada > 0;
  }

  Future<bool> alterarSituacao({required int id, required bool ativo}) async {
    final quantidadeAlterada =
        await (update(
          exercicios,
        )..where((tabela) => tabela.id.equals(id))).write(
          ExerciciosCompanion(
            ativo: Value(ativo),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return quantidadeAlterada > 0;
  }

  TipoExercicio converterTipo(String valor) {
    return TipoExercicio.values.firstWhere(
      (tipo) => tipo.name == valor,
      orElse: () => TipoExercicio.musculacao,
    );
  }

  OrigemExercicio converterOrigem(String valor) {
    return OrigemExercicio.values.firstWhere(
      (origem) => origem.name == valor,
      orElse: () => OrigemExercicio.personalizado,
    );
  }

  EquipamentoExercicio converterEquipamento(String valor) {
    return EquipamentoExercicio.values.firstWhere(
      (equipamento) => equipamento.name == valor,
      orElse: () => EquipamentoExercicio.outro,
    );
  }

  NivelDificuldadeExercicio converterNivelDificuldade(String valor) {
    return NivelDificuldadeExercicio.values.firstWhere(
      (nivel) => nivel.name == valor,
      orElse: () => NivelDificuldadeExercicio.iniciante,
    );
  }

  VelocidadeExecucao converterVelocidadeExecucao(String valor) {
    return VelocidadeExecucao.values.firstWhere(
      (velocidade) => velocidade.name == valor,
      orElse: () => VelocidadeExecucao.controlada,
    );
  }

  String _normalizarCodigoBiblioteca(String? codigo) {
    final valor = codigo?.trim().toLowerCase();

    if (valor == null || valor.isEmpty) {
      throw ArgumentError('O código da biblioteca é obrigatório.');
    }

    return valor;
  }

  String _nomeCurto(DadosExercicio dados) {
    final nomeCurto = dados.nomeCurto?.trim();

    if (nomeCurto == null || nomeCurto.isEmpty) {
      return dados.nome.trim();
    }

    return nomeCurto;
  }

  String? _normalizarTextoOpcional(String? texto) {
    final valor = texto?.trim();

    if (valor == null || valor.isEmpty) {
      return null;
    }

    return valor;
  }
}
