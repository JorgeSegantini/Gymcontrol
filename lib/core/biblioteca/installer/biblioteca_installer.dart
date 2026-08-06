import 'package:drift/drift.dart';
import 'package:gym_control/core/biblioteca/loader/biblioteca_loader.dart';
import 'package:gym_control/core/biblioteca/models/versao/biblioteca_versao.dart';
import 'package:gym_control/core/biblioteca/validators/biblioteca_versao_validator.dart';
import 'package:gym_control/core/database/app_database.dart';

class BibliotecaInstaller {
  final AppDatabase _database;
  final BibliotecaLoader _loader;
  final BibliotecaVersaoValidator _validator;

  BibliotecaInstaller({
    required this._database,
    BibliotecaLoader? loader,
    BibliotecaVersaoValidator? validator,
  }) : _loader = loader ?? const BibliotecaLoader(),
       _validator = validator ?? const BibliotecaVersaoValidator();

  Future<BibliotecaVersao> instalar() async {
    final versao = await _loader.carregarVersao();

    _validator.validar(versao);

    final arquivos = await _carregarArquivos();

    _validarQuantidades(versao: versao, arquivos: arquivos);

    final instalada = await _buscarMetadataInstalada();

    await _database.transaction(() async {
      if (!_metadataCorresponde(instalada: instalada, versao: versao)) {
        await _limparBiblioteca();
        await _inserirGruposMuscularesBiblioteca(arquivos.grupos);
        await _inserirMetadata(versao);
      }

      await _sincronizarGruposMuscularesPrincipais(arquivos.grupos);
    });

    return versao;
  }

  Future<_BibliotecaArquivos> _carregarArquivos() async {
    final resultados = await Future.wait([
      _loader.carregarGruposMusculares(),
      _loader.carregarCategoriasEquipamentos(),
      _loader.carregarEquipamentos(),
      _loader.carregarPadroesMotores(),
      _loader.carregarMovimentos(),
      _loader.carregarVariacoes(),
      _loader.carregarNiveis(),
      _loader.carregarTags(),
      _loader.carregarAliases(),
      _loader.carregarExercicios(),
      _loader.carregarExerciciosGrupos(),
      _loader.carregarExerciciosEquipamentos(),
      _loader.carregarExerciciosTags(),
      _loader.carregarExerciciosAliases(),
    ]);

    return _BibliotecaArquivos(
      grupos: resultados[0],
      categoriasEquipamentos: resultados[1],
      equipamentos: resultados[2],
      padroesMotores: resultados[3],
      movimentos: resultados[4],
      variacoes: resultados[5],
      niveis: resultados[6],
      tags: resultados[7],
      aliases: resultados[8],
      exercicios: resultados[9],
      exerciciosGrupos: resultados[10],
      exerciciosEquipamentos: resultados[11],
      exerciciosTags: resultados[12],
      exerciciosAliases: resultados[13],
    );
  }

  void _validarQuantidades({
    required BibliotecaVersao versao,
    required _BibliotecaArquivos arquivos,
  }) {
    _validarQuantidade(
      nome: 'grupos musculares',
      esperada: versao.quantidades.grupos,
      encontrada: arquivos.grupos.length,
    );

    _validarQuantidade(
      nome: 'categorias de equipamentos',
      esperada: versao.quantidades.categoriasEquipamentos,
      encontrada: arquivos.categoriasEquipamentos.length,
    );

    _validarQuantidade(
      nome: 'equipamentos',
      esperada: versao.quantidades.equipamentos,
      encontrada: arquivos.equipamentos.length,
    );

    _validarQuantidade(
      nome: 'padrões motores',
      esperada: versao.quantidades.padroesMotores,
      encontrada: arquivos.padroesMotores.length,
    );

    _validarQuantidade(
      nome: 'movimentos',
      esperada: versao.quantidades.movimentos,
      encontrada: arquivos.movimentos.length,
    );

    _validarQuantidade(
      nome: 'variações',
      esperada: versao.quantidades.variacoes,
      encontrada: arquivos.variacoes.length,
    );

    _validarQuantidade(
      nome: 'níveis',
      esperada: versao.quantidades.niveis,
      encontrada: arquivos.niveis.length,
    );

    _validarQuantidade(
      nome: 'tags',
      esperada: versao.quantidades.tags,
      encontrada: arquivos.tags.length,
    );

    _validarQuantidade(
      nome: 'aliases',
      esperada: versao.quantidades.aliases,
      encontrada: arquivos.aliases.length,
    );

    _validarQuantidade(
      nome: 'exercícios',
      esperada: versao.quantidades.exercicios,
      encontrada: arquivos.exercicios.length,
    );
  }

  void _validarQuantidade({
    required String nome,
    required int esperada,
    required int encontrada,
  }) {
    if (esperada != encontrada) {
      throw FormatException(
        'Quantidade inválida de $nome. '
        'Esperada: $esperada. Encontrada: $encontrada.',
      );
    }
  }

  Future<BibliotecaMetadataRegistro?> _buscarMetadataInstalada() {
    final consulta = _database.select(_database.bibliotecaMetadata)
      ..orderBy([(tabela) => OrderingTerm.desc(tabela.id)])
      ..limit(1);

    return consulta.getSingleOrNull();
  }

  bool _metadataCorresponde({
    required BibliotecaMetadataRegistro? instalada,
    required BibliotecaVersao versao,
  }) {
    if (instalada == null) {
      return false;
    }

    final quantidades = versao.quantidades;

    return instalada.versao == versao.versao &&
        instalada.hash == versao.hash &&
        instalada.quantidadeGrupos == quantidades.grupos &&
        instalada.quantidadeCategoriasEquipamentos ==
            quantidades.categoriasEquipamentos &&
        instalada.quantidadeEquipamentos == quantidades.equipamentos &&
        instalada.quantidadePadroesMotores == quantidades.padroesMotores &&
        instalada.quantidadeMovimentos == quantidades.movimentos &&
        instalada.quantidadeVariacoes == quantidades.variacoes &&
        instalada.quantidadeNiveis == quantidades.niveis &&
        instalada.quantidadeTags == quantidades.tags &&
        instalada.quantidadeAliases == quantidades.aliases &&
        instalada.quantidadeExercicios == quantidades.exercicios;
  }

  Future<void> _inserirMetadata(BibliotecaVersao versao) {
    return _database
        .into(_database.bibliotecaMetadata)
        .insert(
          BibliotecaMetadataCompanion.insert(
            versao: versao.versao,
            dataVersao: versao.data.toIso8601String(),
            hash: Value(versao.hash),
            quantidadeGrupos: Value(versao.quantidades.grupos),
            quantidadeCategoriasEquipamentos: Value(
              versao.quantidades.categoriasEquipamentos,
            ),
            quantidadeEquipamentos: Value(versao.quantidades.equipamentos),
            quantidadePadroesMotores: Value(versao.quantidades.padroesMotores),
            quantidadeMovimentos: Value(versao.quantidades.movimentos),
            quantidadeVariacoes: Value(versao.quantidades.variacoes),
            quantidadeNiveis: Value(versao.quantidades.niveis),
            quantidadeTags: Value(versao.quantidades.tags),
            quantidadeAliases: Value(versao.quantidades.aliases),
            quantidadeExercicios: Value(versao.quantidades.exercicios),
          ),
        );
  }

  Future<void> _inserirGruposMuscularesBiblioteca(
    List<Map<String, dynamic>> grupos,
  ) async {
    for (final grupo in grupos) {
      await _database
          .into(_database.bibliotecaGruposMusculares)
          .insert(
            BibliotecaGruposMuscularesCompanion.insert(
              codigo: grupo['codigo'] as String,
              nome: grupo['nome'] as String,
              nomeNormalizado: grupo['nomeNormalizado'] as String,
              ordem: Value(grupo['ordem'] as int),
              ativo: Value(grupo['ativo'] as bool),
            ),
          );
    }
  }

  Future<void> _sincronizarGruposMuscularesPrincipais(
    List<Map<String, dynamic>> grupos,
  ) async {
    final agora = DateTime.now();

    for (final grupo in grupos) {
      final codigo = (grupo['codigo'] as String).trim().toLowerCase();
      final nome = (grupo['nome'] as String).trim();
      final ordem = grupo['ordem'] as int;
      final ativo = grupo['ativo'] as bool;

      var existente =
          await (_database.select(_database.gruposMusculares)
                ..where((tabela) => tabela.codigoBiblioteca.equals(codigo)))
              .getSingleOrNull();

      existente ??=
          await (_database.select(_database.gruposMusculares)..where(
                (tabela) => tabela.nome.lower().equals(nome.toLowerCase()),
              ))
              .getSingleOrNull();

      if (existente == null) {
        await _database
            .into(_database.gruposMusculares)
            .insert(
              GruposMuscularesCompanion.insert(
                nome: nome,
                origem: Value(OrigemGrupoMuscular.biblioteca.name),
                codigoBiblioteca: Value(codigo),
                ordem: Value(ordem),
                ativo: Value(ativo),
                criadoEm: Value(agora),
                atualizadoEm: Value(agora),
              ),
            );

        continue;
      }

      final grupoExistente = existente;

      await (_database.update(
        _database.gruposMusculares,
      )..where((tabela) => tabela.id.equals(grupoExistente.id))).write(
        GruposMuscularesCompanion(
          nome: Value(nome),
          origem: Value(OrigemGrupoMuscular.biblioteca.name),
          codigoBiblioteca: Value(codigo),
          ordem: Value(ordem),
          ativo: Value(ativo),
          atualizadoEm: Value(agora),
        ),
      );
    }
  }

  Future<void> _limparBiblioteca() async {
    await _database.delete(_database.bibliotecaExerciciosAliases).go();
    await _database.delete(_database.bibliotecaExerciciosTags).go();
    await _database.delete(_database.bibliotecaExerciciosEquipamentos).go();
    await _database.delete(_database.bibliotecaExerciciosGrupos).go();

    await _database.delete(_database.bibliotecaExercicios).go();
    await _database.delete(_database.bibliotecaEquipamentos).go();

    await _database.delete(_database.bibliotecaAliases).go();
    await _database.delete(_database.bibliotecaTags).go();
    await _database.delete(_database.bibliotecaNiveis).go();
    await _database.delete(_database.bibliotecaVariacoes).go();
    await _database.delete(_database.bibliotecaMovimentos).go();
    await _database.delete(_database.bibliotecaPadroesMotores).go();
    await _database.delete(_database.bibliotecaCategoriasEquipamentos).go();
    await _database.delete(_database.bibliotecaGruposMusculares).go();

    await _database.delete(_database.bibliotecaMetadata).go();
  }
}

class _BibliotecaArquivos {
  final List<Map<String, dynamic>> grupos;
  final List<Map<String, dynamic>> categoriasEquipamentos;
  final List<Map<String, dynamic>> equipamentos;
  final List<Map<String, dynamic>> padroesMotores;
  final List<Map<String, dynamic>> movimentos;
  final List<Map<String, dynamic>> variacoes;
  final List<Map<String, dynamic>> niveis;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> aliases;
  final List<Map<String, dynamic>> exercicios;
  final List<Map<String, dynamic>> exerciciosGrupos;
  final List<Map<String, dynamic>> exerciciosEquipamentos;
  final List<Map<String, dynamic>> exerciciosTags;
  final List<Map<String, dynamic>> exerciciosAliases;

  const _BibliotecaArquivos({
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
    required this.exerciciosGrupos,
    required this.exerciciosEquipamentos,
    required this.exerciciosTags,
    required this.exerciciosAliases,
  });
}
