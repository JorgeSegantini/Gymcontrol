import 'package:flutter/material.dart';

class CabecalhoTreino extends StatelessWidget {
  const CabecalhoTreino({
    required this.tempoDecorrido,
    required this.concluidas,
    required this.total,
    super.key,
  });

  final Duration tempoDecorrido;
  final int concluidas;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progresso = total == 0 ? 0.0 : concluidas / total;
    final percentual = (progresso * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 30),
          const SizedBox(width: 8),
          Text(
            _formatarDuracao(tempoDecorrido),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LinearProgressIndicator(
                    value: progresso,
                    minHeight: 18,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  Text(
                    '$percentual%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatarDuracao(Duration duracao) {
    final horas = duracao.inHours.toString().padLeft(2, '0');
    final minutos = duracao.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = duracao.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$horas:$minutos:$segundos';
  }
}
