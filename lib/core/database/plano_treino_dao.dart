import 'package:drift/drift.dart';

import 'app_database.dart';
import 'treino_tables.dart';

part 'plano_treino_dao.g.dart';

@DriftAccessor(
  tables: [
    PlanosTreino,
    PlanosTreinoItens,
    PlanosTreinoExecucoes,
    FichasTreino,
    TreinosRealizados,
  ],
)
class PlanoTreinoDao extends DatabaseAccessor<AppDatabase>
    with _$PlanoTreinoDaoMixin {
  PlanoTreinoDao(super.database);

  Stream<List<PlanoTreino>> observarPlanos({bool incluirEncerrados = true}) {
    final consulta = select(planosTreino);

    if (!incluirEncerrados) {
      consulta.where(
        (tabela) =>
            tabela.situacao.isNotValue(SituacaoPlanoTreino.encerrado.name),
      );
    }

    consulta.orderBy([
      (tabela) => OrderingTerm.desc(tabela.favorito),
      (tabela) => OrderingTerm.asc(tabela.ordem),
      (tabela) => OrderingTerm.asc(tabela.nome),
      (tabela) => OrderingTerm.asc(tabela.id),
    ]);

    return consulta.watch();
  }

  Future<List<PlanoTreino>> listarPlanos({bool incluirEncerrados = true}) {
    final consulta = select(planosTreino);

    if (!incluirEncerrados) {
      consulta.where(
        (tabela) =>
            tabela.situacao.isNotValue(SituacaoPlanoTreino.encerrado.name),
      );
    }

    consulta.orderBy([
      (tabela) => OrderingTerm.desc(tabela.favorito),
      (tabela) => OrderingTerm.asc(tabela.ordem),
      (tabela) => OrderingTerm.asc(tabela.nome),
      (tabela) => OrderingTerm.asc(tabela.id),
    ]);

    return consulta.get();
  }

  Future<PlanoTreino?> obterPlano(int id) {
    return (select(
      planosTreino,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<int> criarPlano({
    required String nome,
    String? descricao,
    String? objetivo,
    int corArgb = 0xFF1976D2,
    String icone = 'fitness_center',
    int? ordem,
    bool favorito = false,
  }) async {
    final nomeTratado = _validarTextoObrigatorio(
      nome,
      campo: 'nome',
      maximo: 120,
    );
    final descricaoTratada = _validarTextoOpcional(
      descricao,
      campo: 'descrição',
      maximo: 1000,
    );
    final objetivoTratado = _validarTextoOpcional(
      objetivo,
      campo: 'objetivo',
      maximo: 250,
    );
    final iconeTratado = _validarTextoObrigatorio(
      icone,
      campo: 'ícone',
      maximo: 100,
    );

    final proximaOrdem = ordem ?? await _obterProximaOrdemPlano();
    final agora = DateTime.now();

    return into(planosTreino).insert(
      PlanosTreinoCompanion.insert(
        nome: nomeTratado,
        descricao: Value(descricaoTratada),
        objetivo: Value(objetivoTratado),
        situacao: Value(SituacaoPlanoTreino.pausado.name),
        corArgb: Value(corArgb),
        icone: Value(iconeTratado),
        ordem: Value(proximaOrdem),
        favorito: Value(favorito),
        ativo: const Value(false),
        criadoEm: Value(agora),
        atualizadoEm: Value(agora),
      ),
    );
  }

  Future<bool> editarPlano({
    required int id,
    required String nome,
    String? descricao,
    String? objetivo,
    required int corArgb,
    required String icone,
    required int ordem,
    required bool favorito,
  }) async {
    final plano = await obterPlano(id);

    if (plano == null) {
      return false;
    }

    _garantirPlanoEditavel(plano);

    final nomeTratado = _validarTextoObrigatorio(
      nome,
      campo: 'nome',
      maximo: 120,
    );
    final descricaoTratada = _validarTextoOpcional(
      descricao,
      campo: 'descrição',
      maximo: 1000,
    );
    final objetivoTratado = _validarTextoOpcional(
      objetivo,
      campo: 'objetivo',
      maximo: 250,
    );
    final iconeTratado = _validarTextoObrigatorio(
      icone,
      campo: 'ícone',
      maximo: 100,
    );

    final alterados =
        await (update(
          planosTreino,
        )..where((tabela) => tabela.id.equals(id))).write(
          PlanosTreinoCompanion(
            nome: Value(nomeTratado),
            descricao: Value(descricaoTratada),
            objetivo: Value(objetivoTratado),
            corArgb: Value(corArgb),
            icone: Value(iconeTratado),
            ordem: Value(ordem),
            favorito: Value(favorito),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return alterados > 0;
  }

  Future<bool> excluirPlano(int id) async {
    return transaction(() async {
      final plano = await obterPlano(id);

      if (plano == null) {
        return false;
      }

      final quantidadeExecucoes = await _quantidadeExecucoesDoPlano(id);

      if (quantidadeExecucoes > 0) {
        throw StateError(
          'Não é possível excluir um plano que possui histórico. '
          'Encerre o plano em vez de excluí-lo.',
        );
      }

      final removidos = await (delete(
        planosTreino,
      )..where((tabela) => tabela.id.equals(id))).go();

      return removidos > 0;
    });
  }

  Stream<List<PlanoTreinoItem>> observarItens(int planoTreinoId) {
    final consulta = select(planosTreinoItens)
      ..where((tabela) => tabela.planoTreinoId.equals(planoTreinoId))
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.watch();
  }

  Future<List<PlanoTreinoItem>> listarItens(int planoTreinoId) {
    final consulta = select(planosTreinoItens)
      ..where((tabela) => tabela.planoTreinoId.equals(planoTreinoId))
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.get();
  }

  Future<PlanoTreinoItem?> obterItem(int id) {
    return (select(
      planosTreinoItens,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<int> adicionarItem({
    required int planoTreinoId,
    required TipoPlanoTreinoItem tipo,
    required String nome,
    String? codigo,
    String? descricao,
    int? fichaTreinoId,
    int? ordem,
    bool ativo = true,
  }) async {
    return transaction(() async {
      final plano = await obterPlano(planoTreinoId);

      if (plano == null) {
        throw ArgumentError('O plano de treino não foi encontrado.');
      }

      _garantirPlanoEditavel(plano);

      final nomeTratado = _validarTextoObrigatorio(
        nome,
        campo: 'nome do item',
        maximo: 120,
      );
      final codigoTratado = _validarTextoOpcional(
        codigo,
        campo: 'código',
        maximo: 20,
      );
      final descricaoTratada = _validarTextoOpcional(
        descricao,
        campo: 'descrição do item',
        maximo: 500,
      );

      await _validarFichaDoItem(tipo: tipo, fichaTreinoId: fichaTreinoId);

      final proximaOrdem = ordem ?? await _obterProximaOrdemItem(planoTreinoId);
      final agora = DateTime.now();

      final id = await into(planosTreinoItens).insert(
        PlanosTreinoItensCompanion.insert(
          planoTreinoId: planoTreinoId,
          ordem: Value(proximaOrdem),
          codigo: Value(codigoTratado),
          nome: nomeTratado,
          descricao: Value(descricaoTratada),
          tipo: Value(tipo.name),
          fichaTreinoId: Value(fichaTreinoId),
          ativo: Value(ativo),
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      await _atualizarPlano(planoTreinoId);

      return id;
    });
  }

  Future<bool> editarItem({
    required int id,
    required TipoPlanoTreinoItem tipo,
    required String nome,
    String? codigo,
    String? descricao,
    int? fichaTreinoId,
    required bool ativo,
  }) async {
    return transaction(() async {
      final item = await obterItem(id);

      if (item == null) {
        return false;
      }

      final plano = await obterPlano(item.planoTreinoId);

      if (plano == null) {
        throw StateError('O plano de treino não foi encontrado.');
      }

      _garantirPlanoEditavel(plano);

      final nomeTratado = _validarTextoObrigatorio(
        nome,
        campo: 'nome do item',
        maximo: 120,
      );
      final codigoTratado = _validarTextoOpcional(
        codigo,
        campo: 'código',
        maximo: 20,
      );
      final descricaoTratada = _validarTextoOpcional(
        descricao,
        campo: 'descrição do item',
        maximo: 500,
      );

      await _validarFichaDoItem(tipo: tipo, fichaTreinoId: fichaTreinoId);

      final alterados =
          await (update(
            planosTreinoItens,
          )..where((tabela) => tabela.id.equals(id))).write(
            PlanosTreinoItensCompanion(
              codigo: Value(codigoTratado),
              nome: Value(nomeTratado),
              descricao: Value(descricaoTratada),
              tipo: Value(tipo.name),
              fichaTreinoId: Value(fichaTreinoId),
              ativo: Value(ativo),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

      if (alterados > 0) {
        await _atualizarPlano(item.planoTreinoId);
      }

      return alterados > 0;
    });
  }

  Future<bool> removerItem(int id) async {
    return transaction(() async {
      final item = await obterItem(id);

      if (item == null) {
        return false;
      }

      final plano = await obterPlano(item.planoTreinoId);

      if (plano == null) {
        throw StateError('O plano de treino não foi encontrado.');
      }

      _garantirPlanoEditavel(plano);

      final quantidadeExecucoes = await _quantidadeExecucoesDoItem(item.id);

      if (quantidadeExecucoes > 0) {
        throw StateError(
          'Não é possível remover um item que possui histórico. '
          'Inative o item em vez de removê-lo.',
        );
      }

      final removidos = await (delete(
        planosTreinoItens,
      )..where((tabela) => tabela.id.equals(id))).go();

      if (removidos == 0) {
        return false;
      }

      await _normalizarOrdensItens(item.planoTreinoId);
      await _atualizarPlano(item.planoTreinoId);

      return true;
    });
  }

  Future<void> reordenarItens({
    required int planoTreinoId,
    required List<int> itensIds,
  }) async {
    if (itensIds.isEmpty) {
      return;
    }

    if (itensIds.toSet().length != itensIds.length) {
      throw ArgumentError('A lista de itens possui identificadores repetidos.');
    }

    await transaction(() async {
      final plano = await obterPlano(planoTreinoId);

      if (plano == null) {
        throw ArgumentError('O plano de treino não foi encontrado.');
      }

      _garantirPlanoEditavel(plano);

      final itens = await listarItens(planoTreinoId);
      final idsAtuais = itens.map((item) => item.id).toSet();
      final idsRecebidos = itensIds.toSet();

      if (idsAtuais.length != idsRecebidos.length ||
          !idsAtuais.containsAll(idsRecebidos)) {
        throw ArgumentError(
          'A nova ordem deve conter todos os itens do plano exatamente uma vez.',
        );
      }

      final agora = DateTime.now();

      // Usa valores negativos temporariamente para não colidir com a chave
      // única (planoTreinoId, ordem).
      for (var indice = 0; indice < itensIds.length; indice++) {
        await (update(
          planosTreinoItens,
        )..where((tabela) => tabela.id.equals(itensIds[indice]))).write(
          PlanosTreinoItensCompanion(
            ordem: Value(-(indice + 1)),
            atualizadoEm: Value(agora),
          ),
        );
      }

      for (var indice = 0; indice < itensIds.length; indice++) {
        await (update(
          planosTreinoItens,
        )..where((tabela) => tabela.id.equals(itensIds[indice]))).write(
          PlanosTreinoItensCompanion(
            ordem: Value(indice),
            atualizadoEm: Value(agora),
          ),
        );
      }

      await _atualizarPlano(planoTreinoId);
    });
  }

  Future<PlanoTreino?> obterPlanoAtivo() {
    return (select(planosTreino)
          ..where(
            (tabela) => tabela.situacao.equals(SituacaoPlanoTreino.ativo.name),
          )
          ..orderBy([
            (tabela) => OrderingTerm.desc(tabela.favorito),
            (tabela) => OrderingTerm.asc(tabela.ordem),
            (tabela) => OrderingTerm.asc(tabela.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<PlanoTreino?> observarPlanoAtivo() {
    return (select(planosTreino)
          ..where(
            (tabela) => tabela.situacao.equals(SituacaoPlanoTreino.ativo.name),
          )
          ..orderBy([
            (tabela) => OrderingTerm.desc(tabela.favorito),
            (tabela) => OrderingTerm.asc(tabela.ordem),
            (tabela) => OrderingTerm.asc(tabela.id),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<bool> ativarPlano(int id) async {
    return transaction(() async {
      final plano = await obterPlano(id);

      if (plano == null) {
        return false;
      }

      if (plano.situacao == SituacaoPlanoTreino.encerrado.name) {
        throw StateError('Um plano encerrado não pode ser ativado.');
      }

      final itensAtivos = await _listarItensAtivos(id);

      if (itensAtivos.isEmpty) {
        throw StateError(
          'O plano precisa possuir ao menos um item ativo para ser ativado.',
        );
      }

      final agora = DateTime.now();

      await (update(planosTreino)..where(
            (tabela) =>
                tabela.id.isNotValue(id) &
                tabela.situacao.equals(SituacaoPlanoTreino.ativo.name),
          ))
          .write(
            PlanosTreinoCompanion(
              situacao: Value(SituacaoPlanoTreino.pausado.name),
              ativo: const Value(false),
              atualizadoEm: Value(agora),
            ),
          );

      final alterados =
          await (update(
            planosTreino,
          )..where((tabela) => tabela.id.equals(id))).write(
            PlanosTreinoCompanion(
              situacao: Value(SituacaoPlanoTreino.ativo.name),
              ativo: const Value(true),
              atualizadoEm: Value(agora),
            ),
          );

      return alterados > 0;
    });
  }

  Future<bool> pausarPlano(int id) async {
    final plano = await obterPlano(id);

    if (plano == null) {
      return false;
    }

    if (plano.situacao == SituacaoPlanoTreino.encerrado.name) {
      throw StateError('Um plano encerrado não pode ser pausado.');
    }

    final alterados =
        await (update(
          planosTreino,
        )..where((tabela) => tabela.id.equals(id))).write(
          PlanosTreinoCompanion(
            situacao: Value(SituacaoPlanoTreino.pausado.name),
            ativo: const Value(false),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return alterados > 0;
  }

  Future<bool> encerrarPlano(int id) async {
    final plano = await obterPlano(id);

    if (plano == null) {
      return false;
    }

    final alterados =
        await (update(
          planosTreino,
        )..where((tabela) => tabela.id.equals(id))).write(
          PlanosTreinoCompanion(
            situacao: Value(SituacaoPlanoTreino.encerrado.name),
            ativo: const Value(false),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return alterados > 0;
  }

  Future<int> duplicarPlano({
    required int planoTreinoId,
    required String novoNome,
  }) async {
    return transaction(() async {
      final original = await obterPlano(planoTreinoId);

      if (original == null) {
        throw ArgumentError('O plano de treino não foi encontrado.');
      }

      final novoNomeTratado = _validarTextoObrigatorio(
        novoNome,
        campo: 'novo nome',
        maximo: 120,
      );
      final agora = DateTime.now();

      final novoPlanoId = await into(planosTreino).insert(
        PlanosTreinoCompanion.insert(
          nome: novoNomeTratado,
          descricao: Value(original.descricao),
          objetivo: Value(original.objetivo),
          situacao: Value(SituacaoPlanoTreino.pausado.name),
          corArgb: Value(original.corArgb),
          icone: Value(original.icone),
          ordem: Value(await _obterProximaOrdemPlano()),
          favorito: const Value(false),
          ativo: const Value(false),
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      final itens = await listarItens(planoTreinoId);

      for (final item in itens) {
        await into(planosTreinoItens).insert(
          PlanosTreinoItensCompanion.insert(
            planoTreinoId: novoPlanoId,
            ordem: Value(item.ordem),
            codigo: Value(item.codigo),
            nome: item.nome,
            descricao: Value(item.descricao),
            tipo: Value(item.tipo),
            fichaTreinoId: Value(item.fichaTreinoId),
            ativo: Value(item.ativo),
            criadoEm: Value(agora),
            atualizadoEm: Value(agora),
          ),
        );
      }

      return novoPlanoId;
    });
  }

  Future<PlanoTreinoItem?> obterProximoItem() async {
    final plano = await obterPlanoAtivo();

    if (plano == null) {
      return null;
    }

    return _obterItemAtualDoPlano(plano.id);
  }

  Future<EstadoPlanoAtual?> obterEstadoAtual() async {
    final plano = await obterPlanoAtivo();

    if (plano == null) {
      return null;
    }

    final itens = await _listarItensAtivos(plano.id);

    if (itens.isEmpty) {
      return EstadoPlanoAtual(plano: plano, itemAtual: null, proximoItem: null);
    }

    final itemAtual = await _obterItemAtualDoPlano(
      plano.id,
      itensAtivos: itens,
    );

    if (itemAtual == null) {
      return EstadoPlanoAtual(plano: plano, itemAtual: null, proximoItem: null);
    }

    final indiceAtual = itens.indexWhere((item) => item.id == itemAtual.id);
    final proximoItem = itens[(indiceAtual + 1) % itens.length];

    return EstadoPlanoAtual(
      plano: plano,
      itemAtual: itemAtual,
      proximoItem: proximoItem,
    );
  }

  Future<int> registrarTreino({
    required int planoTreinoItemId,
    required int treinoRealizadoId,
    String? observacoes,
  }) async {
    return transaction(() async {
      final contexto = await _validarItemAtual(planoTreinoItemId);
      final item = contexto.item;

      if (item.tipo != TipoPlanoTreinoItem.treino.name) {
        throw StateError('O item atual não é um treino.');
      }

      final treino = await _obterTreinoRealizado(treinoRealizadoId);
      final fichaExecutadaId = treino.fichaTreinoOrigemId;

      if (fichaExecutadaId == null) {
        throw StateError('O treino realizado não possui uma ficha de origem.');
      }

      if (item.fichaTreinoId != fichaExecutadaId) {
        throw StateError(
          'A ficha executada é diferente da ficha planejada. '
          'Use registrarSubstituicao.',
        );
      }

      return _registrarExecucao(
        plano: contexto.plano,
        item: item,
        treinoRealizadoId: treinoRealizadoId,
        fichaPlanejadaId: item.fichaTreinoId,
        fichaExecutadaId: fichaExecutadaId,
        situacao: SituacaoPlanoTreinoExecucao.concluida,
        observacoes: observacoes,
      );
    });
  }

  Future<int> registrarDescanso({
    required int planoTreinoItemId,
    String? observacoes,
  }) async {
    return transaction(() async {
      final contexto = await _validarItemAtual(planoTreinoItemId);
      final item = contexto.item;

      if (item.tipo != TipoPlanoTreinoItem.descanso.name) {
        throw StateError('O item atual não é um descanso.');
      }

      return _registrarExecucao(
        plano: contexto.plano,
        item: item,
        situacao: SituacaoPlanoTreinoExecucao.concluida,
        observacoes: observacoes,
      );
    });
  }

  Future<int> registrarItemSemTreino({
    required int planoTreinoItemId,
    String? observacoes,
  }) async {
    return transaction(() async {
      final contexto = await _validarItemAtual(planoTreinoItemId);
      final item = contexto.item;

      if (item.tipo == TipoPlanoTreinoItem.treino.name) {
        throw StateError(
          'Itens de treino devem ser registrados com registrarTreino.',
        );
      }

      return _registrarExecucao(
        plano: contexto.plano,
        item: item,
        situacao: SituacaoPlanoTreinoExecucao.concluida,
        observacoes: observacoes,
      );
    });
  }

  Future<int> registrarSubstituicao({
    required int planoTreinoItemId,
    required int treinoRealizadoId,
    String? observacoes,
  }) async {
    return transaction(() async {
      final contexto = await _validarItemAtual(planoTreinoItemId);
      final item = contexto.item;
      final treino = await _obterTreinoRealizado(treinoRealizadoId);
      final fichaExecutadaId = treino.fichaTreinoOrigemId;

      if (fichaExecutadaId == null) {
        throw StateError('O treino realizado não possui uma ficha de origem.');
      }

      return _registrarExecucao(
        plano: contexto.plano,
        item: item,
        treinoRealizadoId: treinoRealizadoId,
        fichaPlanejadaId: item.fichaTreinoId,
        fichaExecutadaId: fichaExecutadaId,
        situacao: SituacaoPlanoTreinoExecucao.substituida,
        observacoes: observacoes,
      );
    });
  }

  Future<int> avancarSequencia({String? observacoes}) async {
    return transaction(() async {
      final plano = await obterPlanoAtivo();

      if (plano == null) {
        throw StateError('Não existe um plano ativo.');
      }

      final item = await _obterItemAtualDoPlano(plano.id);

      if (item == null) {
        throw StateError('O plano ativo não possui itens disponíveis.');
      }

      return _registrarExecucao(
        plano: plano,
        item: item,
        fichaPlanejadaId: item.fichaTreinoId,
        situacao: SituacaoPlanoTreinoExecucao.pulada,
        observacoes: observacoes,
      );
    });
  }

  Stream<List<PlanoTreinoExecucao>> observarExecucoesDoPlano(
    int planoTreinoId,
  ) {
    final consulta = select(planosTreinoExecucoes)
      ..where((tabela) => tabela.planoTreinoId.equals(planoTreinoId))
      ..orderBy([
        (tabela) => OrderingTerm.desc(tabela.dataReferencia),
        (tabela) => OrderingTerm.desc(tabela.id),
      ]);

    return consulta.watch();
  }

  Future<List<PlanoTreinoExecucao>> listarExecucoesDoPlano(int planoTreinoId) {
    final consulta = select(planosTreinoExecucoes)
      ..where((tabela) => tabela.planoTreinoId.equals(planoTreinoId))
      ..orderBy([
        (tabela) => OrderingTerm.desc(tabela.dataReferencia),
        (tabela) => OrderingTerm.desc(tabela.id),
      ]);

    return consulta.get();
  }

  Future<PlanoTreinoItem?> _obterItemAtualDoPlano(
    int planoTreinoId, {
    List<PlanoTreinoItem>? itensAtivos,
  }) async {
    final itens = itensAtivos ?? await _listarItensAtivos(planoTreinoId);

    if (itens.isEmpty) {
      return null;
    }

    final ultimaExecucao =
        await (select(planosTreinoExecucoes)
              ..where((tabela) => tabela.planoTreinoId.equals(planoTreinoId))
              ..where(
                (tabela) =>
                    tabela.situacao.equals(
                      SituacaoPlanoTreinoExecucao.concluida.name,
                    ) |
                    tabela.situacao.equals(
                      SituacaoPlanoTreinoExecucao.pulada.name,
                    ) |
                    tabela.situacao.equals(
                      SituacaoPlanoTreinoExecucao.substituida.name,
                    ),
              )
              ..orderBy([
                (tabela) => OrderingTerm.desc(tabela.dataReferencia),
                (tabela) => OrderingTerm.desc(tabela.id),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (ultimaExecucao == null) {
      return itens.first;
    }

    final indiceAnterior = itens.indexWhere(
      (item) => item.id == ultimaExecucao.planoTreinoItemId,
    );

    if (indiceAnterior < 0) {
      return itens.first;
    }

    return itens[(indiceAnterior + 1) % itens.length];
  }

  Future<List<PlanoTreinoItem>> _listarItensAtivos(int planoTreinoId) {
    final consulta = select(planosTreinoItens)
      ..where((tabela) => tabela.planoTreinoId.equals(planoTreinoId))
      ..where((tabela) => tabela.ativo.equals(true))
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.get();
  }

  Future<_ContextoItemAtual> _validarItemAtual(int planoTreinoItemId) async {
    final plano = await obterPlanoAtivo();

    if (plano == null) {
      throw StateError('Não existe um plano ativo.');
    }

    final itemAtual = await _obterItemAtualDoPlano(plano.id);

    if (itemAtual == null) {
      throw StateError('O plano ativo não possui itens disponíveis.');
    }

    if (itemAtual.id != planoTreinoItemId) {
      throw StateError('O item informado não é a etapa atual do plano ativo.');
    }

    return _ContextoItemAtual(plano: plano, item: itemAtual);
  }

  Future<TreinoRealizado> _obterTreinoRealizado(int id) async {
    final treino = await (select(
      treinosRealizados,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();

    if (treino == null) {
      throw ArgumentError('O treino realizado não foi encontrado.');
    }

    if (treino.situacao != SituacaoTreinoRealizado.concluido.name) {
      throw StateError(
        'O treino precisa estar concluído antes de avançar o plano.',
      );
    }

    return treino;
  }

  Future<int> _registrarExecucao({
    required PlanoTreino plano,
    required PlanoTreinoItem item,
    required SituacaoPlanoTreinoExecucao situacao,
    int? treinoRealizadoId,
    int? fichaPlanejadaId,
    int? fichaExecutadaId,
    String? observacoes,
  }) async {
    if (plano.situacao != SituacaoPlanoTreino.ativo.name) {
      throw StateError('Somente um plano ativo pode avançar a sequência.');
    }

    final observacoesTratadas = _validarTextoOpcional(
      observacoes,
      campo: 'observações',
      maximo: 1000,
    );
    final agora = DateTime.now();

    final id = await into(planosTreinoExecucoes).insert(
      PlanosTreinoExecucoesCompanion.insert(
        planoTreinoId: plano.id,
        planoTreinoItemId: item.id,
        treinoRealizadoId: Value(treinoRealizadoId),
        fichaPlanejadaId: Value(fichaPlanejadaId),
        fichaExecutadaId: Value(fichaExecutadaId),
        codigoItemSnapshot: Value(item.codigo),
        nomeItemSnapshot: item.nome,
        tipoItemSnapshot: item.tipo,
        dataReferencia: agora,
        situacao: Value(situacao.name),
        observacoes: Value(observacoesTratadas),
        criadoEm: Value(agora),
        atualizadoEm: Value(agora),
      ),
    );

    await _atualizarPlano(plano.id);

    return id;
  }

  Future<int> _obterProximaOrdemPlano() async {
    final maior =
        await (selectOnly(planosTreino)..addColumns([planosTreino.ordem.max()]))
            .map((linha) => linha.read(planosTreino.ordem.max()))
            .getSingle();

    return (maior ?? -1) + 1;
  }

  Future<int> _obterProximaOrdemItem(int planoTreinoId) async {
    final maior =
        await (selectOnly(planosTreinoItens)
              ..addColumns([planosTreinoItens.ordem.max()])
              ..where(planosTreinoItens.planoTreinoId.equals(planoTreinoId)))
            .map((linha) => linha.read(planosTreinoItens.ordem.max()))
            .getSingle();

    return (maior ?? -1) + 1;
  }

  Future<void> _normalizarOrdensItens(int planoTreinoId) async {
    final itens = await listarItens(planoTreinoId);
    final agora = DateTime.now();

    for (var indice = 0; indice < itens.length; indice++) {
      if (itens[indice].ordem == indice) {
        continue;
      }

      await (update(
        planosTreinoItens,
      )..where((tabela) => tabela.id.equals(itens[indice].id))).write(
        PlanosTreinoItensCompanion(
          ordem: Value(-(indice + 1)),
          atualizadoEm: Value(agora),
        ),
      );
    }

    final temporarios = await listarItens(planoTreinoId);

    for (var indice = 0; indice < temporarios.length; indice++) {
      await (update(
        planosTreinoItens,
      )..where((tabela) => tabela.id.equals(temporarios[indice].id))).write(
        PlanosTreinoItensCompanion(
          ordem: Value(indice),
          atualizadoEm: Value(agora),
        ),
      );
    }
  }

  Future<void> _validarFichaDoItem({
    required TipoPlanoTreinoItem tipo,
    required int? fichaTreinoId,
  }) async {
    if (tipo == TipoPlanoTreinoItem.treino && fichaTreinoId == null) {
      throw ArgumentError(
        'Um item do tipo treino deve possuir uma ficha vinculada.',
      );
    }

    if (tipo != TipoPlanoTreinoItem.treino && fichaTreinoId != null) {
      throw ArgumentError(
        'Somente itens do tipo treino podem possuir uma ficha vinculada.',
      );
    }

    if (fichaTreinoId == null) {
      return;
    }

    final ficha = await (select(
      fichasTreino,
    )..where((tabela) => tabela.id.equals(fichaTreinoId))).getSingleOrNull();

    if (ficha == null) {
      throw ArgumentError('A ficha de treino vinculada não foi encontrada.');
    }

    if (!ficha.ativo) {
      throw StateError('Não é possível vincular uma ficha inativa.');
    }
  }

  Future<int> _quantidadeExecucoesDoPlano(int planoTreinoId) async {
    final quantidade = planosTreinoExecucoes.id.count();

    final consulta = selectOnly(planosTreinoExecucoes)
      ..addColumns([quantidade])
      ..where(planosTreinoExecucoes.planoTreinoId.equals(planoTreinoId));

    return (await consulta
            .map((linha) => linha.read(quantidade))
            .getSingle()) ??
        0;
  }

  Future<int> _quantidadeExecucoesDoItem(int planoTreinoItemId) async {
    final quantidade = planosTreinoExecucoes.id.count();

    final consulta = selectOnly(planosTreinoExecucoes)
      ..addColumns([quantidade])
      ..where(
        planosTreinoExecucoes.planoTreinoItemId.equals(planoTreinoItemId),
      );

    return (await consulta
            .map((linha) => linha.read(quantidade))
            .getSingle()) ??
        0;
  }

  Future<void> _atualizarPlano(int planoTreinoId) {
    return (update(planosTreino)
          ..where((tabela) => tabela.id.equals(planoTreinoId)))
        .write(PlanosTreinoCompanion(atualizadoEm: Value(DateTime.now())));
  }

  void _garantirPlanoEditavel(PlanoTreino plano) {
    if (plano.situacao == SituacaoPlanoTreino.encerrado.name) {
      throw StateError('Um plano encerrado não pode ser alterado.');
    }
  }

  String _validarTextoObrigatorio(
    String valor, {
    required String campo,
    required int maximo,
  }) {
    final tratado = valor.trim();

    if (tratado.isEmpty) {
      throw ArgumentError('O campo $campo é obrigatório.');
    }

    if (tratado.length > maximo) {
      throw ArgumentError(
        'O campo $campo deve possuir no máximo $maximo caracteres.',
      );
    }

    return tratado;
  }

  String? _validarTextoOpcional(
    String? valor, {
    required String campo,
    required int maximo,
  }) {
    final tratado = valor?.trim();

    if (tratado == null || tratado.isEmpty) {
      return null;
    }

    if (tratado.length > maximo) {
      throw ArgumentError(
        'O campo $campo deve possuir no máximo $maximo caracteres.',
      );
    }

    return tratado;
  }
}

class EstadoPlanoAtual {
  const EstadoPlanoAtual({
    required this.plano,
    required this.itemAtual,
    required this.proximoItem,
  });

  final PlanoTreino plano;
  final PlanoTreinoItem? itemAtual;
  final PlanoTreinoItem? proximoItem;
}

class _ContextoItemAtual {
  const _ContextoItemAtual({required this.plano, required this.item});

  final PlanoTreino plano;
  final PlanoTreinoItem item;
}
