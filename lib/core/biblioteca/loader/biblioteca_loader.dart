import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gym_control/core/biblioteca/models/versao/biblioteca_versao.dart';

/// Responsável por carregar os arquivos JSON da Biblioteca Oficial
/// distribuídos junto com o aplicativo.
class BibliotecaLoader {
  const BibliotecaLoader();

  static const String _diretorioBase = 'assets/biblioteca';

  Future<String> carregarTexto(String caminho) async {
    try {
      return await rootBundle.loadString(caminho);
    } on Object catch (erro) {
      throw BibliotecaLoaderException(
        'Não foi possível localizar o arquivo "$caminho".',
        causa: erro,
      );
    }
  }

  Future<BibliotecaVersao> carregarVersao() async {
    final json = await _carregarObjeto('versao.json');

    try {
      return BibliotecaVersao.fromJson(json);
    } on Object catch (erro) {
      throw BibliotecaLoaderException(
        'O arquivo "versao.json" possui uma estrutura inválida.',
        causa: erro,
      );
    }
  }

  Future<List<Map<String, dynamic>>> carregarGruposMusculares() {
    return _carregarLista('grupos_musculares.json');
  }

  Future<List<Map<String, dynamic>>> carregarCategoriasEquipamentos() {
    return _carregarLista('categorias_equipamentos.json');
  }

  Future<List<Map<String, dynamic>>> carregarEquipamentos() {
    return _carregarLista('equipamentos.json');
  }

  Future<List<Map<String, dynamic>>> carregarPadroesMotores() {
    return _carregarLista('padroes_motores.json');
  }

  Future<List<Map<String, dynamic>>> carregarMovimentos() {
    return _carregarLista('movimentos.json');
  }

  Future<List<Map<String, dynamic>>> carregarVariacoes() {
    return _carregarLista('variacoes.json');
  }

  Future<List<Map<String, dynamic>>> carregarNiveis() {
    return _carregarLista('niveis.json');
  }

  Future<List<Map<String, dynamic>>> carregarTags() {
    return _carregarLista('tags.json');
  }

  Future<List<Map<String, dynamic>>> carregarAliases() {
    return _carregarLista('aliases.json');
  }

  Future<List<Map<String, dynamic>>> carregarExercicios() {
    return _carregarLista('exercicios.json');
  }

  Future<List<Map<String, dynamic>>> carregarExerciciosGrupos() {
    return _carregarLista('exercicio_grupos.json');
  }

  Future<List<Map<String, dynamic>>> carregarExerciciosEquipamentos() {
    return _carregarLista('exercicio_equipamentos.json');
  }

  Future<List<Map<String, dynamic>>> carregarExerciciosTags() {
    return _carregarLista('exercicio_tags.json');
  }

  Future<List<Map<String, dynamic>>> carregarExerciciosAliases() {
    return _carregarLista('exercicio_aliases.json');
  }

  Future<Map<String, dynamic>> _carregarObjeto(String nomeArquivo) async {
    final caminho = '$_diretorioBase/$nomeArquivo';
    final texto = await carregarTexto(caminho);

    try {
      final conteudo = jsonDecode(texto);

      if (conteudo is! Map<String, dynamic>) {
        throw const FormatException(
          'O conteúdo principal deve ser um objeto JSON.',
        );
      }

      return conteudo;
    } on BibliotecaLoaderException {
      rethrow;
    } on Object catch (erro) {
      throw BibliotecaLoaderException(
        'O arquivo "$nomeArquivo" não contém um objeto JSON válido.',
        causa: erro,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _carregarLista(String nomeArquivo) async {
    final caminho = '$_diretorioBase/$nomeArquivo';
    final texto = await carregarTexto(caminho);

    try {
      final conteudo = jsonDecode(texto);

      if (conteudo is! List<dynamic>) {
        throw const FormatException(
          'O conteúdo principal deve ser uma lista JSON.',
        );
      }

      return conteudo
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'Todos os itens da lista devem ser objetos JSON.',
              );
            }

            return item;
          })
          .toList(growable: false);
    } on BibliotecaLoaderException {
      rethrow;
    } on Object catch (erro) {
      throw BibliotecaLoaderException(
        'O arquivo "$nomeArquivo" não contém uma lista JSON válida.',
        causa: erro,
      );
    }
  }
}

class BibliotecaLoaderException implements Exception {
  final String mensagem;
  final Object? causa;

  const BibliotecaLoaderException(this.mensagem, {this.causa});

  @override
  String toString() {
    if (causa == null) {
      return 'BibliotecaLoaderException: $mensagem';
    }

    return 'BibliotecaLoaderException: $mensagem Causa: $causa';
  }
}
