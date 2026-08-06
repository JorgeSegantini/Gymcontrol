import 'package:flutter/material.dart';

import '../../../shared/theme/theme_controller.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Aparência',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: RadioGroup<ThemeMode>(
                  groupValue: themeController.themeMode,
                  onChanged: (themeMode) {
                    if (themeMode == null) {
                      return;
                    }

                    themeController.alterarTema(themeMode);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        title: Text('Seguir sistema'),
                        subtitle: Text('Usar o mesmo tema definido no Android'),
                        secondary: Icon(Icons.brightness_auto_outlined),
                      ),
                      Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        title: Text('Claro'),
                        subtitle: Text('Usar sempre o tema claro'),
                        secondary: Icon(Icons.light_mode_outlined),
                      ),
                      Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        title: Text('Escuro'),
                        subtitle: Text('Usar sempre o tema escuro'),
                        secondary: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
