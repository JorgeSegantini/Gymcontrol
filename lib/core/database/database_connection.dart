import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

LazyDatabase abrirConexaoBanco() {
  return LazyDatabase(() async {
    final diretorio = await getApplicationDocumentsDirectory();
    final arquivo = File(path.join(diretorio.path, 'gym_control.sqlite'));

    return NativeDatabase.createInBackground(arquivo);
  });
}
