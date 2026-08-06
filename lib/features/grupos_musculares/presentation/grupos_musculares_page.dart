import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import 'biblioteca_grupos_musculares_page.dart';
import 'grupo_muscular_form_dialog.dart';
import 'grupo_muscular_opcoes_dialog.dart';

class GruposMuscularesPage extends StatelessWidget {
  const GruposMuscularesPage({required this.database, super.key});

  final AppDatabase database;

  Future<void> _abrirFormularioCadastro(BuildContext context) async {
    final grupoCadastrado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return GrupoMuscularFormDialog(database: database);
      },
    );

    if (grupoCadastrado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo muscular cadastrado com sucesso.')),
      );
    }
  }

  Future<void> _abrirFormularioEdicao(
    BuildContext context,
    GrupoMuscular grupo,
  ) async {
    final grupoEditado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return GrupoMuscularFormDialog(database: database, grupo: grupo);
      },
    );

    if (grupoEditado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo muscular editado com sucesso.')),
      );
    }
  }

  Future<void> _alterarSituacao(
    BuildContext context,
    GrupoMuscular grupo,
  ) async {
    try {
      await database.grupoMuscularDao.alterarSituacao(
        id: grupo.id,
        ativo: !grupo.ativo,
      );

      if (!context.mounted) {
        return;
      }

      final mensagem = grupo.ativo
          ? 'Grupo muscular inativado com sucesso.'
          : 'Grupo muscular ativado com sucesso.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível alterar a situação do grupo muscular.',
          ),
        ),
      );
    }
  }

  Future<void> _abrirOpcoes(BuildContext context, GrupoMuscular grupo) async {
    final acao = await showDialog<AcaoGrupoMuscular>(
      context: context,
      builder: (_) {
        return GrupoMuscularOpcoesDialog(grupo: grupo);
      },
    );

    if (acao == null || !context.mounted) {
      return;
    }

    switch (acao) {
      case AcaoGrupoMuscular.editar:
        await _abrirFormularioEdicao(context, grupo);
        break;

      case AcaoGrupoMuscular.alterarSituacao:
        await _alterarSituacao(context, grupo);
        break;
    }
  }

  void _abrirBibliotecaOficial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return BibliotecaGruposMuscularesPage(database: database);
        },
      ),
    );
  }

  Widget _construirResumoBiblioteca() {
    return StreamBuilder<List<BibliotecaGrupoMuscular>>(
      stream: database.select(database.bibliotecaGruposMusculares).watch(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Biblioteca Oficial'),
              subtitle: Text(
                'Erro: ${snapshot.error}',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _abrirBibliotecaOficial(context);
              },
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Biblioteca Oficial'),
              subtitle: Text('Verificando grupos instalados...'),
            ),
          );
        }

        final quantidade = snapshot.data!.length;

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.library_books_outlined),
            ),
            title: const Text('Biblioteca Oficial'),
            subtitle: Text(
              '$quantidade grupos musculares oficiais instalados.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _abrirBibliotecaOficial(context);
            },
          ),
        );
      },
    );
  }

  Widget _construirListaGruposCadastrados() {
    return StreamBuilder<List<GrupoMuscular>>(
      stream: database.grupoMuscularDao.observarTodos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar os grupos musculares.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final grupos = snapshot.data!;

        if (grupos.isEmpty) {
          return const Center(child: Text('Nenhum grupo muscular cadastrado.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: grupos.length,
          separatorBuilder: (_, _) {
            return const SizedBox(height: 8);
          },
          itemBuilder: (context, index) {
            final grupo = grupos[index];

            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${grupo.ordem}')),
                title: Text(grupo.nome),
                subtitle: Text(grupo.ativo ? 'Ativo' : 'Inativo'),
                trailing: const Icon(Icons.more_vert),
                onTap: () {
                  _abrirOpcoes(context, grupo);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos musculares')),
      body: Column(
        children: [
          _construirResumoBiblioteca(),
          Expanded(child: _construirListaGruposCadastrados()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _abrirFormularioCadastro(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo grupo'),
      ),
    );
  }
}
