import 'package:flutter/material.dart';

import '../../data/home_dashboard_models.dart';

class HomeCalendario extends StatelessWidget {
  const HomeCalendario({
    required this.calendario,
    required this.podeVoltarAoMesAtual,
    required this.onMesAnterior,
    required this.onProximoMes,
    required this.onVoltarAoMesAtual,
    required this.onDiaTap,
    super.key,
  });

  final HomeCalendarioMes calendario;
  final bool podeVoltarAoMesAtual;
  final VoidCallback onMesAnterior;
  final VoidCallback onProximoMes;
  final VoidCallback onVoltarAoMesAtual;
  final ValueChanged<HomeCalendarioDia> onDiaTap;

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(calendario.ano, calendario.mes);
    final espacosIniciais = primeiroDia.weekday - DateTime.monday;
    final totalCelulas = espacosIniciais + calendario.dias.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mês anterior',
                  onPressed: onMesAnterior,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${_nomeMes(calendario.mes)} de ${calendario.ano}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  onPressed: onProximoMes,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            if (podeVoltarAoMesAtual)
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: onVoltarAoMesAtual,
                  icon: const Icon(Icons.today_outlined, size: 18),
                  label: const Text('Voltar para hoje'),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final nome in const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'])
                  Expanded(
                    child: Center(
                      child: Text(
                        nome,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ((totalCelulas + 6) ~/ 7) * 7,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.88,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final indiceDia = index - espacosIniciais;

                if (indiceDia < 0 || indiceDia >= calendario.dias.length) {
                  return const SizedBox.shrink();
                }

                final dia = calendario.dias[indiceDia];

                return _DiaCalendario(
                  dia: dia,
                  onTap: () {
                    onDiaTap(dia);
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _LegendaCalendario(
                  icon: Icons.check_circle,
                  texto: 'Realizado',
                ),
                _LegendaCalendario(icon: Icons.today, texto: 'Hoje'),
                _LegendaCalendario(icon: Icons.schedule, texto: 'Previsto'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _nomeMes(int mes) {
    return switch (mes) {
      DateTime.january => 'Janeiro',
      DateTime.february => 'Fevereiro',
      DateTime.march => 'Março',
      DateTime.april => 'Abril',
      DateTime.may => 'Maio',
      DateTime.june => 'Junho',
      DateTime.july => 'Julho',
      DateTime.august => 'Agosto',
      DateTime.september => 'Setembro',
      DateTime.october => 'Outubro',
      DateTime.november => 'Novembro',
      DateTime.december => 'Dezembro',
      _ => '',
    };
  }
}

class _DiaCalendario extends StatelessWidget {
  const _DiaCalendario({required this.dia, required this.onTap});

  final HomeCalendarioDia dia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preenchido =
        dia.situacao == HomeCalendarioSituacao.hoje ||
        dia.situacao == HomeCalendarioSituacao.realizado;

    final cor = switch (dia.situacao) {
      HomeCalendarioSituacao.realizado => colorScheme.tertiary,
      HomeCalendarioSituacao.hoje => colorScheme.primary,
      HomeCalendarioSituacao.previsto => colorScheme.secondary,
      HomeCalendarioSituacao.semRegistro => colorScheme.outlineVariant,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: preenchido ? cor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${dia.data.day}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: preenchido
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Icon(
              _iconeSituacao(dia.situacao),
              size: 14,
              color: preenchido ? colorScheme.onPrimary : cor,
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconeSituacao(HomeCalendarioSituacao situacao) {
    return switch (situacao) {
      HomeCalendarioSituacao.realizado => Icons.check_rounded,
      HomeCalendarioSituacao.hoje => Icons.star_rounded,
      HomeCalendarioSituacao.previsto => Icons.schedule,
      HomeCalendarioSituacao.semRegistro => Icons.circle_outlined,
    };
  }
}

class _LegendaCalendario extends StatelessWidget {
  const _LegendaCalendario({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(texto, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
