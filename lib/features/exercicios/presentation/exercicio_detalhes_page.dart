import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class ExercicioDetalhesPage extends StatefulWidget {
  const ExercicioDetalhesPage({
    required this.database,
    required this.exercicioId,
    super.key,
  });

  final AppDatabase database;
  final int exercicioId;

  @override
  State<ExercicioDetalhesPage> createState() => _ExercicioDetalhesPageState();
}

class _ExercicioDetalhesPageState extends State<ExercicioDetalhesPage> {
  late Future<Exercicio?> _exercicioFuture;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    _exercicioFuture = widget.database.exercicioDao.obterPorId(
      widget.exercicioId,
    );
  }

  String? _texto(String? valor) {
    final texto = valor?.trim();
    return texto == null || texto.isEmpty ? null : texto;
  }

  Future<void> _editarAnotacoes(Exercicio exercicio) async {
    var anotacaoDigitada = exercicio.anotacoesPessoais ?? '';

    final novaAnotacao = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Anotações pessoais'),
          content: TextFormField(
            initialValue: anotacaoDigitada,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (valor) {
              anotacaoDigitada = valor;
            },
            decoration: const InputDecoration(
              hintText: 'Ex.: banco posição 3, pegada mais fechada...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(anotacaoDigitada);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novaAnotacao == null || !mounted) {
      return;
    }

    try {
      final alterado = await widget.database.exercicioDao
          .salvarAnotacoesPessoais(
            id: exercicio.id,
            anotacoesPessoais: novaAnotacao,
          );

      if (!mounted) {
        return;
      }

      if (!alterado) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('O exercício não foi encontrado.')),
          );
        return;
      }

      setState(() {
        _recarregar();
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Anotações salvas.')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar as anotações.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercicio?>(
      future: _exercicioFuture,
      builder: (context, snapshot) {
        final exercicio = snapshot.data;

        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes do exercício')),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : exercicio == null
              ? const Center(child: Text('Exercício não encontrado.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    Text(
                      exercicio.nome,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    if (_texto(exercicio.nomeCurto) != null &&
                        exercicio.nomeCurto != exercicio.nome)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          exercicio.nomeCurto!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    _SecaoDetalhe(
                      icone: Icons.play_circle_outline,
                      titulo: 'Execução',
                      texto: _texto(exercicio.instrucoes),
                      vazio: 'Ainda não há instruções de execução.',
                    ),
                    const SizedBox(height: 12),
                    _SecaoDetalhe(
                      icone: Icons.lightbulb_outline,
                      titulo: 'Dicas',
                      texto: _texto(exercicio.dicas),
                      vazio: 'Ainda não há dicas para este exercício.',
                    ),
                    const SizedBox(height: 12),
                    _SecaoDetalhe(
                      icone: Icons.warning_amber_rounded,
                      titulo: 'Atenção',
                      texto: _texto(exercicio.errosComuns),
                      vazio:
                          'Ainda não há alertas ou erros comuns cadastrados.',
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_note_outlined),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Anotações pessoais',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Editar anotações',
                                  onPressed: () => _editarAnotacoes(exercicio),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _texto(exercicio.anotacoesPessoais) ??
                                  'Nenhuma anotação pessoal.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SecaoDetalhe extends StatelessWidget {
  const _SecaoDetalhe({
    required this.icone,
    required this.titulo,
    required this.texto,
    required this.vazio,
  });

  final IconData icone;
  final String titulo;
  final String? texto;
  final String vazio;

  @override
  Widget build(BuildContext context) {
    final temConteudo = texto != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 21),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              texto ?? vazio,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: temConteudo
                    ? null
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: temConteudo ? null : FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
