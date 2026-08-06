import 'dart:async';

import '../../database/app_database.dart';
import '../loader/biblioteca_loader.dart';

class BibliotecaPesquisaService {
  BibliotecaPesquisaService({BibliotecaLoader? loader})
    : _loader = loader ?? const BibliotecaLoader();

  final BibliotecaLoader _loader;

  Future<_BibliotecaIndice>? _indiceFuture;

  Future<List<Exercicio>> pesquisar({
    required List<Exercicio> exercicios,
    required List<GrupoMuscular> grupos,
    required String termo,
    int? grupoMuscularId,
    bool incluirInativos = false,
  }) async {
    final texto = _normalizar(termo);
    final gruposPorId = <int, GrupoMuscular>{
      for (final grupo in grupos) grupo.id: grupo,
    };

    final candidatos = exercicios.where((exercicio) {
      if (!incluirInativos && !exercicio.ativo) {
        return false;
      }

      if (grupoMuscularId != null &&
          exercicio.grupoMuscularId != grupoMuscularId) {
        return false;
      }

      return true;
    }).toList();

    if (texto.isEmpty) {
      return candidatos;
    }

    final indice = await _obterIndice();
    final pontuados = <_ExercicioPontuado>[];

    for (final exercicio in candidatos) {
      final grupo = gruposPorId[exercicio.grupoMuscularId];
      final codigoBiblioteca = exercicio.codigoBiblioteca?.trim().toLowerCase();
      final dadosBiblioteca = codigoBiblioteca == null
          ? null
          : indice.porExercicio[codigoBiblioteca];

      final pontuacao = _calcularPontuacao(
        termo: texto,
        exercicio: exercicio,
        nomeGrupo: grupo?.nome,
        dadosBiblioteca: dadosBiblioteca,
      );

      if (pontuacao > 0) {
        pontuados.add(
          _ExercicioPontuado(exercicio: exercicio, pontuacao: pontuacao),
        );
      }
    }

    pontuados.sort((a, b) {
      final porPontuacao = b.pontuacao.compareTo(a.pontuacao);

      if (porPontuacao != 0) {
        return porPontuacao;
      }

      final porPopularidade = b.exercicio.popularidade.compareTo(
        a.exercicio.popularidade,
      );

      if (porPopularidade != 0) {
        return porPopularidade;
      }

      final porOrdem = a.exercicio.ordem.compareTo(b.exercicio.ordem);

      if (porOrdem != 0) {
        return porOrdem;
      }

      return a.exercicio.nome.toLowerCase().compareTo(
        b.exercicio.nome.toLowerCase(),
      );
    });

    return pontuados.map((item) => item.exercicio).toList();
  }

  int _calcularPontuacao({
    required String termo,
    required Exercicio exercicio,
    required String? nomeGrupo,
    required _DadosPesquisaExercicio? dadosBiblioteca,
  }) {
    var melhor = 0;

    void avaliar(
      String? valor,
      int pesoExato,
      int pesoPrefixo,
      int pesoContem,
    ) {
      final normalizado = _normalizar(valor);

      if (normalizado.isEmpty) {
        return;
      }

      if (normalizado == termo) {
        melhor = _maior(melhor, pesoExato);
        return;
      }

      if (normalizado.startsWith(termo)) {
        melhor = _maior(melhor, pesoPrefixo);
        return;
      }

      if (normalizado.contains(termo)) {
        melhor = _maior(melhor, pesoContem);
      }
    }

    avaliar(exercicio.nome, 1000, 900, 800);
    avaliar(exercicio.nomeCurto, 950, 850, 750);
    avaliar(exercicio.familia, 760, 700, 640);
    avaliar(exercicio.variante, 720, 660, 600);
    avaliar(exercicio.codigoBiblioteca, 690, 630, 570);

    for (final alias in dadosBiblioteca?.aliases ?? const <String>[]) {
      avaliar(alias, 850, 780, 710);
    }

    avaliar(nomeGrupo, 620, 570, 520);

    avaliar(exercicio.equipamento, 580, 530, 480);

    for (final equipamento
        in dadosBiblioteca?.equipamentos ?? const <String>[]) {
      avaliar(equipamento, 580, 530, 480);
    }

    for (final tag in dadosBiblioteca?.tags ?? const <String>[]) {
      avaliar(tag, 540, 500, 460);
    }

    for (final grupo in dadosBiblioteca?.grupos ?? const <String>[]) {
      avaliar(grupo, 610, 560, 510);
    }

    return melhor;
  }

  Future<_BibliotecaIndice> _obterIndice() {
    return _indiceFuture ??= _carregarIndice();
  }

  Future<_BibliotecaIndice> _carregarIndice() async {
    final resultados = await Future.wait([
      _loader.carregarGruposMusculares(),
      _loader.carregarEquipamentos(),
      _loader.carregarTags(),
      _loader.carregarAliases(),
      _loader.carregarExerciciosGrupos(),
      _loader.carregarExerciciosEquipamentos(),
      _loader.carregarExerciciosTags(),
      _loader.carregarExerciciosAliases(),
    ]);

    final grupos = resultados[0];
    final equipamentos = resultados[1];
    final tags = resultados[2];
    final aliases = resultados[3];
    final exerciciosGrupos = resultados[4];
    final exerciciosEquipamentos = resultados[5];
    final exerciciosTags = resultados[6];
    final exerciciosAliases = resultados[7];

    final nomeGrupoPorCodigo = <String, String>{
      for (final item in grupos) _texto(item, 'codigo'): _texto(item, 'nome'),
    };

    final nomeEquipamentoPorCodigo = <String, String>{
      for (final item in equipamentos)
        _texto(item, 'codigo'): _texto(item, 'nome'),
    };

    final nomeTagPorCodigo = <String, String>{
      for (final item in tags) _texto(item, 'codigo'): _texto(item, 'nome'),
    };

    final nomeAliasPorCodigo = <String, String>{
      for (final item in aliases) _texto(item, 'codigo'): _texto(item, 'nome'),
    };

    final porExercicio = <String, _DadosPesquisaExercicio>{};

    _DadosPesquisaExercicio obter(String codigoExercicio) {
      return porExercicio.putIfAbsent(
        codigoExercicio,
        _DadosPesquisaExercicio.new,
      );
    }

    for (final item in exerciciosGrupos) {
      final codigoExercicio = _texto(item, 'exercicioCodigo');
      final codigoGrupo = _texto(item, 'grupoCodigo');
      final nome = nomeGrupoPorCodigo[codigoGrupo];

      if (nome != null) {
        obter(codigoExercicio).grupos.add(nome);
      }
    }

    for (final item in exerciciosEquipamentos) {
      final codigoExercicio = _texto(item, 'exercicioCodigo');
      final codigoEquipamento = _texto(item, 'equipamentoCodigo');
      final nome = nomeEquipamentoPorCodigo[codigoEquipamento];

      if (nome != null) {
        obter(codigoExercicio).equipamentos.add(nome);
      }
    }

    for (final item in exerciciosTags) {
      final codigoExercicio = _texto(item, 'exercicioCodigo');
      final codigoTag = _texto(item, 'tagCodigo');
      final nome = nomeTagPorCodigo[codigoTag];

      if (nome != null) {
        obter(codigoExercicio).tags.add(nome);
      }
    }

    for (final item in exerciciosAliases) {
      final codigoExercicio = _texto(item, 'exercicioCodigo');
      final codigoAlias = _texto(item, 'aliasCodigo');
      final nome = nomeAliasPorCodigo[codigoAlias];

      if (nome != null) {
        obter(codigoExercicio).aliases.add(nome);
      }
    }

    return _BibliotecaIndice(porExercicio: porExercicio);
  }

  static int _maior(int atual, int candidato) {
    return candidato > atual ? candidato : atual;
  }

  static String _texto(Map<String, dynamic> item, String campo) {
    final valor = item[campo];

    if (valor is String) {
      return valor.trim().toLowerCase();
    }

    return '';
  }

  static String _normalizar(String? texto) {
    if (texto == null) {
      return '';
    }

    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

    var resultado = texto.trim().toLowerCase();

    for (var indice = 0; indice < comAcento.length; indice++) {
      resultado = resultado.replaceAll(comAcento[indice], semAcento[indice]);
    }

    return resultado.replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _BibliotecaIndice {
  const _BibliotecaIndice({required this.porExercicio});

  final Map<String, _DadosPesquisaExercicio> porExercicio;
}

class _DadosPesquisaExercicio {
  final Set<String> aliases = <String>{};
  final Set<String> grupos = <String>{};
  final Set<String> equipamentos = <String>{};
  final Set<String> tags = <String>{};
}

class _ExercicioPontuado {
  const _ExercicioPontuado({required this.exercicio, required this.pontuacao});

  final Exercicio exercicio;
  final int pontuacao;
}
