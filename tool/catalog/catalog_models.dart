class CatalogoGrupo {
  const CatalogoGrupo({
    required this.codigo,
    required this.nome,
    required this.exercicios,
  });

  final String codigo;
  final String nome;
  final List<CatalogoExercicio> exercicios;
}

class CatalogoExercicio {
  const CatalogoExercicio({
    required this.codigo,
    required this.nome,
    required this.nomeCurto,
    required this.grupoPrincipalCodigo,
    required this.equipamento,
    required this.familia,
    required this.variante,
    required this.nivel,
    required this.popularidade,
    required this.ordem,
    this.aliases = const [],
    this.gruposSecundarios = const [],
    this.ativo = true,
  });

  final String codigo;
  final String nome;
  final String nomeCurto;
  final String grupoPrincipalCodigo;
  final String equipamento;
  final String familia;
  final String variante;
  final String nivel;
  final int popularidade;
  final int ordem;
  final List<String> aliases;
  final List<String> gruposSecundarios;
  final bool ativo;
}
