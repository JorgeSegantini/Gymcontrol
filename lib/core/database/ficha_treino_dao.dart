import 'package:drift/drift.dart';

import 'app_database.dart';

part 'ficha_treino_dao.g.dart';

class FichaExercicioDetalhe {
  const FichaExercicioDetalhe({
    required this.fichaExercicio,
    required this.exercicio,
  });

  final FichaExercicio fichaExercicio;
  final Exercicio exercicio;
}

@DriftAccessor(
  tables: [FichasTreino, FichasExercicios, FichasExerciciosSeries, Exercicios],
)
class FichaTreinoDao extends DatabaseAccessor<AppDatabase>
    with _$FichaTreinoDaoMixin {
  FichaTreinoDao(super.database);

  // ---------------------------------------------------------------------------
  // FICHAS DE TREINO
  // ---------------------------------------------------------------------------

  Stream<List<FichaTreino>> observarTodas({bool incluirInativas = true}) {
    final consulta = select(fichasTreino);

    if (!incluirInativas) {
      consulta.where((tabela) => tabela.ativo.equals(true));
    }

    consulta.orderBy([
      (tabela) => OrderingTerm.asc(tabela.ordem),
      (tabela) => OrderingTerm.asc(tabela.nome),
    ]);

    return consulta.watch();
  }

  Stream<List<FichaTreino>> observarAtivas() {
    return observarTodas(incluirInativas: false);
  }

  Future<FichaTreino?> obterPorId(int id) {
    return (select(
      fichasTreino,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<int> cadastrar({
    required String nome,
    String? descricao,
    required int ordem,
  }) {
    final agora = DateTime.now();

    return into(fichasTreino).insert(
      FichasTreinoCompanion.insert(
        nome: nome.trim(),
        descricao: Value(_normalizarTextoOpcional(descricao)),
        ordem: Value(ordem),
        criadoEm: Value(agora),
        atualizadoEm: Value(agora),
      ),
    );
  }

  Future<bool> editar({
    required int id,
    required String nome,
    String? descricao,
    required int ordem,
  }) async {
    final quantidadeAlterada =
        await (update(
          fichasTreino,
        )..where((tabela) => tabela.id.equals(id))).write(
          FichasTreinoCompanion(
            nome: Value(nome.trim()),
            descricao: Value(_normalizarTextoOpcional(descricao)),
            ordem: Value(ordem),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return quantidadeAlterada > 0;
  }

  Future<bool> alterarSituacao({required int id, required bool ativo}) async {
    final quantidadeAlterada =
        await (update(
          fichasTreino,
        )..where((tabela) => tabela.id.equals(id))).write(
          FichasTreinoCompanion(
            ativo: Value(ativo),
            atualizadoEm: Value(DateTime.now()),
          ),
        );

    return quantidadeAlterada > 0;
  }

  // ---------------------------------------------------------------------------
  // EXERCÍCIOS DA FICHA
  // ---------------------------------------------------------------------------

  Stream<List<FichaExercicioDetalhe>> observarExerciciosDaFicha(
    int fichaTreinoId,
  ) {
    final consulta =
        select(fichasExercicios).join([
            innerJoin(
              exercicios,
              exercicios.id.equalsExp(fichasExercicios.exercicioId),
            ),
          ])
          ..where(fichasExercicios.fichaTreinoId.equals(fichaTreinoId))
          ..orderBy([
            OrderingTerm.asc(fichasExercicios.ordem),
            OrderingTerm.asc(exercicios.nome),
          ]);

    return consulta.watch().map((linhas) {
      return linhas.map((linha) {
        return FichaExercicioDetalhe(
          fichaExercicio: linha.readTable(fichasExercicios),
          exercicio: linha.readTable(exercicios),
        );
      }).toList();
    });
  }

  Future<List<FichaExercicioDetalhe>> listarExerciciosDaFicha(
    int fichaTreinoId,
  ) async {
    final consulta =
        select(fichasExercicios).join([
            innerJoin(
              exercicios,
              exercicios.id.equalsExp(fichasExercicios.exercicioId),
            ),
          ])
          ..where(fichasExercicios.fichaTreinoId.equals(fichaTreinoId))
          ..orderBy([
            OrderingTerm.asc(fichasExercicios.ordem),
            OrderingTerm.asc(exercicios.nome),
          ]);

    final linhas = await consulta.get();

    return linhas.map((linha) {
      return FichaExercicioDetalhe(
        fichaExercicio: linha.readTable(fichasExercicios),
        exercicio: linha.readTable(exercicios),
      );
    }).toList();
  }

  Future<FichaExercicio?> obterFichaExercicioPorId(int id) {
    return (select(
      fichasExercicios,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<int> adicionarExercicio({
    required int fichaTreinoId,
    required int exercicioId,
  }) async {
    return transaction(() async {
      final ficha = await obterPorId(fichaTreinoId);

      if (ficha == null) {
        throw ArgumentError('A ficha de treino não foi encontrada.');
      }

      final exercicio = await (select(
        exercicios,
      )..where((tabela) => tabela.id.equals(exercicioId))).getSingleOrNull();

      if (exercicio == null) {
        throw ArgumentError('O exercício não foi encontrado.');
      }

      final exercicioExistente =
          await (select(fichasExercicios)
                ..where((tabela) => tabela.fichaTreinoId.equals(fichaTreinoId))
                ..where((tabela) => tabela.exercicioId.equals(exercicioId)))
              .getSingleOrNull();

      if (exercicioExistente != null) {
        throw StateError('Este exercício já foi adicionado à ficha de treino.');
      }

      final maiorOrdem = fichasExercicios.ordem.max();

      final resultado =
          await (selectOnly(fichasExercicios)
                ..addColumns([maiorOrdem])
                ..where(fichasExercicios.fichaTreinoId.equals(fichaTreinoId)))
              .getSingle();

      final proximaOrdem = (resultado.read(maiorOrdem) ?? 0) + 1;
      final agora = DateTime.now();

      final id = await into(fichasExercicios).insert(
        FichasExerciciosCompanion.insert(
          fichaTreinoId: fichaTreinoId,
          exercicioId: exercicioId,
          ordem: Value(proximaOrdem),
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      await _atualizarDataFicha(fichaTreinoId);

      return id;
    });
  }

  Future<bool> editarExercicioDaFicha({
    required int fichaExercicioId,
    String? observacoes,
    int? rirPlanejado,
    required bool ativo,
  }) async {
    if (rirPlanejado != null && (rirPlanejado < 0 || rirPlanejado > 5)) {
      throw ArgumentError('O RIR deve estar entre 0 e 5.');
    }

    return transaction(() async {
      final vinculo = await obterFichaExercicioPorId(fichaExercicioId);

      if (vinculo == null) {
        return false;
      }

      final quantidadeAlterada =
          await (update(
            fichasExercicios,
          )..where((tabela) => tabela.id.equals(fichaExercicioId))).write(
            FichasExerciciosCompanion(
              observacoes: Value(_normalizarTextoOpcional(observacoes)),
              rirPlanejado: Value(rirPlanejado),
              ativo: Value(ativo),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

      if (quantidadeAlterada > 0) {
        await _atualizarDataFicha(vinculo.fichaTreinoId);
      }

      return quantidadeAlterada > 0;
    });
  }

  Future<bool> removerExercicio({required int fichaExercicioId}) async {
    return transaction(() async {
      final vinculo = await obterFichaExercicioPorId(fichaExercicioId);

      if (vinculo == null) {
        return false;
      }

      final quantidadeRemovida = await (delete(
        fichasExercicios,
      )..where((tabela) => tabela.id.equals(fichaExercicioId))).go();

      if (quantidadeRemovida == 0) {
        return false;
      }

      await _normalizarOrdemExercicios(vinculo.fichaTreinoId);
      await _atualizarDataFicha(vinculo.fichaTreinoId);

      return true;
    });
  }

  Future<void> reordenarExercicios({
    required int fichaTreinoId,
    required List<int> fichaExercicioIds,
  }) async {
    await transaction(() async {
      final vinculos = await (select(
        fichasExercicios,
      )..where((tabela) => tabela.fichaTreinoId.equals(fichaTreinoId))).get();

      final idsExistentes = vinculos.map((vinculo) => vinculo.id).toSet();
      final idsRecebidos = fichaExercicioIds.toSet();

      if (idsExistentes.length != idsRecebidos.length ||
          !idsExistentes.containsAll(idsRecebidos)) {
        throw ArgumentError(
          'A lista de exercícios não corresponde à ficha de treino.',
        );
      }

      final agora = DateTime.now();

      for (var indice = 0; indice < fichaExercicioIds.length; indice++) {
        final fichaExercicioId = fichaExercicioIds[indice];

        await (update(
          fichasExercicios,
        )..where((tabela) => tabela.id.equals(fichaExercicioId))).write(
          FichasExerciciosCompanion(
            ordem: Value(indice + 1),
            atualizadoEm: Value(agora),
          ),
        );
      }

      await _atualizarDataFicha(fichaTreinoId);
    });
  }

  // ---------------------------------------------------------------------------
  // SÉRIES PLANEJADAS
  // ---------------------------------------------------------------------------

  Stream<List<FichaExercicioSerie>> observarSeriesDoExercicio(
    int fichaExercicioId, {
    bool incluirInativas = true,
  }) {
    final consulta = select(fichasExerciciosSeries)
      ..where((tabela) => tabela.fichaExercicioId.equals(fichaExercicioId));

    if (!incluirInativas) {
      consulta.where((tabela) => tabela.ativo.equals(true));
    }

    consulta.orderBy([
      (tabela) => OrderingTerm.asc(tabela.ordem),
      (tabela) => OrderingTerm.asc(tabela.id),
    ]);

    return consulta.watch();
  }

  Future<List<FichaExercicioSerie>> listarSeriesDoExercicio(
    int fichaExercicioId, {
    bool incluirInativas = true,
  }) {
    final consulta = select(fichasExerciciosSeries)
      ..where((tabela) => tabela.fichaExercicioId.equals(fichaExercicioId));

    if (!incluirInativas) {
      consulta.where((tabela) => tabela.ativo.equals(true));
    }

    consulta.orderBy([
      (tabela) => OrderingTerm.asc(tabela.ordem),
      (tabela) => OrderingTerm.asc(tabela.id),
    ]);

    return consulta.get();
  }

  Future<FichaExercicioSerie?> obterSeriePorId(int id) {
    return (select(
      fichasExerciciosSeries,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<int> adicionarSerie({
    required int fichaExercicioId,
    TipoSerie tipoSerie = TipoSerie.normal,
    int? repeticoesMinimas,
    int? repeticoesMaximas,
    int? cargaPlanejadaGramas,
    int? incrementoCargaGramas,
    int descansoSegundos = 0,
    int? tempoExecucaoSegundos,
    String? observacoes,
    bool copiarUltimaSerie = false,
  }) async {
    return transaction(() async {
      final fichaExercicio = await obterFichaExercicioPorId(fichaExercicioId);

      if (fichaExercicio == null) {
        throw ArgumentError(
          'O exercício informado não pertence a uma ficha de treino.',
        );
      }

      FichaExercicioSerie? ultimaSerie;

      if (copiarUltimaSerie) {
        ultimaSerie =
            await (select(fichasExerciciosSeries)
                  ..where(
                    (tabela) =>
                        tabela.fichaExercicioId.equals(fichaExercicioId),
                  )
                  ..orderBy([
                    (tabela) => OrderingTerm.desc(tabela.ordem),
                    (tabela) => OrderingTerm.desc(tabela.id),
                  ])
                  ..limit(1))
                .getSingleOrNull();
      }

      final tipoSerieFinal = ultimaSerie == null
          ? tipoSerie
          : TipoSerie.values.byName(ultimaSerie.tipoSerie);

      final repeticoesMinimasFinal =
          ultimaSerie?.repeticoesMinimas ?? repeticoesMinimas;
      final repeticoesMaximasFinal =
          ultimaSerie?.repeticoesMaximas ?? repeticoesMaximas;
      final cargaPlanejadaGramasFinal =
          ultimaSerie?.cargaPlanejadaGramas ?? cargaPlanejadaGramas;
      final incrementoCargaGramasFinal =
          ultimaSerie?.incrementoCargaGramas ?? incrementoCargaGramas;
      final descansoSegundosFinal =
          ultimaSerie?.descansoSegundos ?? descansoSegundos;
      final tempoExecucaoSegundosFinal =
          ultimaSerie?.tempoExecucaoSegundos ?? tempoExecucaoSegundos;
      final observacoesFinal = ultimaSerie?.observacoes ?? observacoes;
      final ativoFinal = ultimaSerie?.ativo ?? true;

      _validarSerie(
        repeticoesMinimas: repeticoesMinimasFinal,
        repeticoesMaximas: repeticoesMaximasFinal,
        cargaPlanejadaGramas: cargaPlanejadaGramasFinal,
        incrementoCargaGramas: incrementoCargaGramasFinal,
        descansoSegundos: descansoSegundosFinal,
        tempoExecucaoSegundos: tempoExecucaoSegundosFinal,
      );

      final maiorOrdem = fichasExerciciosSeries.ordem.max();

      final resultado =
          await (selectOnly(fichasExerciciosSeries)
                ..addColumns([maiorOrdem])
                ..where(
                  fichasExerciciosSeries.fichaExercicioId.equals(
                    fichaExercicioId,
                  ),
                ))
              .getSingle();

      final proximaOrdem = (resultado.read(maiorOrdem) ?? 0) + 1;
      final agora = DateTime.now();

      final serieId = await into(fichasExerciciosSeries).insert(
        FichasExerciciosSeriesCompanion.insert(
          fichaExercicioId: fichaExercicioId,
          ordem: Value(proximaOrdem),
          tipoSerie: Value(tipoSerieFinal.name),
          repeticoesMinimas: Value(repeticoesMinimasFinal),
          repeticoesMaximas: Value(repeticoesMaximasFinal),
          cargaPlanejadaGramas: Value(cargaPlanejadaGramasFinal),
          incrementoCargaGramas: Value(incrementoCargaGramasFinal),
          descansoSegundos: Value(descansoSegundosFinal),
          tempoExecucaoSegundos: Value(tempoExecucaoSegundosFinal),
          observacoes: Value(_normalizarTextoOpcional(observacoesFinal)),
          ativo: Value(ativoFinal),
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      await _atualizarDataFicha(fichaExercicio.fichaTreinoId);

      return serieId;
    });
  }

  Future<int> duplicarSerie({required int id}) async {
    return transaction(() async {
      final serie = await obterSeriePorId(id);

      if (serie == null) {
        throw ArgumentError('A série não foi encontrada.');
      }

      final fichaExercicio = await obterFichaExercicioPorId(
        serie.fichaExercicioId,
      );

      if (fichaExercicio == null) {
        throw ArgumentError('O exercício informado não pertence a uma ficha.');
      }

      final maiorOrdem = fichasExerciciosSeries.ordem.max();

      final resultado =
          await (selectOnly(fichasExerciciosSeries)
                ..addColumns([maiorOrdem])
                ..where(
                  fichasExerciciosSeries.fichaExercicioId.equals(
                    serie.fichaExercicioId,
                  ),
                ))
              .getSingle();

      final proximaOrdem = (resultado.read(maiorOrdem) ?? 0) + 1;

      final agora = DateTime.now();

      final novoId = await into(fichasExerciciosSeries).insert(
        FichasExerciciosSeriesCompanion.insert(
          fichaExercicioId: serie.fichaExercicioId,
          ordem: Value(proximaOrdem),
          tipoSerie: Value(serie.tipoSerie),
          repeticoesMinimas: Value(serie.repeticoesMinimas),
          repeticoesMaximas: Value(serie.repeticoesMaximas),
          cargaPlanejadaGramas: Value(serie.cargaPlanejadaGramas),
          incrementoCargaGramas: Value(serie.incrementoCargaGramas),
          descansoSegundos: Value(serie.descansoSegundos),
          tempoExecucaoSegundos: Value(serie.tempoExecucaoSegundos),
          observacoes: Value(serie.observacoes),
          ativo: Value(serie.ativo),
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      await _atualizarDataFicha(fichaExercicio.fichaTreinoId);

      return novoId;
    });
  }

  Future<bool> editarSerie({
    required int id,
    required TipoSerie tipoSerie,
    int? repeticoesMinimas,
    int? repeticoesMaximas,
    int? cargaPlanejadaGramas,
    int? incrementoCargaGramas,
    required int descansoSegundos,
    int? tempoExecucaoSegundos,
    String? observacoes,
    required bool ativo,
  }) async {
    _validarSerie(
      repeticoesMinimas: repeticoesMinimas,
      repeticoesMaximas: repeticoesMaximas,
      cargaPlanejadaGramas: cargaPlanejadaGramas,
      incrementoCargaGramas: incrementoCargaGramas,
      descansoSegundos: descansoSegundos,
      tempoExecucaoSegundos: tempoExecucaoSegundos,
    );

    return transaction(() async {
      final serie = await obterSeriePorId(id);

      if (serie == null) {
        return false;
      }

      final quantidadeAlterada =
          await (update(
            fichasExerciciosSeries,
          )..where((tabela) => tabela.id.equals(id))).write(
            FichasExerciciosSeriesCompanion(
              tipoSerie: Value(tipoSerie.name),
              repeticoesMinimas: Value(repeticoesMinimas),
              repeticoesMaximas: Value(repeticoesMaximas),
              cargaPlanejadaGramas: Value(cargaPlanejadaGramas),
              incrementoCargaGramas: Value(incrementoCargaGramas),
              descansoSegundos: Value(descansoSegundos),
              tempoExecucaoSegundos: Value(tempoExecucaoSegundos),
              observacoes: Value(_normalizarTextoOpcional(observacoes)),
              ativo: Value(ativo),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

      if (quantidadeAlterada > 0) {
        await _atualizarDataFichaPelaSerie(serie);
      }

      return quantidadeAlterada > 0;
    });
  }

  Future<bool> alterarSituacaoSerie({
    required int id,
    required bool ativo,
  }) async {
    return transaction(() async {
      final serie = await obterSeriePorId(id);

      if (serie == null) {
        return false;
      }

      final quantidadeAlterada =
          await (update(
            fichasExerciciosSeries,
          )..where((tabela) => tabela.id.equals(id))).write(
            FichasExerciciosSeriesCompanion(
              ativo: Value(ativo),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

      if (quantidadeAlterada > 0) {
        await _atualizarDataFichaPelaSerie(serie);
      }

      return quantidadeAlterada > 0;
    });
  }

  Future<bool> removerSerie({required int id}) async {
    return transaction(() async {
      final serie = await obterSeriePorId(id);

      if (serie == null) {
        return false;
      }

      final fichaExercicio = await obterFichaExercicioPorId(
        serie.fichaExercicioId,
      );

      final quantidadeRemovida = await (delete(
        fichasExerciciosSeries,
      )..where((tabela) => tabela.id.equals(id))).go();

      if (quantidadeRemovida == 0) {
        return false;
      }

      await _normalizarOrdemSeries(serie.fichaExercicioId);

      if (fichaExercicio != null) {
        await _atualizarDataFicha(fichaExercicio.fichaTreinoId);
      }

      return true;
    });
  }

  Future<void> reordenarSeries({
    required int fichaExercicioId,
    required List<int> serieIds,
  }) async {
    await transaction(() async {
      final fichaExercicio = await obterFichaExercicioPorId(fichaExercicioId);

      if (fichaExercicio == null) {
        throw ArgumentError(
          'O exercício informado não pertence a uma ficha de treino.',
        );
      }

      final series =
          await (select(fichasExerciciosSeries)..where(
                (tabela) => tabela.fichaExercicioId.equals(fichaExercicioId),
              ))
              .get();

      final idsExistentes = series.map((serie) => serie.id).toSet();
      final idsRecebidos = serieIds.toSet();

      if (serieIds.length != idsRecebidos.length ||
          idsExistentes.length != idsRecebidos.length ||
          !idsExistentes.containsAll(idsRecebidos)) {
        throw ArgumentError(
          'A lista de séries não corresponde ao exercício da ficha.',
        );
      }

      final agora = DateTime.now();

      for (var indice = 0; indice < serieIds.length; indice++) {
        await (update(
          fichasExerciciosSeries,
        )..where((tabela) => tabela.id.equals(serieIds[indice]))).write(
          FichasExerciciosSeriesCompanion(
            ordem: Value(indice + 1),
            atualizadoEm: Value(agora),
          ),
        );
      }

      await _atualizarDataFicha(fichaExercicio.fichaTreinoId);
    });
  }

  // ---------------------------------------------------------------------------
  // MÉTODOS INTERNOS
  // ---------------------------------------------------------------------------

  Future<void> _normalizarOrdemExercicios(int fichaTreinoId) async {
    final vinculos =
        await (select(fichasExercicios)
              ..where((tabela) => tabela.fichaTreinoId.equals(fichaTreinoId))
              ..orderBy([
                (tabela) => OrderingTerm.asc(tabela.ordem),
                (tabela) => OrderingTerm.asc(tabela.id),
              ]))
            .get();

    final agora = DateTime.now();

    for (var indice = 0; indice < vinculos.length; indice++) {
      final vinculo = vinculos[indice];
      final novaOrdem = indice + 1;

      if (vinculo.ordem == novaOrdem) {
        continue;
      }

      await (update(
        fichasExercicios,
      )..where((tabela) => tabela.id.equals(vinculo.id))).write(
        FichasExerciciosCompanion(
          ordem: Value(novaOrdem),
          atualizadoEm: Value(agora),
        ),
      );
    }
  }

  Future<void> _normalizarOrdemSeries(int fichaExercicioId) async {
    final series =
        await (select(fichasExerciciosSeries)
              ..where(
                (tabela) => tabela.fichaExercicioId.equals(fichaExercicioId),
              )
              ..orderBy([
                (tabela) => OrderingTerm.asc(tabela.ordem),
                (tabela) => OrderingTerm.asc(tabela.id),
              ]))
            .get();

    final agora = DateTime.now();

    for (var indice = 0; indice < series.length; indice++) {
      final serie = series[indice];
      final novaOrdem = indice + 1;

      if (serie.ordem == novaOrdem) {
        continue;
      }

      await (update(
        fichasExerciciosSeries,
      )..where((tabela) => tabela.id.equals(serie.id))).write(
        FichasExerciciosSeriesCompanion(
          ordem: Value(novaOrdem),
          atualizadoEm: Value(agora),
        ),
      );
    }
  }

  Future<void> _atualizarDataFichaPelaSerie(FichaExercicioSerie serie) async {
    final fichaExercicio = await obterFichaExercicioPorId(
      serie.fichaExercicioId,
    );

    if (fichaExercicio == null) {
      return;
    }

    await _atualizarDataFicha(fichaExercicio.fichaTreinoId);
  }

  Future<void> _atualizarDataFicha(int fichaTreinoId) {
    return (update(fichasTreino)
          ..where((tabela) => tabela.id.equals(fichaTreinoId)))
        .write(FichasTreinoCompanion(atualizadoEm: Value(DateTime.now())));
  }

  void _validarSerie({
    required int? repeticoesMinimas,
    required int? repeticoesMaximas,
    required int? cargaPlanejadaGramas,
    required int? incrementoCargaGramas,
    required int descansoSegundos,
    required int? tempoExecucaoSegundos,
  }) {
    if (repeticoesMinimas != null && repeticoesMinimas < 0) {
      throw ArgumentError('As repetições mínimas não podem ser negativas.');
    }

    if (repeticoesMaximas != null && repeticoesMaximas < 0) {
      throw ArgumentError('As repetições máximas não podem ser negativas.');
    }

    if (repeticoesMinimas != null &&
        repeticoesMaximas != null &&
        repeticoesMinimas > repeticoesMaximas) {
      throw ArgumentError(
        'As repetições mínimas não podem ser maiores que as máximas.',
      );
    }

    if (cargaPlanejadaGramas != null && cargaPlanejadaGramas < 0) {
      throw ArgumentError('A carga planejada não pode ser negativa.');
    }

    if (incrementoCargaGramas != null && incrementoCargaGramas < 0) {
      throw ArgumentError('O incremento de carga não pode ser negativo.');
    }

    if (descansoSegundos < 0) {
      throw ArgumentError('O descanso não pode ser negativo.');
    }

    if (tempoExecucaoSegundos != null && tempoExecucaoSegundos < 0) {
      throw ArgumentError('O tempo de execução não pode ser negativo.');
    }
  }

  String? _normalizarTextoOpcional(String? texto) {
    final valor = texto?.trim();

    if (valor == null || valor.isEmpty) {
      return null;
    }

    return valor;
  }
}
