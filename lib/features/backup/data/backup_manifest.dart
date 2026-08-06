class BackupManifest {
  const BackupManifest({
    required this.aplicativo,
    required this.versaoAplicativo,
    required this.buildAplicativo,
    required this.versaoFormato,
    required this.versaoBanco,
    required this.versaoBiblioteca,
    required this.criadoEm,
    required this.plataforma,
    required this.estatisticas,
  });

  final String aplicativo;
  final String versaoAplicativo;
  final int buildAplicativo;
  final int versaoFormato;
  final int versaoBanco;
  final int? versaoBiblioteca;
  final DateTime criadoEm;
  final String plataforma;
  final BackupEstatisticas estatisticas;

  Map<String, dynamic> toJson() {
    return {
      'aplicativo': aplicativo,
      'versaoAplicativo': versaoAplicativo,
      'buildAplicativo': buildAplicativo,
      'versaoFormato': versaoFormato,
      'versaoBanco': versaoBanco,
      'versaoBiblioteca': versaoBiblioteca,
      'criadoEm': criadoEm.toIso8601String(),
      'plataforma': plataforma,
      'estatisticas': estatisticas.toJson(),
    };
  }

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      aplicativo: json['aplicativo'] as String,
      versaoAplicativo: json['versaoAplicativo'] as String,
      buildAplicativo: json['buildAplicativo'] as int,
      versaoFormato: json['versaoFormato'] as int,
      versaoBanco: json['versaoBanco'] as int,
      versaoBiblioteca: json['versaoBiblioteca'] as int?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      plataforma: json['plataforma'] as String,
      estatisticas: BackupEstatisticas.fromJson(
        json['estatisticas'] as Map<String, dynamic>,
      ),
    );
  }
}

class BackupEstatisticas {
  const BackupEstatisticas({
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

  Map<String, dynamic> toJson() {
    return {
      'gruposMusculares': gruposMusculares,
      'exercicios': exercicios,
      'fichasTreino': fichasTreino,
      'planosTreino': planosTreino,
      'treinosRealizados': treinosRealizados,
      'exerciciosRealizados': exerciciosRealizados,
      'seriesRealizadas': seriesRealizadas,
      'execucoesPlano': execucoesPlano,
    };
  }

  factory BackupEstatisticas.fromJson(Map<String, dynamic> json) {
    return BackupEstatisticas(
      gruposMusculares: json['gruposMusculares'] as int,
      exercicios: json['exercicios'] as int,
      fichasTreino: json['fichasTreino'] as int,
      planosTreino: json['planosTreino'] as int,
      treinosRealizados: json['treinosRealizados'] as int,
      exerciciosRealizados: json['exerciciosRealizados'] as int,
      seriesRealizadas: json['seriesRealizadas'] as int,
      execucoesPlano: json['execucoesPlano'] as int,
    );
  }
}
