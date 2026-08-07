import 'package:flutter/material.dart';

import '../../../shared/theme/theme_controller.dart';
import '../data/perfil_local_controller.dart';

class PrimeiroAcessoPage extends StatefulWidget {
  const PrimeiroAcessoPage({
    required this.perfilController,
    required this.themeController,
    super.key,
  });

  final PerfilLocalController perfilController;
  final ThemeController themeController;

  @override
  State<PrimeiroAcessoPage> createState() => _PrimeiroAcessoPageState();
}

class _PrimeiroAcessoPageState extends State<PrimeiroAcessoPage> {
  final _nomeController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _comecar() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Digite seu nome para continuar.')),
        );
      return;
    }

    setState(() => _salvando = true);
    await widget.perfilController.alterarNome(nome);

    if (mounted) {
      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 54,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bem-vindo ao GymControl',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Como podemos chamar você?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nomeController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _comecar(),
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      hintText: 'Ex.: Junior',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Escolha sua aparência',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: widget.themeController,
                    builder: (context, _) {
                      return Card(
                        child: RadioGroup<ThemeMode>(
                          groupValue: widget.themeController.themeMode,
                          onChanged: (tema) {
                            if (tema != null) {
                              widget.themeController.alterarTema(tema);
                            }
                          },
                          child: const Column(
                            children: [
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.system,
                                title: Text('Seguir sistema'),
                                secondary: Icon(Icons.brightness_auto_outlined),
                              ),
                              Divider(height: 1),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.light,
                                title: Text('Claro'),
                                secondary: Icon(Icons.light_mode_outlined),
                              ),
                              Divider(height: 1),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.dark,
                                title: Text('Escuro'),
                                secondary: Icon(Icons.dark_mode_outlined),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _salvando ? null : _comecar,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_salvando ? 'Salvando...' : 'Começar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
