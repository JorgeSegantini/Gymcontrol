import 'dart:io';

import 'backup_manifest.dart';

class BackupSelecionado {
  const BackupSelecionado({
    required this.arquivo,
    required this.nomeArquivo,
    required this.tamanhoBytes,
    required this.manifesto,
    required this.possuiBanco,
  });

  final File arquivo;
  final String nomeArquivo;
  final int tamanhoBytes;
  final BackupManifest manifesto;
  final bool possuiBanco;

  bool get compativel {
    return manifesto.aplicativo == 'GymControl' &&
        manifesto.versaoFormato == 1 &&
        possuiBanco;
  }
}
