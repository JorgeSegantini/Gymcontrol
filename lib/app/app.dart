import 'package:flutter/material.dart';

import '../core/database/app_database.dart';
import '../features/home/presentation/home_page.dart';
import '../shared/theme/dark_theme.dart';
import '../shared/theme/light_theme.dart';
import '../shared/theme/theme_controller.dart';

class GymControlApp extends StatefulWidget {
  const GymControlApp({required this.database, super.key});

  final AppDatabase database;

  @override
  State<GymControlApp> createState() => _GymControlAppState();
}

class _GymControlAppState extends State<GymControlApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.carregar();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'GymControl',
          debugShowCheckedModeBanner: false,
          theme: GcLightTheme.build(),
          darkTheme: GcDarkTheme.build(),
          themeMode: _themeController.themeMode,
          home: HomePage(
            database: widget.database,
            themeController: _themeController,
          ),
        );
      },
    );
  }
}
