class ResumoUltimaExecucao {
  const ResumoUltimaExecucao({
    required this.data,
    required this.maiorCargaGramas,
    required this.maiorRepeticao,
    required this.rir,
  });

  final DateTime data;
  final int? maiorCargaGramas;
  final int? maiorRepeticao;
  final int? rir;
}
