class BibliotecaQuantidades {
  final int grupos;
  final int categoriasEquipamentos;
  final int equipamentos;
  final int padroesMotores;
  final int movimentos;
  final int variacoes;
  final int niveis;
  final int tags;
  final int aliases;
  final int exercicios;

  const BibliotecaQuantidades({
    required this.grupos,
    required this.categoriasEquipamentos,
    required this.equipamentos,
    required this.padroesMotores,
    required this.movimentos,
    required this.variacoes,
    required this.niveis,
    required this.tags,
    required this.aliases,
    required this.exercicios,
  });

  factory BibliotecaQuantidades.fromJson(Map<String, dynamic> json) {
    return BibliotecaQuantidades(
      grupos: json['grupos'] as int,
      categoriasEquipamentos: json['categoriasEquipamentos'] as int,
      equipamentos: json['equipamentos'] as int,
      padroesMotores: json['padroesMotores'] as int,
      movimentos: json['movimentos'] as int,
      variacoes: json['variacoes'] as int,
      niveis: json['niveis'] as int,
      tags: json['tags'] as int,
      aliases: json['aliases'] as int,
      exercicios: json['exercicios'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupos': grupos,
      'categoriasEquipamentos': categoriasEquipamentos,
      'equipamentos': equipamentos,
      'padroesMotores': padroesMotores,
      'movimentos': movimentos,
      'variacoes': variacoes,
      'niveis': niveis,
      'tags': tags,
      'aliases': aliases,
      'exercicios': exercicios,
    };
  }
}

class BibliotecaVersao {
  final int versao;
  final DateTime data;
  final String? hash;
  final BibliotecaQuantidades quantidades;

  const BibliotecaVersao({
    required this.versao,
    required this.data,
    required this.hash,
    required this.quantidades,
  });

  factory BibliotecaVersao.fromJson(Map<String, dynamic> json) {
    return BibliotecaVersao(
      versao: json['versao'] as int,
      data: DateTime.parse(json['data'] as String),
      hash: json['hash'] as String?,
      quantidades: BibliotecaQuantidades.fromJson(
        json['quantidades'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versao': versao,
      'data': data.toIso8601String(),
      'hash': hash,
      'quantidades': quantidades.toJson(),
    };
  }
}
