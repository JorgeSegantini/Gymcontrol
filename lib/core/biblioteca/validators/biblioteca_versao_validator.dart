import 'package:gym_control/core/biblioteca/models/versao/biblioteca_versao.dart';

class BibliotecaVersaoValidator {
  const BibliotecaVersaoValidator();

  void validar(BibliotecaVersao biblioteca) {
    if (biblioteca.versao <= 0) {
      throw const FormatException(
        'A versão da biblioteca deve ser maior que zero.',
      );
    }

    _validarNaoNegativo(biblioteca.quantidades.grupos, 'grupos musculares');

    _validarNaoNegativo(
      biblioteca.quantidades.categoriasEquipamentos,
      'categorias de equipamentos',
    );

    _validarNaoNegativo(biblioteca.quantidades.equipamentos, 'equipamentos');

    _validarNaoNegativo(
      biblioteca.quantidades.padroesMotores,
      'padrões motores',
    );

    _validarNaoNegativo(biblioteca.quantidades.movimentos, 'movimentos');

    _validarNaoNegativo(biblioteca.quantidades.variacoes, 'variações');

    _validarNaoNegativo(biblioteca.quantidades.niveis, 'níveis');

    _validarNaoNegativo(biblioteca.quantidades.tags, 'tags');

    _validarNaoNegativo(biblioteca.quantidades.aliases, 'aliases');

    _validarNaoNegativo(biblioteca.quantidades.exercicios, 'exercícios');
  }

  void _validarNaoNegativo(int valor, String nomeCampo) {
    if (valor < 0) {
      throw FormatException(
        'A quantidade de $nomeCampo não pode ser negativa.',
      );
    }
  }
}
