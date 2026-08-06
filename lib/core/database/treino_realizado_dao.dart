import 'package:drift/drift.dart';

import 'app_database.dart';
import 'models/evolucao_exercicio.dart';
import 'models/resumo_treino_concluido.dart';
import 'models/resumo_ultima_execucao.dart';
import 'models/serie_ultima_execucao.dart';
import 'treino_tables.dart';

part 'treino_realizado_dao.g.dart';

class SerieTreinoDetalhe {
  const SerieTreinoDetalhe({required this.serie, required this.exercicio});

  final SerieRealizada serie;
  final ExercicioRealizado exercicio;
}

@DriftAccessor(
  tables: [
    FichasTreino,
    FichasExercicios,
    FichasExerciciosSeries,
    Exercicios,
    TreinosRealizados,
    ExerciciosRealizados,
    SeriesRealizadas,
  ],
)
class TreinoRealizadoDao extends DatabaseAccessor<AppDatabase>
    with _$TreinoRealizadoDaoMixin {
  TreinoRealizadoDao(super.database);

  Future<int> iniciarTreinoDaFicha({required int fichaTreinoId}) async {
    return transaction(() async {
      final fichaTreino = await (select(
        fichasTreino,
      )..where((tabela) => tabela.id.equals(fichaTreinoId))).getSingleOrNull();

      if (fichaTreino == null) {
        throw ArgumentError('A ficha de treino não foi encontrada.');
      }

      if (!fichaTreino.ativo) {
        throw StateError('Não é possível iniciar uma ficha inativa.');
      }

      final exerciciosDaFicha =
          await (select(fichasExercicios).join([
                  innerJoin(
                    exercicios,
                    exercicios.id.equalsExp(fichasExercicios.exercicioId),
                  ),
                ])
                ..where(fichasExercicios.fichaTreinoId.equals(fichaTreinoId))
                ..where(fichasExercicios.ativo.equals(true))
                ..orderBy([
                  OrderingTerm.asc(fichasExercicios.ordem),
                  OrderingTerm.asc(fichasExercicios.id),
                ]))
              .get();

      if (exerciciosDaFicha.isEmpty) {
        throw StateError(
          'A ficha não possui exercícios ativos para iniciar o treino.',
        );
      }

      final agora = DateTime.now();

      final treinoRealizadoId = await into(treinosRealizados).insert(
        TreinosRealizadosCompanion.insert(
          fichaTreinoOrigemId: Value(fichaTreino.id),
          nomeFichaSnapshot: fichaTreino.nome,
          descricaoFichaSnapshot: Value(fichaTreino.descricao),
          corArgbSnapshot: Value(fichaTreino.corArgb),
          situacao: Value(SituacaoTreinoRealizado.emAndamento.name),
          iniciadoEm: agora,
          criadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      for (final linha in exerciciosDaFicha) {
        final fichaExercicio = linha.readTable(fichasExercicios);
        final exercicio = linha.readTable(exercicios);

        final exercicioRealizadoId = await into(exerciciosRealizados).insert(
          ExerciciosRealizadosCompanion.insert(
            treinoRealizadoId: treinoRealizadoId,
            fichaExercicioOrigemId: Value(fichaExercicio.id),
            exercicioOrigemId: Value(exercicio.id),
            nomeExercicioSnapshot: exercicio.nome,
            ordem: Value(fichaExercicio.ordem),
            rirPlanejado: Value(fichaExercicio.rirPlanejado),
            observacoesPlanejadas: Value(fichaExercicio.observacoes),
            situacao: Value(SituacaoExercicioRealizado.pendente.name),
            criadoEm: Value(agora),
            atualizadoEm: Value(agora),
          ),
        );

        final seriesPlanejadas =
            await (select(fichasExerciciosSeries)
                  ..where(
                    (tabela) =>
                        tabela.fichaExercicioId.equals(fichaExercicio.id),
                  )
                  ..where((tabela) => tabela.ativo.equals(true))
                  ..orderBy([
                    (tabela) => OrderingTerm.asc(tabela.ordem),
                    (tabela) => OrderingTerm.asc(tabela.id),
                  ]))
                .get();

        for (final seriePlanejada in seriesPlanejadas) {
          final repeticoesIniciais =
              seriePlanejada.repeticoesMaximas ??
              seriePlanejada.repeticoesMinimas;

          await into(seriesRealizadas).insert(
            SeriesRealizadasCompanion.insert(
              exercicioRealizadoId: exercicioRealizadoId,
              fichaExercicioSerieOrigemId: Value(seriePlanejada.id),
              ordem: Value(seriePlanejada.ordem),
              tipoSerie: Value(seriePlanejada.tipoSerie),
              repeticoesMinimasPlanejadas: Value(
                seriePlanejada.repeticoesMinimas,
              ),
              repeticoesMaximasPlanejadas: Value(
                seriePlanejada.repeticoesMaximas,
              ),
              cargaPlanejadaGramas: Value(seriePlanejada.cargaPlanejadaGramas),
              incrementoCargaGramas: Value(
                seriePlanejada.incrementoCargaGramas,
              ),
              descansoPlanejadoSegundos: Value(seriePlanejada.descansoSegundos),
              tempoExecucaoPlanejadoSegundos: Value(
                seriePlanejada.tempoExecucaoSegundos,
              ),
              observacoesPlanejadas: Value(seriePlanejada.observacoes),
              situacao: Value(SituacaoSerieRealizada.pendente.name),
              cargaRealizadaGramas: Value(seriePlanejada.cargaPlanejadaGramas),
              repeticoesRealizadas: Value(repeticoesIniciais),
              rirRealizado: Value(fichaExercicio.rirPlanejado),
              criadoEm: Value(agora),
              atualizadoEm: Value(agora),
            ),
          );
        }
      }

      return treinoRealizadoId;
    });
  }

  Stream<List<TreinoRealizado>> observarTreinos({
    bool incluirCancelados = true,
  }) {
    final consulta = select(treinosRealizados);

    if (!incluirCancelados) {
      consulta.where(
        (tabela) =>
            tabela.situacao.isNotValue(SituacaoTreinoRealizado.cancelado.name),
      );
    }

    consulta.orderBy([
      (tabela) => OrderingTerm.desc(tabela.iniciadoEm),
      (tabela) => OrderingTerm.desc(tabela.id),
    ]);

    return consulta.watch();
  }

  Future<TreinoRealizado?> obterTreinoPorId(int id) {
    return (select(
      treinosRealizados,
    )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();
  }

  Future<List<ExercicioRealizado>> listarExerciciosDoTreino(
    int treinoRealizadoId,
  ) {
    final consulta = select(exerciciosRealizados)
      ..where((tabela) => tabela.treinoRealizadoId.equals(treinoRealizadoId))
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.get();
  }

  Stream<List<ExercicioRealizado>> observarExerciciosDoTreino(
    int treinoRealizadoId,
  ) {
    final consulta = select(exerciciosRealizados)
      ..where((tabela) => tabela.treinoRealizadoId.equals(treinoRealizadoId))
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.watch();
  }

  Future<List<SerieRealizada>> listarSeriesDoExercicio(
    int exercicioRealizadoId,
  ) {
    final consulta = select(seriesRealizadas)
      ..where(
        (tabela) => tabela.exercicioRealizadoId.equals(exercicioRealizadoId),
      )
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.get();
  }

  Stream<List<SerieRealizada>> observarSeriesDoExercicio(
    int exercicioRealizadoId,
  ) {
    final consulta = select(seriesRealizadas)
      ..where(
        (tabela) => tabela.exercicioRealizadoId.equals(exercicioRealizadoId),
      )
      ..orderBy([
        (tabela) => OrderingTerm.asc(tabela.ordem),
        (tabela) => OrderingTerm.asc(tabela.id),
      ]);

    return consulta.watch();
  }

  Future<List<SerieTreinoDetalhe>> listarSeriesDoTreino(
    int treinoRealizadoId,
  ) async {
    final consulta =
        select(seriesRealizadas).join([
            innerJoin(
              exerciciosRealizados,
              exerciciosRealizados.id.equalsExp(
                seriesRealizadas.exercicioRealizadoId,
              ),
            ),
          ])
          ..where(
            exerciciosRealizados.treinoRealizadoId.equals(treinoRealizadoId),
          )
          ..orderBy([
            OrderingTerm.asc(exerciciosRealizados.ordem),
            OrderingTerm.asc(seriesRealizadas.ordem),
            OrderingTerm.asc(seriesRealizadas.id),
          ]);

    final linhas = await consulta.get();

    return linhas.map((linha) {
      return SerieTreinoDetalhe(
        serie: linha.readTable(seriesRealizadas),
        exercicio: linha.readTable(exerciciosRealizados),
      );
    }).toList();
  }

  Stream<List<SerieTreinoDetalhe>> observarSeriesDoTreino(
    int treinoRealizadoId,
  ) {
    final consulta =
        select(seriesRealizadas).join([
            innerJoin(
              exerciciosRealizados,
              exerciciosRealizados.id.equalsExp(
                seriesRealizadas.exercicioRealizadoId,
              ),
            ),
          ])
          ..where(
            exerciciosRealizados.treinoRealizadoId.equals(treinoRealizadoId),
          )
          ..orderBy([
            OrderingTerm.asc(exerciciosRealizados.ordem),
            OrderingTerm.asc(seriesRealizadas.ordem),
            OrderingTerm.asc(seriesRealizadas.id),
          ]);

    return consulta.watch().map((linhas) {
      return linhas.map((linha) {
        return SerieTreinoDetalhe(
          serie: linha.readTable(seriesRealizadas),
          exercicio: linha.readTable(exerciciosRealizados),
        );
      }).toList();
    });
  }

  Future<bool> concluirSerie({
    required int id,
    required int cargaRealizadaGramas,
    required int repeticoesRealizadas,
    required int rirRealizado,
  }) async {
    _validarExecucaoSerie(
      cargaRealizadaGramas: cargaRealizadaGramas,
      repeticoesRealizadas: repeticoesRealizadas,
      rirRealizado: rirRealizado,
    );

    return transaction(() async {
      final serie = await (select(
        seriesRealizadas,
      )..where((tabela) => tabela.id.equals(id))).getSingleOrNull();

      if (serie == null) {
        return false;
      }

      final exercicio =
          await (select(exerciciosRealizados)..where(
                (tabela) => tabela.id.equals(serie.exercicioRealizadoId),
              ))
              .getSingleOrNull();

      if (exercicio == null) {
        throw StateError('O exercício realizado não foi encontrado.');
      }

      final agora = DateTime.now();

      final alteradas =
          await (update(
            seriesRealizadas,
          )..where((tabela) => tabela.id.equals(id))).write(
            SeriesRealizadasCompanion(
              situacao: Value(SituacaoSerieRealizada.concluida.name),
              cargaRealizadaGramas: Value(cargaRealizadaGramas),
              repeticoesRealizadas: Value(repeticoesRealizadas),
              rirRealizado: Value(rirRealizado),
              iniciadoEm: Value(serie.iniciadoEm ?? agora),
              finalizadoEm: Value(agora),
              atualizadoEm: Value(agora),
            ),
          );

      if (alteradas == 0) {
        return false;
      }

      await _atualizarSituacaoExercicio(exercicio, agora);
      await (update(treinosRealizados)
            ..where((tabela) => tabela.id.equals(exercicio.treinoRealizadoId)))
          .write(TreinosRealizadosCompanion(atualizadoEm: Value(agora)));

      return true;
    });
  }

  Future<bool> finalizarTreino({required int treinoRealizadoId}) async {
    return transaction(() async {
      final treino =
          await (select(treinosRealizados)
                ..where((tabela) => tabela.id.equals(treinoRealizadoId)))
              .getSingleOrNull();

      if (treino == null) {
        return false;
      }

      if (treino.situacao == SituacaoTreinoRealizado.concluido.name) {
        return true;
      }

      if (treino.situacao == SituacaoTreinoRealizado.cancelado.name) {
        throw StateError('Não é possível finalizar um treino cancelado.');
      }

      final agora = DateTime.now();

      final exercicios =
          await (select(exerciciosRealizados)..where(
                (tabela) => tabela.treinoRealizadoId.equals(treinoRealizadoId),
              ))
              .get();

      for (final exercicio in exercicios) {
        await (update(seriesRealizadas)..where(
              (tabela) =>
                  tabela.exercicioRealizadoId.equals(exercicio.id) &
                  tabela.situacao.equals(SituacaoSerieRealizada.pendente.name),
            ))
            .write(
              SeriesRealizadasCompanion(
                situacao: Value(SituacaoSerieRealizada.pulada.name),
                finalizadoEm: Value(agora),
                atualizadoEm: Value(agora),
              ),
            );

        final series =
            await (select(seriesRealizadas)..where(
                  (tabela) => tabela.exercicioRealizadoId.equals(exercicio.id),
                ))
                .get();

        final possuiSerieConcluida = series.any(
          (serie) => serie.situacao == SituacaoSerieRealizada.concluida.name,
        );

        await (update(
          exerciciosRealizados,
        )..where((tabela) => tabela.id.equals(exercicio.id))).write(
          ExerciciosRealizadosCompanion(
            situacao: Value(
              possuiSerieConcluida
                  ? SituacaoExercicioRealizado.concluido.name
                  : SituacaoExercicioRealizado.pulado.name,
            ),
            finalizadoEm: Value(agora),
            atualizadoEm: Value(agora),
          ),
        );
      }

      await (update(
        treinosRealizados,
      )..where((tabela) => tabela.id.equals(treinoRealizadoId))).write(
        TreinosRealizadosCompanion(
          situacao: Value(SituacaoTreinoRealizado.concluido.name),
          finalizadoEm: Value(agora),
          atualizadoEm: Value(agora),
        ),
      );

      return true;
    });
  }

  Future<void> _atualizarSituacaoExercicio(
    ExercicioRealizado exercicio,
    DateTime agora,
  ) async {
    final series =
        await (select(seriesRealizadas)..where(
              (tabela) => tabela.exercicioRealizadoId.equals(exercicio.id),
            ))
            .get();

    final todasFinalizadas =
        series.isNotEmpty &&
        series.every(
          (serie) =>
              serie.situacao == SituacaoSerieRealizada.concluida.name ||
              serie.situacao == SituacaoSerieRealizada.pulada.name,
        );

    await (update(
      exerciciosRealizados,
    )..where((tabela) => tabela.id.equals(exercicio.id))).write(
      ExerciciosRealizadosCompanion(
        situacao: Value(
          todasFinalizadas
              ? SituacaoExercicioRealizado.concluido.name
              : SituacaoExercicioRealizado.emExecucao.name,
        ),
        iniciadoEm: Value(exercicio.iniciadoEm ?? agora),
        finalizadoEm: Value(todasFinalizadas ? agora : null),
        atualizadoEm: Value(agora),
      ),
    );
  }

  Future<ResumoUltimaExecucao?> obterUltimaExecucaoExercicio({
    required int exercicioOrigemId,
  }) async {
    final ultimoExercicio =
        await (select(exerciciosRealizados).join([
                innerJoin(
                  treinosRealizados,
                  treinosRealizados.id.equalsExp(
                    exerciciosRealizados.treinoRealizadoId,
                  ),
                ),
              ])
              ..where(
                exerciciosRealizados.exercicioOrigemId.equals(
                  exercicioOrigemId,
                ),
              )
              ..where(
                treinosRealizados.situacao.equals(
                  SituacaoTreinoRealizado.concluido.name,
                ),
              )
              ..orderBy([
                OrderingTerm.desc(treinosRealizados.finalizadoEm),
                OrderingTerm.desc(treinosRealizados.id),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (ultimoExercicio == null) {
      return null;
    }

    final exercicio = ultimoExercicio.readTable(exerciciosRealizados);
    final treino = ultimoExercicio.readTable(treinosRealizados);

    final series =
        await (select(seriesRealizadas)
              ..where(
                (tabela) => tabela.exercicioRealizadoId.equals(exercicio.id),
              )
              ..where(
                (tabela) => tabela.situacao.equals(
                  SituacaoSerieRealizada.concluida.name,
                ),
              ))
            .get();

    if (series.isEmpty) {
      return null;
    }

    int? maiorCarga;
    int? maiorRepeticao;
    int? rir;

    for (final serie in series) {
      final carga = serie.cargaRealizadaGramas;
      final repeticoes = serie.repeticoesRealizadas;

      if (carga != null && (maiorCarga == null || carga > maiorCarga)) {
        maiorCarga = carga;
      }

      if (repeticoes != null &&
          (maiorRepeticao == null || repeticoes > maiorRepeticao)) {
        maiorRepeticao = repeticoes;
      }

      rir ??= serie.rirRealizado;
    }

    return ResumoUltimaExecucao(
      data: treino.finalizadoEm ?? treino.iniciadoEm,
      maiorCargaGramas: maiorCarga,
      maiorRepeticao: maiorRepeticao,
      rir: rir,
    );
  }

  Future<List<SerieUltimaExecucao>> obterSeriesUltimaExecucaoExercicio({
    required int exercicioOrigemId,
  }) async {
    final ultimoExercicio =
        await (select(exerciciosRealizados).join([
                innerJoin(
                  treinosRealizados,
                  treinosRealizados.id.equalsExp(
                    exerciciosRealizados.treinoRealizadoId,
                  ),
                ),
              ])
              ..where(
                exerciciosRealizados.exercicioOrigemId.equals(
                  exercicioOrigemId,
                ),
              )
              ..where(
                treinosRealizados.situacao.equals(
                  SituacaoTreinoRealizado.concluido.name,
                ),
              )
              ..orderBy([
                OrderingTerm.desc(treinosRealizados.finalizadoEm),
                OrderingTerm.desc(treinosRealizados.id),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (ultimoExercicio == null) {
      return const [];
    }

    final exercicio = ultimoExercicio.readTable(exerciciosRealizados);

    final series =
        await (select(seriesRealizadas)
              ..where(
                (tabela) => tabela.exercicioRealizadoId.equals(exercicio.id),
              )
              ..where(
                (tabela) => tabela.situacao.equals(
                  SituacaoSerieRealizada.concluida.name,
                ),
              )
              ..orderBy([
                (tabela) => OrderingTerm.asc(tabela.ordem),
                (tabela) => OrderingTerm.asc(tabela.id),
              ]))
            .get();

    return series.map((serie) {
      return SerieUltimaExecucao(
        ordem: serie.ordem,
        cargaGramas: serie.cargaRealizadaGramas,
        repeticoes: serie.repeticoesRealizadas,
        rir: serie.rirRealizado,
      );
    }).toList();
  }

  Future<ResumoTreinoConcluido> obterResumoTreinoConcluido({
    required int treinoRealizadoId,
  }) async {
    final treino =
        await (select(treinosRealizados)
              ..where((tabela) => tabela.id.equals(treinoRealizadoId)))
            .getSingleOrNull();

    if (treino == null) {
      throw ArgumentError('O treino realizado não foi encontrado.');
    }

    final detalhes = await listarSeriesDoTreino(treinoRealizadoId);

    final seriesConcluidas = detalhes
        .where(
          (detalhe) =>
              detalhe.serie.situacao == SituacaoSerieRealizada.concluida.name,
        )
        .toList();

    final exerciciosExecutados = <int>{
      for (final detalhe in seriesConcluidas) detalhe.exercicio.id,
    };

    var volumeTotalGramas = 0;

    for (final detalhe in seriesConcluidas) {
      final carga = detalhe.serie.cargaRealizadaGramas ?? 0;
      final repeticoes = detalhe.serie.repeticoesRealizadas ?? 0;

      volumeTotalGramas += carga * repeticoes;
    }

    final evolucoes = await _calcularEvolucoesDoTreino(
      treino: treino,
      detalhesAtuais: seriesConcluidas,
    );

    final finalizadoEm = treino.finalizadoEm ?? DateTime.now();
    final duracao = finalizadoEm.difference(treino.iniciadoEm);

    return ResumoTreinoConcluido(
      nomeTreino: treino.nomeFichaSnapshot,
      duracao: duracao.isNegative ? Duration.zero : duracao,
      quantidadeExercicios: exerciciosExecutados.length,
      quantidadeSeries: seriesConcluidas.length,
      volumeTotalGramas: volumeTotalGramas,
      evolucoes: evolucoes,
    );
  }

  Future<List<EvolucaoExercicio>> _calcularEvolucoesDoTreino({
    required TreinoRealizado treino,
    required List<SerieTreinoDetalhe> detalhesAtuais,
  }) async {
    final gruposAtuais = <int, List<SerieTreinoDetalhe>>{};

    for (final detalhe in detalhesAtuais) {
      gruposAtuais.putIfAbsent(detalhe.exercicio.id, () => []).add(detalhe);
    }

    final evolucoes = <EvolucaoExercicio>[];

    for (final grupo in gruposAtuais.values) {
      final exercicioAtual = grupo.first.exercicio;
      final exercicioOrigemId = exercicioAtual.exercicioOrigemId;

      if (exercicioOrigemId == null) {
        continue;
      }

      final exercicioAnterior = await _obterExecucaoAnteriorDoExercicio(
        exercicioOrigemId: exercicioOrigemId,
        treinoAtual: treino,
      );

      if (exercicioAnterior == null) {
        continue;
      }

      final seriesAnteriores =
          await (select(seriesRealizadas)
                ..where(
                  (tabela) =>
                      tabela.exercicioRealizadoId.equals(exercicioAnterior.id),
                )
                ..where(
                  (tabela) => tabela.situacao.equals(
                    SituacaoSerieRealizada.concluida.name,
                  ),
                )
                ..orderBy([
                  (tabela) => OrderingTerm.asc(tabela.ordem),
                  (tabela) => OrderingTerm.asc(tabela.id),
                ]))
              .get();

      final anterioresPorOrdem = <int, SerieRealizada>{
        for (final serie in seriesAnteriores) serie.ordem: serie,
      };

      _ComparacaoSerie? melhorComparacao;

      for (final detalheAtual in grupo) {
        final serieAtual = detalheAtual.serie;
        final serieAnterior = anterioresPorOrdem[serieAtual.ordem];

        if (serieAnterior == null) {
          continue;
        }

        final cargaAtual = serieAtual.cargaRealizadaGramas;
        final repeticoesAtuais = serieAtual.repeticoesRealizadas;
        final cargaAnterior = serieAnterior.cargaRealizadaGramas;
        final repeticoesAnteriores = serieAnterior.repeticoesRealizadas;

        if (cargaAtual == null ||
            repeticoesAtuais == null ||
            cargaAnterior == null ||
            repeticoesAnteriores == null) {
          continue;
        }

        final diferencaCarga = cargaAtual - cargaAnterior;
        final diferencaRepeticoes = repeticoesAtuais - repeticoesAnteriores;

        final evolucaoObjetiva =
            diferencaCarga >= 0 &&
            diferencaRepeticoes >= 0 &&
            (diferencaCarga > 0 || diferencaRepeticoes > 0);

        if (!evolucaoObjetiva) {
          continue;
        }

        final comparacao = _ComparacaoSerie(
          cargaAtualGramas: cargaAtual,
          repeticoesAtuais: repeticoesAtuais,
          diferencaCargaGramas: diferencaCarga,
          diferencaRepeticoes: diferencaRepeticoes,
        );

        if (melhorComparacao == null ||
            comparacao.ehMaiorQue(melhorComparacao)) {
          melhorComparacao = comparacao;
        }
      }

      if (melhorComparacao == null) {
        continue;
      }

      evolucoes.add(
        EvolucaoExercicio(
          nomeExercicio: exercicioAtual.nomeExercicioSnapshot,
          cargaAtualGramas: melhorComparacao.cargaAtualGramas,
          repeticoesAtuais: melhorComparacao.repeticoesAtuais,
          diferencaCargaGramas: melhorComparacao.diferencaCargaGramas,
          diferencaRepeticoes: melhorComparacao.diferencaRepeticoes,
        ),
      );
    }

    evolucoes.sort((a, b) {
      final porCarga = b.diferencaCargaGramas.compareTo(a.diferencaCargaGramas);

      if (porCarga != 0) {
        return porCarga;
      }

      final porRepeticoes = b.diferencaRepeticoes.compareTo(
        a.diferencaRepeticoes,
      );

      if (porRepeticoes != 0) {
        return porRepeticoes;
      }

      return a.nomeExercicio.compareTo(b.nomeExercicio);
    });

    return evolucoes;
  }

  Future<ExercicioRealizado?> _obterExecucaoAnteriorDoExercicio({
    required int exercicioOrigemId,
    required TreinoRealizado treinoAtual,
  }) async {
    final linha =
        await (select(exerciciosRealizados).join([
                innerJoin(
                  treinosRealizados,
                  treinosRealizados.id.equalsExp(
                    exerciciosRealizados.treinoRealizadoId,
                  ),
                ),
              ])
              ..where(
                exerciciosRealizados.exercicioOrigemId.equals(
                  exercicioOrigemId,
                ),
              )
              ..where(treinosRealizados.id.isNotValue(treinoAtual.id))
              ..where(
                treinosRealizados.situacao.equals(
                  SituacaoTreinoRealizado.concluido.name,
                ),
              )
              ..where(
                treinosRealizados.iniciadoEm.isSmallerThanValue(
                  treinoAtual.iniciadoEm,
                ),
              )
              ..orderBy([
                OrderingTerm.desc(treinosRealizados.iniciadoEm),
                OrderingTerm.desc(treinosRealizados.id),
              ])
              ..limit(1))
            .getSingleOrNull();

    return linha?.readTable(exerciciosRealizados);
  }

  void _validarExecucaoSerie({
    required int cargaRealizadaGramas,
    required int repeticoesRealizadas,
    required int rirRealizado,
  }) {
    if (cargaRealizadaGramas < 0) {
      throw ArgumentError('A carga realizada não pode ser negativa.');
    }

    if (repeticoesRealizadas < 0) {
      throw ArgumentError('As repetições realizadas não podem ser negativas.');
    }

    if (rirRealizado < 0 || rirRealizado > 5) {
      throw ArgumentError('O RIR realizado deve estar entre 0 e 5.');
    }
  }
}

class _ComparacaoSerie {
  const _ComparacaoSerie({
    required this.cargaAtualGramas,
    required this.repeticoesAtuais,
    required this.diferencaCargaGramas,
    required this.diferencaRepeticoes,
  });

  final int cargaAtualGramas;
  final int repeticoesAtuais;
  final int diferencaCargaGramas;
  final int diferencaRepeticoes;

  bool ehMaiorQue(_ComparacaoSerie outra) {
    if (diferencaCargaGramas != outra.diferencaCargaGramas) {
      return diferencaCargaGramas > outra.diferencaCargaGramas;
    }

    if (diferencaRepeticoes != outra.diferencaRepeticoes) {
      return diferencaRepeticoes > outra.diferencaRepeticoes;
    }

    if (cargaAtualGramas != outra.cargaAtualGramas) {
      return cargaAtualGramas > outra.cargaAtualGramas;
    }

    return repeticoesAtuais > outra.repeticoesAtuais;
  }
}
