import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/widgets/gc_number_badge.dart';
import 'informacao_serie.dart';

class SerieCard extends StatelessWidget {
  const SerieCard({
    required this.serie,
    required this.indice,
    required this.onTap,
    required this.onRemover,
    required this.onDuplicar,
    required this.onAlterarSituacao,
    super.key,
  });

  final FichaExercicioSerie serie;
  final int indice;
  final VoidCallback onTap;
  final VoidCallback onRemover;
  final VoidCallback onDuplicar;
  final VoidCallback onAlterarSituacao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GcNumberBadge(numero: serie.ordem),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _ConteudoSerie(serie: serie)),
                const SizedBox(width: AppSpacing.xs),
                _AcoesSerie(
                  serie: serie,
                  indice: indice,
                  onAlterarSituacao: onAlterarSituacao,
                  onRemover: onRemover,
                  onDuplicar: onDuplicar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConteudoSerie extends StatelessWidget {
  const _ConteudoSerie({required this.serie});

  final FichaExercicioSerie serie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Série ${serie.ordem}',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!serie.ativo)
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Chip(
                  label: Text('Inativa'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            InformacaoSerie(
              icone: Icons.category_outlined,
              texto: _nomeTipoSerie(serie.tipoSerie),
            ),
            InformacaoSerie(
              icone: Icons.repeat,
              texto: _formatarRepeticoes(
                serie.repeticoesMinimas,
                serie.repeticoesMaximas,
              ),
            ),
            InformacaoSerie(
              icone: Icons.monitor_weight_outlined,
              texto: _formatarCarga(serie.cargaPlanejadaGramas),
            ),
            InformacaoSerie(
              icone: Icons.timer_outlined,
              texto: _formatarDescanso(serie.descansoSegundos),
            ),
          ],
        ),
      ],
    );
  }

  static String _nomeTipoSerie(String tipoSerie) {
    return switch (tipoSerie) {
      'normal' => 'Normal',
      'aquecimento' => 'Aquecimento',
      'dropSet' => 'Drop set',
      'restPause' => 'Rest-pause',
      'biSet' => 'Bi-set',
      'triSet' => 'Tri-set',
      'cluster' => 'Cluster',
      'isometrica' => 'Isométrica',
      _ => tipoSerie,
    };
  }

  static String _formatarRepeticoes(
    int? repeticoesMinimas,
    int? repeticoesMaximas,
  ) {
    if (repeticoesMinimas == null && repeticoesMaximas == null) {
      return 'Repetições não definidas';
    }

    if (repeticoesMinimas != null &&
        repeticoesMaximas != null &&
        repeticoesMinimas != repeticoesMaximas) {
      return '$repeticoesMinimas–$repeticoesMaximas rep';
    }

    final repeticoes = repeticoesMinimas ?? repeticoesMaximas;

    return '$repeticoes rep';
  }

  static String _formatarCarga(int? cargaGramas) {
    if (cargaGramas == null) {
      return 'Carga não definida';
    }

    final cargaQuilos = cargaGramas / 1000;

    if (cargaQuilos == cargaQuilos.roundToDouble()) {
      return '${cargaQuilos.toInt()} kg';
    }

    return '${cargaQuilos.toStringAsFixed(1)} kg';
  }

  static String _formatarDescanso(int descansoSegundos) {
    if (descansoSegundos == 0) {
      return 'Sem descanso definido';
    }

    final minutos = descansoSegundos ~/ 60;
    final segundos = descansoSegundos % 60;

    if (minutos == 0) {
      return '$segundos s';
    }

    if (segundos == 0) {
      return '$minutos min';
    }

    return '$minutos min $segundos s';
  }
}

enum _AcaoSerie { alterarSituacao, remover, duplicar }

class _AcoesSerie extends StatelessWidget {
  const _AcoesSerie({
    required this.serie,
    required this.indice,
    required this.onAlterarSituacao,
    required this.onRemover,
    required this.onDuplicar,
  });

  final FichaExercicioSerie serie;
  final int indice;
  final VoidCallback onAlterarSituacao;
  final VoidCallback onRemover;
  final VoidCallback onDuplicar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<_AcaoSerie>(
          tooltip: 'Ações da série',
          icon: const Icon(Icons.more_vert),
          onSelected: (acao) {
            switch (acao) {
              case _AcaoSerie.alterarSituacao:
                onAlterarSituacao();
              case _AcaoSerie.remover:
                onRemover();
              case _AcaoSerie.duplicar:
                onDuplicar();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: _AcaoSerie.alterarSituacao,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    serie.ativo
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  title: Text(serie.ativo ? 'Inativar série' : 'Ativar série'),
                ),
              ),
              const PopupMenuItem(
                value: _AcaoSerie.duplicar,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.content_copy_outlined),
                  title: Text('Duplicar série'),
                ),
              ),
              const PopupMenuItem(
                value: _AcaoSerie.remover,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Remover série'),
                ),
              ),
            ];
          },
        ),
        ReorderableDragStartListener(
          index: indice,
          child: const SizedBox(
            width: 36,
            height: 40,
            child: Icon(Icons.drag_handle, size: 22),
          ),
        ),
      ],
    );
  }
}
