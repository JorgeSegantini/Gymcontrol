import 'package:flutter/material.dart';

import '../../data/manutencao_banco_info.dart';

class InformacoesBancoCard extends StatelessWidget {
  const InformacoesBancoCard({required this.info, super.key});

  final ManutencaoBancoInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.storage_outlined),
        title: const Text(
          'Informações do banco',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${info.treinosRealizados} treinos • '
          '${info.seriesRealizadas} séries realizadas',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          _LinhaInfo(rotulo: 'Grupos musculares', valor: info.gruposMusculares),
          _LinhaInfo(rotulo: 'Exercícios', valor: info.exercicios),
          _LinhaInfo(rotulo: 'Fichas de treino', valor: info.fichasTreino),
          _LinhaInfo(rotulo: 'Planos de treino', valor: info.planosTreino),
          _LinhaInfo(
            rotulo: 'Treinos realizados',
            valor: info.treinosRealizados,
          ),
          _LinhaInfo(
            rotulo: 'Exercícios realizados',
            valor: info.exerciciosRealizados,
          ),
          _LinhaInfo(rotulo: 'Séries realizadas', valor: info.seriesRealizadas),
          _LinhaInfo(
            rotulo: 'Etapas do plano registradas',
            valor: info.execucoesPlano,
          ),
        ],
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({required this.rotulo, required this.valor});

  final String rotulo;
  final int valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(rotulo)),
          Text('$valor', style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
