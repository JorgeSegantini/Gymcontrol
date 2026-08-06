Modelo Físico da Biblioteca Oficial

Projeto: GymControlDocumento: ModeloFisicoBiblioteca.mdVersão: 1.0Status: Aprovado para implementaçãoÚltima atualização: 2026-07-27

1. Objetivo

Este documento define o modelo físico da Biblioteca Oficial do GymControl e será a referência direta para a implementação das tabelas, chaves, índices, restrições e migrações no Drift.

2. Princípios

A Biblioteca Oficial é separada dos dados do usuário.

Todo item oficial possui código permanente.

Códigos publicados nunca são reutilizados.

Registros oficiais são inativados, não apagados.

Relacionamentos N possuem tabelas próprias.

O SQLite é a fonte de consulta em tempo de execução.

Os JSONs são usados apenas para distribuição.

Instalações e atualizações são transacionais.

O histórico do usuário deve permanecer legível.

Exercícios personalizados não são alterados pelo instalador oficial.

3. Convenções gerais

3.1 Identificador local

Todas as tabelas principais possuirão:

id INTEGER PRIMARY KEY AUTOINCREMENT

O id é local e não substitui o código permanente.

3.2 Código permanente

Todos os catálogos oficiais possuirão:

codigo TEXT NOT NULL UNIQUE

Prefixos previstos:

GM  Grupo muscular
CE  Categoria de equipamento
EQ  Equipamento
PM  Padrão motor
MV  Movimento
VR  Variação
NV  Nível
TG  Tag
AL  Alias
EX  Exercício

3.3 Campos comuns

Quando aplicável:

ativo BOOLEAN NOT NULL DEFAULT TRUE
criadoEm DATETIME NOT NULL
atualizadoEm DATETIME NOT NULL

3.4 Datas

As datas serão armazenadas em UTC.

3.5 Exclusão

Atualizações normais usarão inativação lógica:

ativo = false

4. Tabelas previstas

BibliotecaMetadata

BibliotecaGruposMusculares
BibliotecaCategoriasEquipamentos
BibliotecaEquipamentos
BibliotecaPadroesMotores
BibliotecaMovimentos
BibliotecaVariacoes
BibliotecaNiveis
BibliotecaTags
BibliotecaAliases
BibliotecaExercicios

BibliotecaExerciciosGrupos
BibliotecaExerciciosEquipamentos
BibliotecaExerciciosTags
BibliotecaExerciciosAliases

Total: 15 tabelas.

5. BibliotecaMetadata

Responsabilidade

Registrar a versão instalada da Biblioteca Oficial.

Campos

Campo

Tipo

Obrigatório

Regra

id

INTEGER

Sim

Chave primária

versao

INTEGER

Sim

Maior ou igual a 1

dataVersao

TEXT

Sim

Data do versao.json

instaladoEm

DATETIME

Sim

UTC

atualizadoEm

DATETIME

Sim

UTC

hash

TEXT

Não

Hash global

quantidadeGrupos

INTEGER

Sim

Não negativo

quantidadeCategoriasEquipamentos

INTEGER

Sim

Não negativo

quantidadeEquipamentos

INTEGER

Sim

Não negativo

quantidadePadroesMotores

INTEGER

Sim

Não negativo

quantidadeMovimentos

INTEGER

Sim

Não negativo

quantidadeVariacoes

INTEGER

Sim

Não negativo

quantidadeNiveis

INTEGER

Sim

Não negativo

quantidadeTags

INTEGER

Sim

Não negativo

quantidadeAliases

INTEGER

Sim

Não negativo

quantidadeExercicios

INTEGER

Sim

Não negativo

Regras

Deve existir no máximo um registro.

O registro só é atualizado no fim da transação.

Quantidades não podem ser negativas.

6. Estrutura comum dos catálogos

As tabelas abaixo compartilham a estrutura básica:

BibliotecaGruposMusculares;

BibliotecaCategoriasEquipamentos;

BibliotecaPadroesMotores;

BibliotecaMovimentos;

BibliotecaVariacoes;

BibliotecaNiveis;

BibliotecaTags.

Campos

Campo

Tipo

Obrigatório

Regra

id

INTEGER

Sim

Chave primária

codigo

TEXT

Sim

Único e permanente

nome

TEXT

Sim

Não vazio

nomeNormalizado

TEXT

Sim

Pesquisa

ordem

INTEGER

Sim

Padrão 0

ativo

BOOLEAN

Sim

Padrão true

criadoEm

DATETIME

Sim

UTC

atualizadoEm

DATETIME

Sim

UTC

Restrições

UNIQUE(codigo)

Índices

INDEX(nomeNormalizado)
INDEX(ativo, ordem)

7. BibliotecaEquipamentos

Campos

Campo

Tipo

Obrigatório

Regra

id

INTEGER

Sim

Chave primária

codigo

TEXT

Sim

Único

categoriaCodigo

TEXT

Sim

FK

nome

TEXT

Sim

Não vazio

nomeNormalizado

TEXT

Sim

Pesquisa

ordem

INTEGER

Sim

Padrão 0

ativo

BOOLEAN

Sim

Padrão true

criadoEm

DATETIME

Sim

UTC

atualizadoEm

DATETIME

Sim

UTC

Chave estrangeira

categoriaCodigo
→ BibliotecaCategoriasEquipamentos.codigo

Índices

UNIQUE(codigo)
INDEX(categoriaCodigo)
INDEX(nomeNormalizado)
INDEX(ativo, ordem)

8. BibliotecaAliases

Campos

Campo

Tipo

Obrigatório

id

INTEGER

Sim

codigo

TEXT

Sim

nome

TEXT

Sim

nomeNormalizado

TEXT

Sim

ativo

BOOLEAN

Sim

criadoEm

DATETIME

Sim

atualizadoEm

DATETIME

Sim

Regras

UNIQUE(codigo)
INDEX(nomeNormalizado)
INDEX(ativo)

nomeNormalizado não precisa ser globalmente único, pois o mesmo alias pode ser associado a mais de um exercício.

9. BibliotecaExercicios

Responsabilidade

Armazenar os dados próprios dos exercícios oficiais.

Campos

Campo

Tipo

Obrigatório

Observação

id

INTEGER

Sim

Chave primária

codigo

TEXT

Sim

Único e permanente

nome

TEXT

Sim

Nome exibido

nomeNormalizado

TEXT

Sim

Pesquisa

movimentoCodigo

TEXT

Não

FK

variacaoCodigo

TEXT

Não

FK

padraoMotorCodigo

TEXT

Não

FK

nivelCodigo

TEXT

Não

FK

descricao

TEXT

Não

Texto livre

instrucoesJson

TEXT

Não

Lista JSON

dicasJson

TEXT

Não

Lista JSON

errosComunsJson

TEXT

Não

Lista JSON

unilateral

BOOLEAN

Sim

Padrão false

usaPesoCorporal

BOOLEAN

Sim

Padrão false

usaMaquina

BOOLEAN

Sim

Padrão false

velocidadeExecucao

TEXT

Não

Enum textual

descansoPadraoSegundos

INTEGER

Não

Não negativo

popularidade

INTEGER

Sim

Padrão 0

ativo

BOOLEAN

Sim

Padrão true

criadoEm

DATETIME

Sim

UTC

atualizadoEm

DATETIME

Sim

UTC

Chaves estrangeiras

movimentoCodigo
→ BibliotecaMovimentos.codigo

variacaoCodigo
→ BibliotecaVariacoes.codigo

padraoMotorCodigo
→ BibliotecaPadroesMotores.codigo

nivelCodigo
→ BibliotecaNiveis.codigo

Restrições

UNIQUE(codigo)
CHECK(descansoPadraoSegundos IS NULL OR descansoPadraoSegundos >= 0)
CHECK(popularidade >= 0)

Índices

INDEX(nomeNormalizado)
INDEX(movimentoCodigo)
INDEX(variacaoCodigo)
INDEX(padraoMotorCodigo)
INDEX(nivelCodigo)
INDEX(ativo, popularidade)

Listas textuais

Na primeira versão:

instrucoesJson
dicasJson
errosComunsJson

serão armazenados como texto JSON. Eles não serão usados como relacionamentos estruturais.

10. BibliotecaExerciciosGrupos

Campos

Campo

Tipo

Obrigatório

id

INTEGER

Sim

exercicioCodigo

TEXT

Sim

grupoCodigo

TEXT

Sim

tipoParticipacao

TEXT

Sim

ordem

INTEGER

Sim

Valores permitidos

principal
secundario

Chaves estrangeiras

exercicioCodigo
→ BibliotecaExercicios.codigo

grupoCodigo
→ BibliotecaGruposMusculares.codigo

Restrições

UNIQUE(exercicioCodigo, grupoCodigo)
CHECK(tipoParticipacao IN ('principal', 'secundario'))

Índices

INDEX(exercicioCodigo)
INDEX(grupoCodigo)
INDEX(exercicioCodigo, tipoParticipacao)

Regra adicional

Cada exercício ativo deverá possuir exatamente um grupo principal.

Essa regra será validada pelo Validator e pelo Installer.

11. BibliotecaExerciciosEquipamentos

Campos

Campo

Tipo

Obrigatório

id

INTEGER

Sim

exercicioCodigo

TEXT

Sim

equipamentoCodigo

TEXT

Sim

obrigatorio

BOOLEAN

Sim

ordem

INTEGER

Sim

Chaves estrangeiras

exercicioCodigo
→ BibliotecaExercicios.codigo

equipamentoCodigo
→ BibliotecaEquipamentos.codigo

Restrições e índices

UNIQUE(exercicioCodigo, equipamentoCodigo)
INDEX(exercicioCodigo)
INDEX(equipamentoCodigo)
INDEX(exercicioCodigo, obrigatorio)

12. BibliotecaExerciciosTags

Campos

Campo

Tipo

Obrigatório

id

INTEGER

Sim

exercicioCodigo

TEXT

Sim

tagCodigo

TEXT

Sim

Chaves estrangeiras

exercicioCodigo
→ BibliotecaExercicios.codigo

tagCodigo
→ BibliotecaTags.codigo

Restrições e índices

UNIQUE(exercicioCodigo, tagCodigo)
INDEX(exercicioCodigo)
INDEX(tagCodigo)

13. BibliotecaExerciciosAliases

Campos

Campo

Tipo

Obrigatório

id

INTEGER

Sim

exercicioCodigo

TEXT

Sim

aliasCodigo

TEXT

Sim

Chaves estrangeiras

exercicioCodigo
→ BibliotecaExercicios.codigo

aliasCodigo
→ BibliotecaAliases.codigo

Restrições e índices

UNIQUE(exercicioCodigo, aliasCodigo)
INDEX(exercicioCodigo)
INDEX(aliasCodigo)

14. Ordem de criação das tabelas

1. BibliotecaMetadata
2. BibliotecaGruposMusculares
3. BibliotecaCategoriasEquipamentos
4. BibliotecaEquipamentos
5. BibliotecaPadroesMotores
6. BibliotecaMovimentos
7. BibliotecaVariacoes
8. BibliotecaNiveis
9. BibliotecaTags
10. BibliotecaAliases
11. BibliotecaExercicios
12. BibliotecaExerciciosGrupos
13. BibliotecaExerciciosEquipamentos
14. BibliotecaExerciciosTags
15. BibliotecaExerciciosAliases

15. Ordem de instalação dos dados

1. Categorias de equipamentos
2. Equipamentos
3. Grupos musculares
4. Padrões motores
5. Movimentos
6. Variações
7. Níveis
8. Tags
9. Aliases
10. Exercícios
11. Exercício × Grupo
12. Exercício × Equipamento
13. Exercício × Tag
14. Exercício × Alias
15. Metadata

BibliotecaMetadata será gravada por último.

16. Atualização por código permanente

Código não existe
→ inserir

Código já existe
→ atualizar os campos oficiais

Código existe no banco, mas não está na nova distribuição
→ marcar ativo = false

O id local não será usado para identificar registros entre versões.

17. Integridade referencial

O banco deverá manter:

PRAGMA foreign_keys = ON;

As chaves estrangeiras deverão impedir exclusões físicas acidentais.

Não será usado CASCADE DELETE nas tabelas principais da Biblioteca.

18. Pesquisa

A pesquisa de exercícios poderá considerar:

nome oficial;

nome normalizado;

aliases;

grupos musculares;

equipamentos;

tags;

movimento;

padrão motor;

popularidade;

estado ativo.

Ordenação recomendada:

1. Correspondência exata
2. Correspondência pelo início
3. Popularidade decrescente
4. Nome crescente

19. Tipos Drift

SQLite

Drift

INTEGER

IntColumn

TEXT

TextColumn

BOOLEAN

BoolColumn

DATETIME

DateTimeColumn

Enums simples poderão ser persistidos como texto.

Exemplos:

tipoParticipacao
velocidadeExecucao

20. Migração

A implementação exigirá aumento de schemaVersion.

A migração deverá:

criar as 15 tabelas;

preservar todas as tabelas e dados atuais;

não apagar grupos ou exercícios do usuário;

manter compatibilidade com cadastros existentes;

executar a geração do Drift;

validar a abertura do banco;

executar os testes.

A versão exata do schema será definida após a leitura do app_database.dart atual.

21. Compatibilidade com as tabelas atuais

As tabelas atuais:

GruposMusculares
Exercicios

continuam pertencendo aos dados do usuário.

As tabelas oficiais terão nomes independentes:

BibliotecaGruposMusculares
BibliotecaExercicios

Isso evita colisões e mantém os domínios separados.

22. Regras aplicadas pelo Validator e Installer

As seguintes regras não dependerão apenas de restrições SQL:

exatamente um grupo principal por exercício ativo;

contagens iguais ao versao.json;

códigos com prefixos corretos;

todas as referências válidas;

ausência de códigos duplicados;

inativação dos itens ausentes;

preservação dos códigos já publicados.

23. Checklist antes da implementação

ArquiteturaBiblioteca.md atualizado.

Modelo físico aprovado.

app_database.dart atual revisado.

schemaVersion atual confirmado.

Tabelas existentes confirmadas.

Estratégia de migração definida.

Arquivos JSON novos planejados.

Modelos Dart planejados.

Índices confirmados.

Relacionamentos confirmados.

24. Critérios de conclusão

A implementação será considerada concluída quando:

as 15 tabelas existirem no Drift;

todas as FKs estiverem configuradas;

os índices obrigatórios estiverem implementados;

o banco abrir com foreign_keys = ON;

a migração preservar os dados atuais;

o build_runner finalizar;

flutter analyze não apresentar problemas;

os testes do banco forem aprovados.

25. Encerramento

Este documento define o modelo físico oficial da Biblioteca do GymControl.

Qualquer mudança estrutural deverá ser registrada aqui antes da alteração do código.