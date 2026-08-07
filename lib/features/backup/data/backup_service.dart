import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_selector/file_selector.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import 'backup_info.dart';
import 'backup_manifest.dart';
import 'backup_selecionado.dart';
import 'manutencao_banco_service.dart';

class BackupService {
  BackupService(this._database)
    : _manutencaoService = ManutencaoBancoService(_database);

  static const _chaveUltimoBackupEm = 'backup.ultimoBackupEm';
  static const _chaveUltimoArquivo = 'backup.ultimoArquivo';
  static const _chaveUltimoTamanho = 'backup.ultimoTamanhoBytes';
  static const _chaveCompartilhado = 'backup.compartilhado';
  static const _chaveCompartilhadoEm = 'backup.compartilhadoEm';

  static const _versaoAplicativo = '1.0.0';
  static const _buildAplicativo = 1;
  static const _versaoFormato = 1;

  final AppDatabase _database;
  final ManutencaoBancoService _manutencaoService;

  Future<BackupInfo> obterInformacoes() async {
    final preferences = await SharedPreferences.getInstance();
    final ultimoBackupTexto = preferences.getString(_chaveUltimoBackupEm);

    return BackupInfo(
      ultimoBackupEm: ultimoBackupTexto == null
          ? null
          : DateTime.tryParse(ultimoBackupTexto),
      nomeArquivo: preferences.getString(_chaveUltimoArquivo),
      tamanhoBytes: preferences.getInt(_chaveUltimoTamanho),
      compartilhado: preferences.getBool(_chaveCompartilhado) ?? false,
      compartilhadoEm: _lerDataOpcional(
        preferences.getString(_chaveCompartilhadoEm),
      ),
    );
  }

  Future<BackupSelecionado?> selecionarEValidarBackup() async {
    const grupoTipos = XTypeGroup(
      label: 'Backup do GymControl',
      extensions: ['gym'],
      mimeTypes: ['application/zip', 'application/octet-stream'],
    );

    final arquivoSelecionado = await openFile(
      acceptedTypeGroups: const [grupoTipos],
    );

    if (arquivoSelecionado == null) {
      return null;
    }

    final caminho = arquivoSelecionado.path.trim();

    if (caminho.isEmpty) {
      throw const BackupValidacaoException(
        'Não foi possível acessar o arquivo selecionado.',
      );
    }

    return validarArquivoBackup(File(caminho));
  }

  Future<BackupSelecionado> validarArquivoBackup(File arquivo) async {
    if (!await arquivo.exists()) {
      throw const BackupValidacaoException(
        'O arquivo selecionado não foi encontrado.',
      );
    }

    if (path.extension(arquivo.path).toLowerCase() != '.gym') {
      throw const BackupValidacaoException(
        'Selecione um arquivo de backup com extensão .gym.',
      );
    }

    final tamanhoBytes = await arquivo.length();

    if (tamanhoBytes <= 0) {
      throw const BackupValidacaoException('O arquivo selecionado está vazio.');
    }

    try {
      final bytes = await arquivo.readAsBytes();
      final pacote = ZipDecoder().decodeBytes(bytes);

      final manifestoArquivo = pacote.files.cast<ArchiveFile?>().firstWhere(
        (item) => item?.name == 'manifest.json',
        orElse: () => null,
      );
      final bancoArquivo = pacote.files.cast<ArchiveFile?>().firstWhere(
        (item) => item?.name == 'database.sqlite',
        orElse: () => null,
      );

      if (manifestoArquivo == null || !manifestoArquivo.isFile) {
        throw const BackupValidacaoException(
          'O backup não contém o arquivo manifest.json.',
        );
      }

      if (bancoArquivo == null ||
          !bancoArquivo.isFile ||
          bancoArquivo.size <= 0) {
        throw const BackupValidacaoException(
          'O backup não contém um banco SQLite válido.',
        );
      }

      final manifestoBytes = manifestoArquivo.readBytes();

      if (manifestoBytes == null || manifestoBytes.isEmpty) {
        throw const BackupValidacaoException(
          'O manifesto do backup está vazio.',
        );
      }

      final conteudoJson = jsonDecode(utf8.decode(manifestoBytes));

      if (conteudoJson is! Map<String, dynamic>) {
        throw const BackupValidacaoException(
          'O manifesto do backup possui formato inválido.',
        );
      }

      final manifesto = BackupManifest.fromJson(conteudoJson);

      _validarCompatibilidade(manifesto);

      return BackupSelecionado(
        arquivo: arquivo,
        nomeArquivo: path.basename(arquivo.path),
        tamanhoBytes: tamanhoBytes,
        manifesto: manifesto,
        possuiBanco: true,
      );
    } on BackupValidacaoException {
      rethrow;
    } on FormatException {
      throw const BackupValidacaoException(
        'O arquivo selecionado está corrompido ou não é um backup GymControl.',
      );
    } catch (erro) {
      throw BackupValidacaoException(
        'Não foi possível validar o backup: $erro',
      );
    }
  }

  void _validarCompatibilidade(BackupManifest manifesto) {
    if (manifesto.aplicativo != 'GymControl') {
      throw const BackupValidacaoException(
        'Este arquivo não pertence ao GymControl.',
      );
    }

    if (manifesto.versaoFormato != _versaoFormato) {
      throw BackupValidacaoException(
        'Formato de backup incompatível. Arquivo: '
        '${manifesto.versaoFormato}; aplicativo: $_versaoFormato.',
      );
    }

    if (manifesto.versaoBanco > _database.schemaVersion) {
      throw BackupValidacaoException(
        'Este backup foi criado em uma versão mais nova do GymControl.',
      );
    }
  }

  Future<BackupCriado> criarArquivoBackup() async {
    final criadoEm = DateTime.now();
    final documentos = await getApplicationDocumentsDirectory();
    final diretorioBackups = Directory(path.join(documentos.path, 'backups'));

    await diretorioBackups.create(recursive: true);

    final nomeBase = _nomeBaseArquivo(criadoEm);
    final arquivoBackup = await _arquivoDisponivel(
      diretorio: diretorioBackups,
      nomeBase: nomeBase,
    );

    final temporarios = await getTemporaryDirectory();
    final diretorioTrabalho = await Directory(
      path.join(
        temporarios.path,
        'gymcontrol_backup_${criadoEm.microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);

    final snapshotBanco = File(
      path.join(diretorioTrabalho.path, 'database.sqlite'),
    );
    final arquivoManifesto = File(
      path.join(diretorioTrabalho.path, 'manifest.json'),
    );

    try {
      await _criarSnapshotBanco(snapshotBanco);

      final manifesto = await _criarManifesto(criadoEm);
      const encoderJson = JsonEncoder.withIndent('  ');

      await arquivoManifesto.writeAsString(
        encoderJson.convert(manifesto.toJson()),
        flush: true,
      );

      final encoder = ZipFileEncoder();
      encoder.create(arquivoBackup.path);
      await encoder.addFile(snapshotBanco, 'database.sqlite');
      await encoder.addFile(arquivoManifesto, 'manifest.json');
      await encoder.close();

      if (!await arquivoBackup.exists()) {
        throw const BackupException('O arquivo de backup não foi criado.');
      }

      final tamanhoBytes = await arquivoBackup.length();

      if (tamanhoBytes <= 0) {
        throw const BackupException('O arquivo de backup foi criado vazio.');
      }

      await _registrarBackupCriado(
        criadoEm: criadoEm,
        nomeArquivo: path.basename(arquivoBackup.path),
        tamanhoBytes: tamanhoBytes,
      );

      return BackupCriado(
        arquivo: arquivoBackup,
        criadoEm: criadoEm,
        nomeArquivo: path.basename(arquivoBackup.path),
        tamanhoBytes: tamanhoBytes,
      );
    } on BackupException {
      await _apagarSeExistir(arquivoBackup);
      rethrow;
    } catch (erro) {
      await _apagarSeExistir(arquivoBackup);
      throw BackupException('Não foi possível criar o backup: $erro');
    } finally {
      if (await diretorioTrabalho.exists()) {
        await diretorioTrabalho.delete(recursive: true);
      }
    }
  }

  Future<ShareResult> compartilharBackup(BackupCriado backup) async {
    if (!await backup.arquivo.exists()) {
      throw const BackupCompartilhamentoException(
        'O arquivo de backup não foi encontrado para compartilhamento.',
      );
    }

    try {
      final resultado = await SharePlus.instance.share(
        ShareParams(
          text:
              'Backup do GymControl criado em '
              '${_formatarDataHora(backup.criadoEm)}.',
          files: [XFile(backup.arquivo.path)],
        ),
      );

      if (resultado.status == ShareResultStatus.success) {
        await _registrarCompartilhamento(DateTime.now());
      }

      return resultado;
    } catch (erro) {
      throw BackupCompartilhamentoException(
        'O backup foi criado, mas o Android não conseguiu abrir o menu de '
        'compartilhamento. Detalhes: $erro',
      );
    }
  }

  Future<BackupManifest> _criarManifesto(DateTime criadoEm) async {
    final info = await _manutencaoService.obterInformacoes();
    final metadata =
        await (_database.select(_database.bibliotecaMetadata)
              ..orderBy([(tabela) => OrderingTerm.desc(tabela.id)])
              ..limit(1))
            .getSingleOrNull();

    return BackupManifest(
      aplicativo: 'GymControl',
      versaoAplicativo: _versaoAplicativo,
      buildAplicativo: _buildAplicativo,
      versaoFormato: _versaoFormato,
      versaoBanco: _database.schemaVersion,
      versaoBiblioteca: metadata?.versao,
      criadoEm: criadoEm,
      plataforma: Platform.operatingSystem,
      estatisticas: BackupEstatisticas(
        gruposMusculares: info.gruposMusculares,
        exercicios: info.exercicios,
        fichasTreino: info.fichasTreino,
        planosTreino: info.planosTreino,
        treinosRealizados: info.treinosRealizados,
        exerciciosRealizados: info.exerciciosRealizados,
        seriesRealizadas: info.seriesRealizadas,
        execucoesPlano: info.execucoesPlano,
      ),
    );
  }

  Future<void> _criarSnapshotBanco(File destino) async {
    await _apagarSeExistir(destino);

    await _database.customStatement('PRAGMA wal_checkpoint(FULL)');

    final caminhoSeguro = destino.path.replaceAll("'", "''");
    await _database.customStatement("VACUUM INTO '$caminhoSeguro'");

    if (!await destino.exists() || await destino.length() <= 0) {
      throw const BackupException(
        'Não foi possível gerar uma cópia consistente do banco.',
      );
    }
  }

  Future<void> _registrarBackupCriado({
    required DateTime criadoEm,
    required String nomeArquivo,
    required int tamanhoBytes,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _chaveUltimoBackupEm,
      criadoEm.toIso8601String(),
    );
    await preferences.setString(_chaveUltimoArquivo, nomeArquivo);
    await preferences.setInt(_chaveUltimoTamanho, tamanhoBytes);
    await preferences.setBool(_chaveCompartilhado, false);
    await preferences.remove(_chaveCompartilhadoEm);
  }

  Future<void> _registrarCompartilhamento(DateTime compartilhadoEm) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_chaveCompartilhado, true);
    await preferences.setString(
      _chaveCompartilhadoEm,
      compartilhadoEm.toIso8601String(),
    );
  }

  DateTime? _lerDataOpcional(String? valor) {
    if (valor == null) {
      return null;
    }

    return DateTime.tryParse(valor);
  }

  Future<File> _arquivoDisponivel({
    required Directory diretorio,
    required String nomeBase,
  }) async {
    var versao = 1;

    while (true) {
      final sufixo = versao == 1 ? '' : '_v$versao';
      final arquivo = File(path.join(diretorio.path, '$nomeBase$sufixo.gym'));

      if (!await arquivo.exists()) {
        return arquivo;
      }

      versao += 1;
    }
  }

  String _nomeBaseArquivo(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');

    return 'GymControl_Backup_'
        '${data.year}-${dois(data.month)}-${dois(data.day)}_'
        '${dois(data.hour)}-${dois(data.minute)}-${dois(data.second)}';
  }

  static String _formatarDataHora(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');

    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        'às ${dois(data.hour)}:${dois(data.minute)}';
  }

  Future<void> _apagarSeExistir(File arquivo) async {
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }

  Never restaurarBackup() {
    throw const BackupAindaNaoImplementadoException(
      'A restauração será adicionada na Etapa 15.2.',
    );
  }
}

class BackupException implements Exception {
  const BackupException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class BackupValidacaoException implements Exception {
  const BackupValidacaoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class BackupCompartilhamentoException implements Exception {
  const BackupCompartilhamentoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class BackupAindaNaoImplementadoException implements Exception {
  const BackupAindaNaoImplementadoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}
