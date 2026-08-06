class EvolucaoExercicioResumo {
  const EvolucaoExercicioResumo({
    required this.exercicioOrigemId,
    required this.nome,
    required this.quantidadeExecucoes,
    required this.ultimaData,
    required this.ultimaCargaGramas,
    required this.ultimasRepeticoes,
    required this.ultimoRir,
  });

  final int exercicioOrigemId;
  final String nome;
  final int quantidadeExecucoes;
  final DateTime ultimaData;
  final int? ultimaCargaGramas;
  final int? ultimasRepeticoes;
  final int? ultimoRir;
}

enum TendenciaExercicio { evoluindo, estavel, atencao, insuficiente }

class EvolucaoExercicioDetalhes {
  const EvolucaoExercicioDetalhes({
    required this.exercicioOrigemId,
    required this.nome,
    required this.quantidadeExecucoes,
    required this.primeiraExecucao,
    required this.ultimaExecucao,
    required this.maiorCarga,
    required this.maiorRepeticao,
    required this.maiorVolume,
    required this.tendencia,
    required this.execucoes,
  });

  final int exercicioOrigemId;
  final String nome;
  final int quantidadeExecucoes;
  final DateTime primeiraExecucao;
  final EvolucaoExecucaoItem ultimaExecucao;
  final EvolucaoRecorde maiorCarga;
  final EvolucaoRecorde maiorRepeticao;
  final EvolucaoRecorde maiorVolume;
  final TendenciaExercicio tendencia;
  final List<EvolucaoExecucaoItem> execucoes;
}

class EvolucaoRecorde {
  const EvolucaoRecorde({required this.valor, required this.data});

  final int valor;
  final DateTime data;
}

class EvolucaoExecucaoItem {
  const EvolucaoExecucaoItem({
    required this.treinoRealizadoId,
    required this.nomeTreino,
    required this.data,
    required this.maiorCargaGramas,
    required this.maiorRepeticao,
    required this.rir,
    required this.volumeTotalGramas,
    required this.recordeCarga,
    required this.recordeRepeticao,
    required this.recordeVolume,
  });

  final int treinoRealizadoId;
  final String nomeTreino;
  final DateTime data;
  final int maiorCargaGramas;
  final int maiorRepeticao;
  final int? rir;
  final int volumeTotalGramas;
  final bool recordeCarga;
  final bool recordeRepeticao;
  final bool recordeVolume;

  bool get possuiRecorde {
    return recordeCarga || recordeRepeticao || recordeVolume;
  }
}
