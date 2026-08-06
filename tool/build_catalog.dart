import 'dart:convert';
import 'dart:io';

import 'catalog/catalog_models.dart';
import 'catalog/grupos/biceps.dart';
import 'catalog/grupos/costas.dart';
import 'catalog/grupos/ombros.dart';
import 'catalog/grupos/peitoral.dart';
import 'catalog/grupos/triceps.dart';

const _diretorioSaida = 'assets/biblioteca';

void main() {
  final grupos = <CatalogoGrupo>[
    catalogoPeitoral,
    catalogoCostas,
    catalogoOmbros,
    catalogoBiceps,
    catalogoTriceps,
  ];

  _validarGrupos(grupos);

  final exercicios = [for (final grupo in grupos) ...grupo.exercicios];

  _validarExercicios(exercicios);

  final aliases = <Map<String, Object?>>[];
  final exerciciosAliases = <Map<String, Object?>>[];
  var aliasOrdem = 1;

  for (final exercicio in exercicios) {
    for (final nomeAlias in exercicio.aliases) {
      final codigoAlias =
          '${exercicio.codigo}_alias_${aliasOrdem.toString().padLeft(4, '0')}';

      aliases.add({
        'codigo': codigoAlias,
        'nome': nomeAlias,
        'nomeNormalizado': _normalizar(nomeAlias),
        'ativo': true,
      });

      exerciciosAliases.add({
        'exercicioCodigo': exercicio.codigo,
        'aliasCodigo': codigoAlias,
      });

      aliasOrdem += 1;
    }
  }

  final exerciciosJson = exercicios
      .map((exercicio) {
        return <String, Object?>{
          'codigo': exercicio.codigo,
          'nome': exercicio.nome,
          'nomeCurto': exercicio.nomeCurto,
          'nomeNormalizado': _normalizar(exercicio.nome),
          'movimentoCodigo': null,
          'variacaoCodigo': null,
          'padraoMotorCodigo': null,
          'nivelCodigo': null,
          'descricao': null,
          'instrucoesJson': null,
          'dicasJson': null,
          'errosComunsJson': null,
          'unilateral': exercicio.variante.toLowerCase().contains('unilateral'),
          'usaPesoCorporal': exercicio.equipamento == 'pesoCorporal',
          'usaMaquina': exercicio.equipamento == 'maquina',
          'velocidadeExecucao': 'controlada',
          'descansoPadraoSegundos': null,
          'popularidade': exercicio.popularidade,
          'ativo': exercicio.ativo,
          'grupoPrincipalCodigo': exercicio.grupoPrincipalCodigo,
          'equipamento': exercicio.equipamento,
          'familia': exercicio.familia,
          'variante': exercicio.variante,
          'nivelDificuldade': exercicio.nivel,
          'ordem': exercicio.ordem,
        };
      })
      .toList(growable: false);

  final exerciciosGrupos = <Map<String, Object?>>[];

  for (final exercicio in exercicios) {
    exerciciosGrupos.add({
      'exercicioCodigo': exercicio.codigo,
      'grupoCodigo': exercicio.grupoPrincipalCodigo,
      'tipoParticipacao': 'principal',
      'ordem': 0,
    });

    for (
      var indice = 0;
      indice < exercicio.gruposSecundarios.length;
      indice++
    ) {
      exerciciosGrupos.add({
        'exercicioCodigo': exercicio.codigo,
        'grupoCodigo': exercicio.gruposSecundarios[indice],
        'tipoParticipacao': 'secundario',
        'ordem': indice + 1,
      });
    }
  }

  _gravarJson('exercicios.json', exerciciosJson);
  _gravarJson('exercicio_grupos.json', exerciciosGrupos);
  _gravarJson('aliases.json', aliases);
  _gravarJson('exercicio_aliases.json', exerciciosAliases);

  _atualizarVersao(
    quantidadeExercicios: exerciciosJson.length,
    quantidadeAliases: aliases.length,
  );

  stdout.writeln('Catálogo gerado com sucesso.');
  stdout.writeln('Grupos: ${grupos.length}');
  stdout.writeln('Exercícios: ${exerciciosJson.length}');
  stdout.writeln('Aliases: ${aliases.length}');
  stdout.writeln('Relações exercício/grupo: ${exerciciosGrupos.length}');
}

void _validarGrupos(List<CatalogoGrupo> grupos) {
  final codigos = <String>{};

  for (final grupo in grupos) {
    if (!_identificadorValido(grupo.codigo)) {
      throw FormatException(
        'Identificador de grupo inválido: ${grupo.codigo}.',
      );
    }

    if (!codigos.add(grupo.codigo)) {
      throw FormatException(
        'Identificador de grupo duplicado: ${grupo.codigo}.',
      );
    }

    if (grupo.nome.trim().isEmpty) {
      throw FormatException('O grupo ${grupo.codigo} possui nome vazio.');
    }
  }
}

void _validarExercicios(List<CatalogoExercicio> exercicios) {
  final codigos = <String>{};
  final nomesPorGrupo = <String, Set<String>>{};

  for (final exercicio in exercicios) {
    if (!_identificadorValido(exercicio.codigo)) {
      throw FormatException('Identificador inválido: ${exercicio.codigo}.');
    }

    if (!codigos.add(exercicio.codigo)) {
      throw FormatException(
        'Identificador de exercício duplicado: ${exercicio.codigo}.',
      );
    }

    final nomesDoGrupo = nomesPorGrupo.putIfAbsent(
      exercicio.grupoPrincipalCodigo,
      () => <String>{},
    );
    final nomeNormalizado = _normalizar(exercicio.nome);

    if (!nomesDoGrupo.add(nomeNormalizado)) {
      throw FormatException(
        'Nome duplicado no grupo ${exercicio.grupoPrincipalCodigo}: '
        '${exercicio.nome}.',
      );
    }

    if (exercicio.nome.trim().isEmpty ||
        exercicio.nomeCurto.trim().isEmpty ||
        exercicio.grupoPrincipalCodigo.trim().isEmpty ||
        exercicio.equipamento.trim().isEmpty ||
        exercicio.familia.trim().isEmpty ||
        exercicio.variante.trim().isEmpty) {
      throw FormatException(
        'O exercício ${exercicio.codigo} possui campos obrigatórios vazios.',
      );
    }

    if (exercicio.popularidade < 0 || exercicio.popularidade > 100) {
      throw FormatException(
        'Popularidade inválida no exercício ${exercicio.codigo}.',
      );
    }
  }
}

bool _identificadorValido(String valor) {
  return RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$').hasMatch(valor);
}

void _gravarJson(String nomeArquivo, Object conteudo) {
  final arquivo = File('$_diretorioSaida/$nomeArquivo');
  arquivo.parent.createSync(recursive: true);

  const encoder = JsonEncoder.withIndent('  ');
  arquivo.writeAsStringSync('${encoder.convert(conteudo)}\n');
}

void _atualizarVersao({
  required int quantidadeExercicios,
  required int quantidadeAliases,
}) {
  final arquivo = File('$_diretorioSaida/versao.json');

  if (!arquivo.existsSync()) {
    throw FileSystemException(
      'O arquivo versao.json não foi encontrado.',
      arquivo.path,
    );
  }

  final conteudo = jsonDecode(arquivo.readAsStringSync());

  if (conteudo is! Map<String, dynamic>) {
    throw const FormatException('O arquivo versao.json é inválido.');
  }

  final quantidades = conteudo['quantidades'];

  if (quantidades is! Map<String, dynamic>) {
    throw const FormatException(
      'O campo quantidades de versao.json é inválido.',
    );
  }

  quantidades['exercicios'] = quantidadeExercicios;
  quantidades['aliases'] = quantidadeAliases;

  conteudo['data'] = DateTime.now().toIso8601String().split('T').first;
  conteudo['hash'] = null;

  const encoder = JsonEncoder.withIndent('  ');
  arquivo.writeAsStringSync('${encoder.convert(conteudo)}\n');
}

String _normalizar(String valor) {
  var resultado = valor.trim().toLowerCase();

  const substituicoes = <String, String>{
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };

  substituicoes.forEach((origem, destino) {
    resultado = resultado.replaceAll(origem, destino);
  });

  return resultado.replaceAll(RegExp(r'\s+'), ' ');
}
