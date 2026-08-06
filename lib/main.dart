import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/biblioteca/installer/biblioteca_installer.dart';
import 'core/biblioteca/services/biblioteca_sync_service.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  final installer = BibliotecaInstaller(database: database);
  await installer.instalar();

  final syncService = BibliotecaSyncService(database: database);
  await syncService.sincronizarExercicios();

  runApp(GymControlApp(database: database));
}
