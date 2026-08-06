import 'package:gym_control/core/biblioteca/loader/biblioteca_loader.dart';
import 'package:gym_control/core/database/app_database.dart';
import 'package:gym_control/core/database/dados_exercicio.dart';

class BibliotecaSyncService {
  BibliotecaSyncService({required this._database, BibliotecaLoader? loader})
    : _loader = loader ?? const BibliotecaLoader();

  final AppDatabase _database;
  final BibliotecaLoader _loader;

  Future<int> sincronizarExercicios() async {
    final exercicios = await _loader.carregarExercicios();
    var sincronizados = 0;

    for (final item in exercicios) {
      final grupoCodigo = _textoObrigatorio(
        item,
        'grupoPrincipalCodigo',
      ).toLowerCase();

      final grupo =
          await (_database.select(
                _database.gruposMusculares,
              )..where((tabela) => tabela.codigoBiblioteca.equals(grupoCodigo)))
              .getSingleOrNull();

      if (grupo == null) {
        throw StateError(
          'O grupo muscular "$grupoCodigo" não foi encontrado '
          'para o exercício "${item['codigo']}".',
        );
      }

      final dados = DadosExercicio(
        grupoMuscularId: grupo.id,
        nome: _textoObrigatorio(item, 'nome'),
        nomeCurto: _textoOpcional(item, 'nomeCurto'),
        codigoBiblioteca: _textoObrigatorio(item, 'codigo'),
        tipo: TipoExercicio.musculacao,
        equipamento: _converterEquipamento(
          _textoObrigatorio(item, 'equipamento'),
        ),
        nivelDificuldade: _converterNivel(
          _textoObrigatorio(item, 'nivelDificuldade'),
        ),
        velocidadeExecucao: _converterVelocidade(
          _textoOpcional(item, 'velocidadeExecucao') ?? 'controlada',
        ),
        familia: _textoOpcional(item, 'familia'),
        variante: _textoOpcional(item, 'variante'),
        instrucoes: _textoOpcional(item, 'instrucoes'),
        dicas: _textoOpcional(item, 'dicas'),
        errosComuns: _textoOpcional(item, 'errosComuns'),
        popularidade: _inteiro(item, 'popularidade'),
        ordem: _inteiro(item, 'ordem'),
      );

      await _database.exercicioDao.cadastrarOuAtualizarBiblioteca(dados);
      sincronizados += 1;
    }

    return sincronizados;
  }

  EquipamentoExercicio _converterEquipamento(String valor) {
    return EquipamentoExercicio.values.firstWhere(
      (item) => item.name == valor,
      orElse: () => EquipamentoExercicio.outro,
    );
  }

  NivelDificuldadeExercicio _converterNivel(String valor) {
    return NivelDificuldadeExercicio.values.firstWhere(
      (item) => item.name == valor,
      orElse: () => NivelDificuldadeExercicio.iniciante,
    );
  }

  VelocidadeExecucao _converterVelocidade(String valor) {
    return VelocidadeExecucao.values.firstWhere(
      (item) => item.name == valor,
      orElse: () => VelocidadeExecucao.controlada,
    );
  }

  String _textoObrigatorio(Map<String, dynamic> item, String campo) {
    final valor = item[campo];

    if (valor is! String || valor.trim().isEmpty) {
      throw FormatException(
        'O campo "$campo" é obrigatório no exercício ${item['codigo']}.',
      );
    }

    return valor.trim();
  }

  String? _textoOpcional(Map<String, dynamic> item, String campo) {
    final valor = item[campo];

    if (valor == null) {
      return null;
    }

    if (valor is! String) {
      throw FormatException(
        'O campo "$campo" deve ser texto no exercício ${item['codigo']}.',
      );
    }

    final texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }

  int _inteiro(Map<String, dynamic> item, String campo) {
    final valor = item[campo];

    if (valor is int) {
      return valor;
    }

    throw FormatException(
      'O campo "$campo" deve ser inteiro no exercício ${item['codigo']}.',
    );
  }
}
