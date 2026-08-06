import 'dart:io';

class BackupInfo {
  const BackupInfo({
    required this.ultimoBackupEm,
    required this.nomeArquivo,
    required this.tamanhoBytes,
    required this.compartilhado,
    required this.compartilhadoEm,
  });

  final DateTime? ultimoBackupEm;
  final String? nomeArquivo;
  final int? tamanhoBytes;
  final bool compartilhado;
  final DateTime? compartilhadoEm;

  bool get possuiBackup => ultimoBackupEm != null && nomeArquivo != null;

  bool get backupValido {
    return possuiBackup && tamanhoBytes != null && tamanhoBytes! > 0;
  }

  static const vazio = BackupInfo(
    ultimoBackupEm: null,
    nomeArquivo: null,
    tamanhoBytes: null,
    compartilhado: false,
    compartilhadoEm: null,
  );
}

class BackupCriado {
  const BackupCriado({
    required this.arquivo,
    required this.criadoEm,
    required this.nomeArquivo,
    required this.tamanhoBytes,
  });

  final File arquivo;
  final DateTime criadoEm;
  final String nomeArquivo;
  final int tamanhoBytes;

  BackupInfo get info {
    return BackupInfo(
      ultimoBackupEm: criadoEm,
      nomeArquivo: nomeArquivo,
      tamanhoBytes: tamanhoBytes,
      compartilhado: false,
      compartilhadoEm: null,
    );
  }
}
