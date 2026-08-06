import '../../../core/database/app_database.dart';
import '../../../core/database/treino_tables.dart';
import 'evolucao_models.dart';

class EvolucaoService {
  EvolucaoService(this._database);

  final AppDatabase _database;

  Future<EvolucaoExercicioDetalhes> obterDetalhesExercicio({
    required int exercicioOrigemId,
    required String nomeExercicio,
  }) async {
    final treinos = await _database.treinoRealizadoDao
        .observarTreinos(incluirCancelados: false)
        .first;

    final concluidos = treinos.where((treino) {
      return treino.situacao == SituacaoTreinoRealizado.concluido.name;
    }).toList();

    final execucoesBrutas = <_ExecucaoBruta>[];

    for (final treino in concluidos) {
      final exercicios = await _database.treinoRealizadoDao
          .listarExerciciosDoTreino(treino.id);

      final exerciciosCorrespondentes = exercicios.where((exercicio) {
        return exercicio.exercicioOrigemId == exercicioOrigemId;
      });

      for (final exercicio in exerciciosCorrespondentes) {
        final series = await _database.treinoRealizadoDao
            .listarSeriesDoExercicio(exercicio.id);

        final concluidas = series.where((serie) {
          return serie.situacao == SituacaoSerieRealizada.concluida.name;
        }).toList();

        if (concluidas.isEmpty) {
          continue;
        }

        var maiorCarga = 0;
        var maiorRepeticao = 0;
        var volumeTotal = 0;
        int? rirDaMelhorSerie;

        for (final serie in concluidas) {
          final carga = serie.cargaRealizadaGramas ?? 0;
          final repeticoes = serie.repeticoesRealizadas ?? 0;

          volumeTotal += carga * repeticoes;

          final serieMelhorQueAtual =
              carga > maiorCarga ||
              (carga == maiorCarga && repeticoes > maiorRepeticao);

          if (serieMelhorQueAtual) {
            maiorCarga = carga;
            maiorRepeticao = repeticoes;
            rirDaMelhorSerie = serie.rirRealizado;
          } else if (repeticoes > maiorRepeticao) {
            maiorRepeticao = repeticoes;
          }
        }

        execucoesBrutas.add(
          _ExecucaoBruta(
            treinoRealizadoId: treino.id,
            nomeTreino: treino.nomeFichaSnapshot,
            data: treino.finalizadoEm ?? treino.iniciadoEm,
            maiorCargaGramas: maiorCarga,
            maiorRepeticao: maiorRepeticao,
            rir: rirDaMelhorSerie,
            volumeTotalGramas: volumeTotal,
          ),
        );
      }
    }

    if (execucoesBrutas.isEmpty) {
      throw StateError('Não existem execuções concluídas para este exercício.');
    }

    execucoesBrutas.sort((a, b) => a.data.compareTo(b.data));

    final maiorCargaBruta = execucoesBrutas.reduce((a, b) {
      return b.maiorCargaGramas > a.maiorCargaGramas ? b : a;
    });

    final maiorRepeticaoBruta = execucoesBrutas.reduce((a, b) {
      return b.maiorRepeticao > a.maiorRepeticao ? b : a;
    });

    final maiorVolumeBruta = execucoesBrutas.reduce((a, b) {
      return b.volumeTotalGramas > a.volumeTotalGramas ? b : a;
    });

    final execucoes = execucoesBrutas.map((execucao) {
      return EvolucaoExecucaoItem(
        treinoRealizadoId: execucao.treinoRealizadoId,
        nomeTreino: execucao.nomeTreino,
        data: execucao.data,
        maiorCargaGramas: execucao.maiorCargaGramas,
        maiorRepeticao: execucao.maiorRepeticao,
        rir: execucao.rir,
        volumeTotalGramas: execucao.volumeTotalGramas,
        recordeCarga:
            execucao.maiorCargaGramas == maiorCargaBruta.maiorCargaGramas,
        recordeRepeticao:
            execucao.maiorRepeticao == maiorRepeticaoBruta.maiorRepeticao,
        recordeVolume:
            execucao.volumeTotalGramas == maiorVolumeBruta.volumeTotalGramas,
      );
    }).toList()..sort((a, b) => b.data.compareTo(a.data));

    final tendencia = _calcularTendencia(execucoes);

    return EvolucaoExercicioDetalhes(
      exercicioOrigemId: exercicioOrigemId,
      nome: nomeExercicio,
      quantidadeExecucoes: execucoes.length,
      primeiraExecucao: execucoesBrutas.first.data,
      ultimaExecucao: execucoes.first,
      maiorCarga: EvolucaoRecorde(
        valor: maiorCargaBruta.maiorCargaGramas,
        data: maiorCargaBruta.data,
      ),
      maiorRepeticao: EvolucaoRecorde(
        valor: maiorRepeticaoBruta.maiorRepeticao,
        data: maiorRepeticaoBruta.data,
      ),
      maiorVolume: EvolucaoRecorde(
        valor: maiorVolumeBruta.volumeTotalGramas,
        data: maiorVolumeBruta.data,
      ),
      tendencia: tendencia,
      execucoes: execucoes,
    );
  }

  TendenciaExercicio _calcularTendencia(List<EvolucaoExecucaoItem> execucoes) {
    if (execucoes.length < 2) {
      return TendenciaExercicio.insuficiente;
    }

    final atual = execucoes[0];
    final anterior = execucoes[1];

    if (atual.maiorCargaGramas > anterior.maiorCargaGramas ||
        (atual.maiorCargaGramas == anterior.maiorCargaGramas &&
            atual.maiorRepeticao > anterior.maiorRepeticao)) {
      return TendenciaExercicio.evoluindo;
    }

    if (atual.maiorCargaGramas == anterior.maiorCargaGramas &&
        atual.maiorRepeticao == anterior.maiorRepeticao) {
      return TendenciaExercicio.estavel;
    }

    return TendenciaExercicio.atencao;
  }

  Future<List<EvolucaoExercicioResumo>> listarExercicios() async {
    final treinos = await _database.treinoRealizadoDao
        .observarTreinos(incluirCancelados: false)
        .first;

    final concluidos = treinos.where((treino) {
      return treino.situacao == SituacaoTreinoRealizado.concluido.name;
    }).toList();

    final acumulados = <int, _ExercicioAcumulado>{};

    for (final treino in concluidos) {
      final exercicios = await _database.treinoRealizadoDao
          .listarExerciciosDoTreino(treino.id);

      for (final exercicio in exercicios) {
        final exercicioOrigemId = exercicio.exercicioOrigemId;

        if (exercicioOrigemId == null) {
          continue;
        }

        final series = await _database.treinoRealizadoDao
            .listarSeriesDoExercicio(exercicio.id);

        final concluidas = series.where((serie) {
          return serie.situacao == SituacaoSerieRealizada.concluida.name;
        }).toList();

        if (concluidas.isEmpty) {
          continue;
        }

        concluidas.sort((a, b) {
          final porCarga = (b.cargaRealizadaGramas ?? -1).compareTo(
            a.cargaRealizadaGramas ?? -1,
          );

          if (porCarga != 0) {
            return porCarga;
          }

          final porRepeticoes = (b.repeticoesRealizadas ?? -1).compareTo(
            a.repeticoesRealizadas ?? -1,
          );

          if (porRepeticoes != 0) {
            return porRepeticoes;
          }

          return a.ordem.compareTo(b.ordem);
        });

        final melhorSerie = concluidas.first;
        final dataExecucao = treino.finalizadoEm ?? treino.iniciadoEm;

        final acumulado = acumulados.putIfAbsent(
          exercicioOrigemId,
          () => _ExercicioAcumulado(
            exercicioOrigemId: exercicioOrigemId,
            nome: exercicio.nomeExercicioSnapshot,
          ),
        );

        acumulado.registrarExecucao(
          data: dataExecucao,
          cargaGramas: melhorSerie.cargaRealizadaGramas,
          repeticoes: melhorSerie.repeticoesRealizadas,
          rir: melhorSerie.rirRealizado,
        );
      }
    }

    final resultado = acumulados.values.map((item) {
      return EvolucaoExercicioResumo(
        exercicioOrigemId: item.exercicioOrigemId,
        nome: item.nome,
        quantidadeExecucoes: item.quantidadeExecucoes,
        ultimaData: item.ultimaData!,
        ultimaCargaGramas: item.ultimaCargaGramas,
        ultimasRepeticoes: item.ultimasRepeticoes,
        ultimoRir: item.ultimoRir,
      );
    }).toList();

    resultado.sort((a, b) {
      final porData = b.ultimaData.compareTo(a.ultimaData);

      if (porData != 0) {
        return porData;
      }

      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });

    return resultado;
  }
}

class _ExercicioAcumulado {
  _ExercicioAcumulado({required this.exercicioOrigemId, required this.nome});

  final int exercicioOrigemId;
  final String nome;

  int quantidadeExecucoes = 0;
  DateTime? ultimaData;
  int? ultimaCargaGramas;
  int? ultimasRepeticoes;
  int? ultimoRir;

  void registrarExecucao({
    required DateTime data,
    required int? cargaGramas,
    required int? repeticoes,
    required int? rir,
  }) {
    quantidadeExecucoes += 1;

    if (ultimaData == null || data.isAfter(ultimaData!)) {
      ultimaData = data;
      ultimaCargaGramas = cargaGramas;
      ultimasRepeticoes = repeticoes;
      ultimoRir = rir;
    }
  }
}

class _ExecucaoBruta {
  const _ExecucaoBruta({
    required this.treinoRealizadoId,
    required this.nomeTreino,
    required this.data,
    required this.maiorCargaGramas,
    required this.maiorRepeticao,
    required this.rir,
    required this.volumeTotalGramas,
  });

  final int treinoRealizadoId;
  final String nomeTreino;
  final DateTime data;
  final int maiorCargaGramas;
  final int maiorRepeticao;
  final int? rir;
  final int volumeTotalGramas;
}
