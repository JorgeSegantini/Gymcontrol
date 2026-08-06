import 'package:flutter/material.dart';

class DescansoBar extends StatelessWidget {
  const DescansoBar({
    required this.restante,
    required this.total,
    required this.pausado,
    required this.origem,
    required this.onPausar,
    required this.onPular,
    super.key,
  });

  final int restante;
  final int total;
  final bool pausado;
  final String? origem;
  final VoidCallback onPausar;
  final VoidCallback onPular;

  @override
  Widget build(BuildContext context) {
    final progresso = total <= 0 ? 0.0 : restante / total;

    return SafeArea(
      top: false,
      child: Material(
        elevation: 12,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descanso ${origem ?? ''}'.trim(),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _formatarTempo(restante),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onPausar,
                    icon: Icon(pausado ? Icons.play_arrow : Icons.pause),
                    label: Text(pausado ? 'Continuar' : 'Pausar'),
                  ),
                  TextButton(onPressed: onPular, child: const Text('Pular')),
                ],
              ),
              LinearProgressIndicator(
                value: progresso,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final restante = segundos % 60;

    return '${minutos.toString().padLeft(2, '0')}:'
        '${restante.toString().padLeft(2, '0')}';
  }
}
