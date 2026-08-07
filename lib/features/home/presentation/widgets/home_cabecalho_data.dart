import 'package:flutter/material.dart';

class HomeCabecalhoData extends StatelessWidget {
  const HomeCabecalhoData({required this.data, required this.nome, super.key});

  final DateTime data;
  final String nome;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_saudacao(data.hour)}, $nome 👋',
          style: tema.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_nomeDiaSemana(data.weekday)}, ${data.day} de ${_nomeMes(data.month)}',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _saudacao(int hora) {
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
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
