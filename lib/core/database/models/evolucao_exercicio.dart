class EvolucaoExercicio {
  const EvolucaoExercicio({
    required this.nomeExercicio,
    required this.cargaAtualGramas,
    required this.repeticoesAtuais,
    required this.diferencaCargaGramas,
    required this.diferencaRepeticoes,
  });

  final String nomeExercicio;
  final int cargaAtualGramas;
  final int repeticoesAtuais;
  final int diferencaCargaGramas;
  final int diferencaRepeticoes;
}
