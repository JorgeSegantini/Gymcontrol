import 'evolucao_exercicio.dart';

class ResumoTreinoConcluido {
  const ResumoTreinoConcluido({
    required this.nomeTreino,
    required this.duracao,
    required this.quantidadeExercicios,
    required this.quantidadeSeries,
    required this.volumeTotalGramas,
    required this.evolucoes,
  });

  final String nomeTreino;
  final Duration duracao;
  final int quantidadeExercicios;
  final int quantidadeSeries;
  final int volumeTotalGramas;
  final List<EvolucaoExercicio> evolucoes;
}
