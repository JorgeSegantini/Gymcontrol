class BibliotecaGrupoMuscular {
  final String codigo;
  final String nome;
  final int ordem;

  const BibliotecaGrupoMuscular({
    required this.codigo,
    required this.nome,
    required this.ordem,
  });

  factory BibliotecaGrupoMuscular.fromJson(Map<String, dynamic> json) {
    return BibliotecaGrupoMuscular(
      codigo: json['codigo'] as String,
      nome: json['nome'] as String,
      ordem: json['ordem'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'nome': nome, 'ordem': ordem};
  }
}
