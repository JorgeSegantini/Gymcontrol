import 'package:flutter/material.dart';

class HomeCabecalhoData extends StatelessWidget {
  const HomeCabecalhoData({required this.data, super.key});

  final DateTime data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${data.day}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nomeDiaSemana(data.weekday),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                '${data.day} de ${_nomeMes(data.month)} de ${data.year}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _nomeDiaSemana(int dia) {
    return switch (dia) {
      DateTime.monday => 'Segunda-feira',
      DateTime.tuesday => 'Terça-feira',
      DateTime.wednesday => 'Quarta-feira',
      DateTime.thursday => 'Quinta-feira',
      DateTime.friday => 'Sexta-feira',
      DateTime.saturday => 'Sábado',
      DateTime.sunday => 'Domingo',
      _ => '',
    };
  }

  static String _nomeMes(int mes) {
    return switch (mes) {
      DateTime.january => 'janeiro',
      DateTime.february => 'fevereiro',
      DateTime.march => 'março',
      DateTime.april => 'abril',
      DateTime.may => 'maio',
      DateTime.june => 'junho',
      DateTime.july => 'julho',
      DateTime.august => 'agosto',
      DateTime.september => 'setembro',
      DateTime.october => 'outubro',
      DateTime.november => 'novembro',
      DateTime.december => 'dezembro',
      _ => '',
    };
  }
}
