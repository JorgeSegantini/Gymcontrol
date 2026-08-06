import 'app_database.dart';

class DadosExercicio {
  const DadosExercicio({
    required this.grupoMuscularId,
    required this.nome,
    required this.tipo,
    required this.equipamento,
    required this.nivelDificuldade,
    required this.velocidadeExecucao,
    this.nomeCurto,
    this.codigoBiblioteca,
    this.familia,
    this.variante,
    this.instrucoes,
    this.dicas,
    this.errosComuns,
    this.popularidade = 0,
    this.ordem = 0,
  });

  final int grupoMuscularId;
  final String nome;
  final String? nomeCurto;
  final TipoExercicio tipo;
  final EquipamentoExercicio equipamento;
  final NivelDificuldadeExercicio nivelDificuldade;
  final VelocidadeExecucao velocidadeExecucao;

  final String? codigoBiblioteca;
  final String? familia;
  final String? variante;
  final String? instrucoes;
  final String? dicas;
  final String? errosComuns;

  final int popularidade;
  final int ordem;
}
