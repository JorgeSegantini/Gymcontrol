import 'package:flutter/material.dart';

class ControleNumerico extends StatelessWidget {
  const ControleNumerico({
    required this.rotulo,
    required this.valor,
    required this.textoMenos,
    required this.textoMais,
    required this.habilitado,
    required this.onDiminuir,
    required this.onAumentar,
    super.key,
  });

  final String rotulo;
  final String valor;
  final String textoMenos;
  final String textoMais;
  final bool habilitado;
  final VoidCallback onDiminuir;
  final VoidCallback onAumentar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          children: [
            OutlinedButton(
              onPressed: habilitado ? onDiminuir : null,
              style: OutlinedButton.styleFrom(minimumSize: const Size(76, 50)),
              child: Text(textoMenos),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  valor,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: habilitado ? onAumentar : null,
              style: OutlinedButton.styleFrom(minimumSize: const Size(76, 50)),
              child: Text(textoMais),
            ),
          ],
        ),
      ],
    );
  }
}
