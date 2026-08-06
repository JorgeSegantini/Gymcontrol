import '../../../core/database/app_database.dart';
import '../../../core/database/treino_tables.dart';
import 'historico_models.dart';

class HistoricoService {
  HistoricoService(this._database);

  final AppDatabase _database;

  Future<List<HistoricoExercicioDetalhe>> listarExerciciosDoTreino(
    int treinoRealizadoId,
  ) async {
    final exercicios = await _database.treinoRealizadoDao
        .listarExerciciosDoTreino(treinoRealizadoId);

    final resultado = <HistoricoExercicioDetalhe>[];

    for (final exercicio in exercicios) {
      final series = await _database.treinoRealizadoDao.listarSeriesDoExercicio(
        exercicio.id,
      );

      resultado.add(
        HistoricoExercicioDetalhe(
          id: exercicio.id,
          nome: exercicio.nomeExercicioSnapshot,
          ordem: exercicio.ordem,
          series: series.map((serie) {
            return HistoricoSerieDetalhe(
              ordem: serie.ordem,
              situacao: serie.situacao,
              cargaGramas: serie.cargaRealizadaGramas,
              repeticoes: serie.repeticoesRealizadas,
              rir: serie.rirRealizado,
            );
          }).toList(),
        ),
      );
    }

    return resultado;
  }

  Future<List<HistoricoGrupoDia>> listarGrupos() async {
    final treinos = await _database.treinoRealizadoDao
        .observarTreinos(incluirCancelados: false)
        .first;

    final concluidos = treinos.where((treino) {
      return treino.situacao == SituacaoTreinoRealizado.concluido.name;
    }).toList();

    final resumos = <HistoricoTreinoResumo>[];

    for (final treino in concluidos) {
      final resumo = await _database.treinoRealizadoDao
          .obterResumoTreinoConcluido(treinoRealizadoId: treino.id);

      final finalizadoEm = treino.finalizadoEm ?? treino.iniciadoEm;

      resumos.add(
        HistoricoTreinoResumo(
          id: treino.id,
          nome: treino.nomeFichaSnapshot,
          iniciadoEm: treino.iniciadoEm,
          finalizadoEm: finalizadoEm,
          duracao: resumo.duracao,
          quantidadeExercicios: resumo.quantidadeExercicios,
          quantidadeSeries: resumo.quantidadeSeries,
          volumeTotalGramas: resumo.volumeTotalGramas,
        ),
      );
    }

    resumos.sort((a, b) {
      final porData = b.finalizadoEm.compareTo(a.finalizadoEm);

      if (porData != 0) {
        return porData;
      }

      return b.id.compareTo(a.id);
    });

    final porDia = <DateTime, List<HistoricoTreinoResumo>>{};

    for (final resumo in resumos) {
      porDia.putIfAbsent(resumo.data, () => []).add(resumo);
    }

    return porDia.entries.map((entry) {
      return HistoricoGrupoDia(data: entry.key, treinos: entry.value);
    }).toList();
  }
}
