import 'package:flutter/material.dart';

class ConfirmarLimpezaHistoricoDialog extends StatefulWidget {
  const ConfirmarLimpezaHistoricoDialog({super.key});

  @override
  State<ConfirmarLimpezaHistoricoDialog> createState() =>
      _ConfirmarLimpezaHistoricoDialogState();
}

class _ConfirmarLimpezaHistoricoDialogState
    extends State<ConfirmarLimpezaHistoricoDialog> {
  final TextEditingController _controller = TextEditingController();

  bool get _confirmacaoValida {
    return _controller.text.trim().toUpperCase() == 'LIMPAR';
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_atualizar);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_atualizar)
      ..dispose();
    super.dispose();
  }

  void _atualizar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: const Text('Limpar histórico de treinos?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esta ação removerá definitivamente:'),
            const SizedBox(height: 12),
            const _ItemRemovido(texto: 'Treinos realizados'),
            const _ItemRemovido(texto: 'Exercícios e séries realizadas'),
            const _ItemRemovido(texto: 'Histórico e evolução'),
            const _ItemRemovido(texto: 'Progresso das etapas do plano'),
            const SizedBox(height: 12),
            Text(
              'Fichas, planos, exercícios, grupos musculares e configurações '
              'serão preservados.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Para confirmar, digite LIMPAR:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'LIMPAR',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmacaoValida
              ? () {
                  Navigator.of(context).pop(true);
                }
              : null,
          child: const Text('Limpar histórico'),
        ),
      ],
    );
  }
}

class _ItemRemovido extends StatelessWidget {
  const _ItemRemovido({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.delete_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
