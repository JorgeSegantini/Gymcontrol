class ManutencaoBancoInfo {
  const ManutencaoBancoInfo({
    required this.gruposMusculares,
    required this.exercicios,
    required this.fichasTreino,
    required this.planosTreino,
    required this.treinosRealizados,
    required this.exerciciosRealizados,
    required this.seriesRealizadas,
    required this.execucoesPlano,
  });

  final int gruposMusculares;
  final int exercicios;
  final int fichasTreino;
  final int planosTreino;
  final int treinosRealizados;
  final int exerciciosRealizados;
  final int seriesRealizadas;
  final int execucoesPlano;

  bool get possuiHistorico {
    return treinosRealizados > 0 ||
        exerciciosRealizados > 0 ||
        seriesRealizadas > 0 ||
        execucoesPlano > 0;
  }
}
