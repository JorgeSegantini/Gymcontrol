class HistoricoTreinoResumo {
  const HistoricoTreinoResumo({
    required this.id,
    required this.nome,
    required this.iniciadoEm,
    required this.finalizadoEm,
    required this.duracao,
    required this.quantidadeExercicios,
    required this.quantidadeSeries,
    required this.volumeTotalGramas,
  });

  final int id;
  final String nome;
  final DateTime iniciadoEm;
  final DateTime finalizadoEm;
  final Duration duracao;
  final int quantidadeExercicios;
  final int quantidadeSeries;
  final int volumeTotalGramas;

  DateTime get data {
    return DateTime(finalizadoEm.year, finalizadoEm.month, finalizadoEm.day);
  }
}

class HistoricoGrupoDia {
  const HistoricoGrupoDia({required this.data, required this.treinos});

  final DateTime data;
  final List<HistoricoTreinoResumo> treinos;
}

class HistoricoExercicioDetalhe {
  const HistoricoExercicioDetalhe({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.series,
  });

  final int id;
  final String nome;
  final int ordem;
  final List<HistoricoSerieDetalhe> series;

  int get quantidadeSeriesConcluidas {
    return series.where((serie) => serie.concluida).length;
  }

  int get volumeTotalGramas {
    return series.fold<int>(0, (total, serie) => total + serie.volumeGramas);
  }
}

class HistoricoSerieDetalhe {
  const HistoricoSerieDetalhe({
    required this.ordem,
    required this.situacao,
    required this.cargaGramas,
    required this.repeticoes,
    required this.rir,
  });

  final int ordem;
  final String situacao;
  final int? cargaGramas;
  final int? repeticoes;
  final int? rir;

  bool get concluida => situacao == 'concluida';

  int get volumeGramas {
    if (!concluida) {
      return 0;
    }

    return (cargaGramas ?? 0) * (repeticoes ?? 0);
  }
}
