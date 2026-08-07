import 'package:flutter/material.dart';

import '../../../features/perfil/data/perfil_local_controller.dart';
import '../../../shared/theme/theme_controller.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({
    required this.themeController,
    required this.perfilController,
    super.key,
  });

  final ThemeController themeController;
  final PerfilLocalController perfilController;

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  late String _nome;

  @override
  void initState() {
    super.initState();
    _nome = widget.perfilController.nome ?? '';
  }

  Future<void> _editarNome() async {
    var nomeDigitado = _nome;

    final novoNome = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar nome'),
          content: TextFormField(
            initialValue: _nome,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (valor) {
              nomeDigitado = valor;
            },
            onFieldSubmitted: (_) {
              final nome = nomeDigitado.trim();

              if (nome.isNotEmpty) {
                Navigator.of(dialogContext).pop(nome);
              }
            },
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final nome = nomeDigitado.trim();

                if (nome.isNotEmpty) {
                  Navigator.of(dialogContext).pop(nome);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novoNome == null || !mounted) {
      return;
    }

    await widget.perfilController.alterarNome(novoNome);

    if (!mounted) {
      return;
    }

    setState(() {
      _nome = novoNome;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Perfil',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(_nome),
              subtitle: const Text('Nome usado nas saudações do GymControl'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _editarNome,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aparência',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: widget.themeController,
            builder: (context, _) {
              return Card(
                child: RadioGroup<ThemeMode>(
                  groupValue: widget.themeController.themeMode,
                  onChanged: (themeMode) {
                    if (themeMode != null) {
                      widget.themeController.alterarTema(themeMode);
                    }
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
              );
            },
          ),
        ],
      ),
    );
  }
}
