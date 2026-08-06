so tenho essas opcoes como crio o dart
 onde esta o exibir
consegui 
 COLOQUEI A PRINT, NAO ENCHERGUEI NADA EM VERMELHO
Texto colado (1).txt
Documento
ela nao esta vazia 
ja criei todas as pastas e joguei os arquivos la 
Markdown(3).md colado
Ficheiro

Perfeito. Acho que agora vale a pena fazer uma mudança de estratégia.

Até aqui trabalhamos como se estivéssemos implementando o sistema enquanto projetávamos a arquitetura. A partir deste ponto, eu prefiro trabalhar como uma equipe de software faria em um projeto grande.

Minha proposta

Vamos congelar a arquitetura da Biblioteca Oficial antes de escrever mais código.

Mas não quero apenas reescrever o documento. Quero transformá-lo em um documento de arquitetura realmente profissional.

Eu dividiria em capítulos como estes:

1. Objetivo
2. Princípios Arquiteturais
3. Domínios
4. Modelo Conceitual
5. Modelo Lógico
6. Modelo Físico
7. Catálogos
8. Relacionamentos
9. Estrutura dos JSONs
10. Instalação
11. Atualização
12. Versionamento
13. Compatibilidade
14. Exercícios Personalizados
15. Evoluções Futuras
16. Decisões Arquiteturais
17. Diagramas
18. Checklist
19. Glossário
E eu faria uma mudança importante

Hoje a Biblioteca ainda está muito focada em exercícios.

Eu mudaria a visão para Conhecimento.

Ou seja:

Biblioteca Oficial

├── Conhecimento
│     ├── Grupos
│     ├── Equipamentos
│     ├── Categorias
│     ├── Padrões
│     ├── Movimentos
│     ├── Variações
│     ├── Níveis
│     └── Tags
│
├── Exercícios
│
├── Relacionamentos
│
└── Versionamento

Essa mudança parece sutil, mas é enorme.

Significa que o GymControl não terá apenas uma lista de exercícios; ele terá uma base de conhecimento sobre musculação.

Isso abre espaço para, no futuro:

montar treinos automaticamente;
sugerir substituições inteligentes;
identificar desequilíbrios musculares;
gerar estatísticas de volume por padrão motor;
recomendar exercícios equivalentes quando um equipamento não estiver disponível.

Tudo isso sem alterar a arquitetura.

Outra mudança que eu gostaria de fazer

Há uma decisão que eu mudaria em relação ao HiperControl.

No HiperControl, documentamos bastante ao longo do desenvolvimento. Funcionou bem, mas em alguns momentos precisávamos atualizar vários documentos quando uma decisão mudava.

No GymControl, eu faria diferente.

Teríamos apenas três documentos principais como "fonte da verdade":

docs/
│
├── Arquitetura.md
├── ArquiteturaBiblioteca.md
└── CHANGELOG.md

Os demais documentos surgiriam apenas quando realmente agregassem valor.

Isso reduz manutenção e evita divergências entre documentos.

Como vamos trabalhar daqui para frente

Minha sugestão é esta:

Fase A (Arquitetura): fechar completamente a Biblioteca Oficial.
Fase B (Implementação): implementar exatamente o que foi definido.
Fase C (Funcionalidades): criar telas, fichas, execução, histórico etc.

Assim, quando estivermos codificando, praticamente não precisaremos parar para decidir como modelar alguma entidade.

📝 Minha recomendação final

Eu não faria mais nenhuma implementação da Biblioteca até concluirmos a Versão 2.0 do ArquiteturaBiblioteca.md.

Esse documento será a base de todo o domínio de exercícios do GymControl. Depois dele, teremos um roteiro muito claro para as próximas sprints e a implementação ficará muito mais fluida e previsível.

ok

Perfeito. Então vamos fazer da forma que eu faria se estivesse liderando a arquitetura desse projeto desde o início.

A partir de agora muda a metodologia

Até aqui nós construímos a infraestrutura.

Agora paramos de programar por um momento.

Vamos projetar o domínio inteiro.

Só depois voltaremos para o Flutter.

Essa é exatamente a forma como projetos grandes são desenvolvidos.

Fase 1 — Arquitetura (100%)

Nesta fase vamos responder todas as perguntas difíceis.

Domínio Biblioteca
O que é um Exercício?
O que é um Movimento?
O que é uma Variação?
O que é um Equipamento?
O que é um Grupo Muscular?
O que é um Padrão Motor?
O que é um Alias?
O que é uma Tag?
O que pertence à Biblioteca Oficial?
O que pertence ao Usuário?
Domínio Treino

Depois modelaremos:

Ficha

↓

Treino

↓

Exercício

↓

Série

↓

Execução

Mas sem escrever código.

Domínio Histórico

Depois:

Treino realizado

↓

Séries realizadas

↓

Carga

↓

Repetições

↓

Volume

↓

Tempo
Domínio Evolução

Depois:

Peso

Medidas

Recordes

PR

Volume semanal

Volume mensal

Carga máxima

1RM

Progressão
Fase 2 — Banco

Depois que tudo estiver definido:

Arquitetura

↓

Modelo Lógico

↓

Modelo Físico

↓

Drift

Nesse momento escreveremos as tabelas.

Sem improviso.

Fase 3 — Flutter

Só então começaremos as telas.

Porque já saberemos exatamente quais objetos existem.

Fase 4 — Funcionalidades

Aí sim:

Cadastro
Biblioteca
Fichas
Execução
Histórico
Evolução
Backup
O que quero melhorar em relação ao HiperControl

Depois de conhecer seu jeito de trabalhar nos últimos meses, percebi algumas características importantes:

Você gosta de entender a arquitetura antes de implementar.
Prefere validar uma etapa de cada vez.
Registra mudanças e decisões importantes.
Não gosta de "gambiarras" que depois precisem ser refeitas.

Essas características combinam muito bem com um projeto em camadas bem definidas.

Por isso, vou adotar uma regra durante todo o GymControl:

Nenhum código novo será escrito enquanto a modelagem daquela parte não estiver completamente definida.

Isso pode parecer mais lento nas primeiras semanas, mas normalmente acelera bastante o restante do desenvolvimento.

Minha proposta de cronograma

Eu dividiria o GymControl em aproximadamente 12 grandes módulos:

Módulo	Status
1. Fundação Flutter	✅
2. Banco Drift	✅
3. Biblioteca Oficial	🔄 Em andamento
4. Exercícios do Usuário	⏳
5. Fichas de Treino	⏳
6. Execução do Treino	⏳
7. Histórico	⏳
8. Estatísticas	⏳
9. Peso Corporal	⏳
10. Medidas Corporais	⏳
11. Backup e Restauração	⏳
12. Polimento e Publicação	⏳
Minha responsabilidade daqui para frente

Quero assumir um papel um pouco diferente neste projeto.

Não quero apenas fornecer código. Quero atuar como um arquiteto técnico, ajudando a tomar decisões que mantenham o GymControl organizado por muitos anos.

Sempre que eu enxergar uma oportunidade de melhorar a arquitetura, vou:

explicar o motivo;
mostrar os impactos positivos e negativos;
sugerir uma solução;
deixar a decisão final com você.

Assim, as escolhas serão conscientes e documentadas.

📝 Primeiro objetivo

Nos próximos passos, vamos produzir a Arquitetura da Biblioteca v2.0. Ela será a referência oficial para tudo o que envolve exercícios e conhecimento do aplicativo. Depois disso, voltaremos ao Flutter para implementar exatamente o que foi definido, com muito menos retrabalho e uma base muito mais sólida.

vamos continuar

Preparei a versão 2.0 completa do documento, consolidando o conteúdo anterior e as decisões mais recentes sobre persistência, relacionamentos, atualização e preservação histórica.

ArquiteturaBiblioteca_v2.md

O que fazer agora

Substitua o conteúdo de:

docs/ArquiteturaBiblioteca.md

pelo conteúdo do arquivo novo.

📝 O arquivo foi ampliado porque agora ele funciona como a fonte oficial da implementação. As principais mudanças são:

todos os catálogos serão persistidos no SQLite;
inclusão de categorias de equipamentos e níveis;
códigos no formato GM000001, EX000001 etc.;
grupos e equipamentos separados do exercício por relacionamentos;
instalação e atualização transacionais;
inativação em vez de exclusão;
contratos definitivos dos JSONs;
modelo físico previsto no Drift;
regras de validação e integridade;
responsabilidades de Loader, Validator, Installer e Service;
preservação do histórico e dos exercícios personalizados.

Depois de substituir e salvar, não é necessário executar flutter analyze, pois alteramos somente documentação. O próximo passo será comparar a estrutura atual de assets/biblioteca com a nova arquitetura e ajustar primeiro o versao.json. 

Biblioteca
/
ArquiteturaBiblioteca_v2.md
Arquitetura da Biblioteca Oficial

Projeto: GymControl
Versão do documento: 2.0
Status: Aprovado para implementação
Última atualização: 2026-07-27

1. Objetivo

A Biblioteca Oficial é o domínio responsável por armazenar, organizar, validar, versionar e disponibilizar o conhecimento de musculação utilizado pelo GymControl.

Ela reúne informações independentes do usuário, como:

grupos musculares;
categorias de equipamentos;
equipamentos;
padrões motores;
movimentos;
variações;
níveis de dificuldade;
tags;
aliases;
exercícios;
relacionamentos entre exercícios e os demais catálogos.

A Biblioteca Oficial deve funcionar completamente offline, ser distribuída junto com o aplicativo e ser consultada pelo banco SQLite durante o funcionamento normal do GymControl.

2. Escopo
2.1 Faz parte da Biblioteca Oficial
metadados e versão da Biblioteca;
grupos musculares;
categorias de equipamentos;
equipamentos;
padrões motores;
movimentos;
variações;
níveis de dificuldade;
tags;
aliases;
exercícios oficiais;
músculos principais e secundários de cada exercício;
equipamentos obrigatórios e opcionais de cada exercício;
tags associadas aos exercícios;
nomes alternativos dos exercícios.
2.2 Não faz parte da Biblioteca Oficial
fichas de treino;
ordem de exercícios nas fichas;
séries planejadas;
treinos realizados;
séries executadas;
cargas utilizadas;
repetições realizadas;
histórico;
recordes pessoais;
peso corporal;
medidas corporais;
anexos do usuário;
preferências pessoais;
exercícios personalizados.

Esses dados pertencem aos domínios do usuário e nunca deverão ser sobrescritos por uma atualização da Biblioteca Oficial.

3. Separação de domínios

O GymControl mantém dois universos de dados independentes.

3.1 Biblioteca Oficial

É fornecida junto com o aplicativo.

Características:

somente leitura para o usuário;
distribuída por arquivos JSON;
instalada no SQLite;
atualizável por novas versões do aplicativo;
identificada por códigos permanentes;
validada antes da instalação;
totalmente offline.
3.2 Dados do Usuário

São criados ou gerados pelo uso do aplicativo.

Características:

editáveis pelo usuário;
nunca substituídos por atualização da Biblioteca;
preservados em backup;
responsáveis pelo planejamento, execução e histórico;
podem referenciar exercícios oficiais ou personalizados.
4. Princípios arquiteturais

A Biblioteca Oficial segue os seguintes princípios:

Todo item possui um código permanente.
O código representa a identidade do item e nunca muda.
O nome exibido pode ser corrigido ou traduzido sem alterar o código.
Nenhuma funcionalidade principal depende de internet.
Os JSONs são usados para distribuição, não para consultas normais.
O SQLite é a fonte de consulta durante a execução do aplicativo.
A instalação e a atualização são transacionais.
Uma falha de validação cancela toda a instalação ou atualização.
Dados do usuário nunca são sobrescritos.
Relacionamentos N são representados por estruturas próprias.
A Biblioteca Oficial é imutável para o usuário.
O modelo conceitual pode ser mais rico que a interface inicial.
O histórico do usuário deve continuar legível mesmo após mudanças na Biblioteca.
A modelagem deve permitir crescimento sem exigir reformulação completa.
5. Visão geral
Biblioteca Oficial
│
├── Versionamento
│   └── Metadados da Biblioteca
│
├── Conhecimento
│   ├── Grupos Musculares
│   ├── Categorias de Equipamentos
│   ├── Equipamentos
│   ├── Padrões Motores
│   ├── Movimentos
│   ├── Variações
│   ├── Níveis
│   └── Tags
│
├── Exercícios
│   ├── Dados principais
│   ├── Instruções
│   ├── Dicas
│   └── Erros comuns
│
└── Relacionamentos
    ├── Exercício × Grupo Muscular
    ├── Exercício × Equipamento
    ├── Exercício × Tag
    └── Exercício × Alias
6. Códigos permanentes

Todos os códigos devem ser:

únicos dentro do respectivo catálogo;
imutáveis;
independentes do nome exibido;
sem significado operacional obrigatório;
usados em referências entre arquivos;
preservados em todas as versões futuras.
6.1 Formatos recomendados
BV000001  Biblioteca/versão lógica, quando necessário
GM000001  Grupo muscular
CE000001  Categoria de equipamento
EQ000001  Equipamento
PM000001  Padrão motor
MV000001  Movimento
VR000001  Variação
NV000001  Nível
TG000001  Tag
AL000001  Alias
EX000001  Exercício

O tamanho numérico pode crescer sem alterar o significado.

6.2 Regra de imutabilidade

Depois que um código for publicado:

ele não poderá ser reutilizado;
ele não poderá ser atribuído a outro item;
ele não poderá mudar por correção de nome;
ele poderá ser marcado como inativo, mas não apagado de forma destrutiva.
7. Modelo conceitual
7.1 Grupo muscular

Representa uma região muscular usada para classificar a participação de um exercício.

Exemplos:

Peitoral;
Costas;
Ombros;
Bíceps;
Tríceps;
Antebraços;
Abdômen;
Lombar;
Glúteos;
Quadríceps;
Posteriores da coxa;
Panturrilhas.

Um exercício deve possuir:

exatamente um grupo principal;
zero ou mais grupos secundários.

A participação principal e secundária é definida pelo relacionamento, não pelo exercício.

7.2 Categoria de equipamento

Agrupa equipamentos por natureza ou utilização.

Exemplos:

Peso corporal;
Pesos livres;
Barras;
Máquinas;
Cabos e polias;
Bancos;
Estruturas;
Acessórios.

Uma categoria pode possuir vários equipamentos.

7.3 Equipamento

Representa algo necessário ou opcional para executar um exercício.

Exemplos:

Halter;
Barra reta;
Barra W;
Barra olímpica;
Banco reto;
Banco inclinado;
Polia;
Corda;
Máquina Smith;
Barra fixa;
Faixa elástica.

Um exercício pode exigir vários equipamentos.

O relacionamento define se cada equipamento é:

obrigatório;
opcional.
7.4 Padrão motor

Representa a classificação biomecânica predominante do exercício.

Exemplos:

Empurrar horizontal;
Empurrar vertical;
Puxar horizontal;
Puxar vertical;
Agachar;
Hinge;
Flexão de cotovelo;
Extensão de cotovelo;
Elevação;
Core anti-extensão;
Core anti-rotação.

Cada exercício possui zero ou um padrão motor principal na primeira versão.

7.5 Movimento

Representa a família funcional do exercício.

Exemplos:

Supino;
Crucifixo;
Remada;
Puxada;
Rosca;
Tríceps;
Agachamento;
Levantamento terra;
Elevação lateral.

Um movimento não precisa pertencer exclusivamente a um grupo muscular.

A associação muscular é definida no exercício.

7.6 Variação

Representa uma forma reconhecível de execução.

Exemplos:

Reto;
Inclinado;
Declinado;
Sentado;
Em pé;
Alternado;
Unilateral;
Bilateral;
Pegada pronada;
Pegada supinada;
Pegada neutra.

Uma variação pode ser compartilhada por vários movimentos.

7.7 Nível de dificuldade

Classifica a complexidade técnica predominante.

Valores iniciais:

Iniciante;
Intermediário;
Avançado.

O nível não representa força, carga ou condicionamento do usuário.

7.8 Tag

Complementa filtros e pesquisas sem substituir os relacionamentos estruturais.

Exemplos:

Composto;
Isolado;
Unilateral;
Bilateral;
Casa;
Academia;
Peso corporal;
Estabilidade;
Força;
Hipertrofia.
7.9 Alias

Representa um nome alternativo usado na pesquisa.

Exemplos para Supino Reto com Barra:

Supino barra;
Bench press;
Supino reto;
Barbell bench press.

O alias não cria um novo exercício.

7.10 Exercício

É a entidade central da Biblioteca Oficial.

Um exercício contém seus dados próprios e referencia catálogos por códigos permanentes.

Ele não armazena diretamente:

grupo muscular principal;
grupos secundários;
equipamentos;
tags;
aliases.

Essas informações são representadas pelos relacionamentos.

8. Modelo lógico
8.1 Entidades principais
BibliotecaMetadata
BibliotecaGrupoMuscular
BibliotecaCategoriaEquipamento
BibliotecaEquipamento
BibliotecaPadraoMotor
BibliotecaMovimento
BibliotecaVariacao
BibliotecaNivel
BibliotecaTag
BibliotecaAlias
BibliotecaExercicio
8.2 Relacionamentos
BibliotecaExercicioGrupo
BibliotecaExercicioEquipamento
BibliotecaExercicioTag
BibliotecaExercicioAlias
8.3 Cardinalidades
CategoriaEquipamento 1 ─── N Equipamento

Movimento 1 ─── N Exercício
Variação 1 ─── N Exercício
PadrãoMotor 1 ─── N Exercício
Nível 1 ─── N Exercício

Exercício N ─── N GrupoMuscular
Exercício N ─── N Equipamento
Exercício N ─── N Tag
Exercício N ─── N Alias

Movimento, variação, padrão motor e nível poderão ser opcionais quando o exercício não se encaixar adequadamente em um catálogo.

9. Diagrama entidade-relacionamento
BibliotecaCategoriaEquipamento
              │ 1
              │
              │ N
BibliotecaEquipamento
              ▲
              │ N
              │
BibliotecaExercicioEquipamento
              │
              │ N
              ▼
BibliotecaExercicio
       ▲         ▲          ▲
       │ N       │ N        │ N
       │         │          │
BibliotecaExercicioGrupo
       │         │          │
       │ N       │          │
       ▼         │          │
BibliotecaGrupoMuscular     │
                 │          │
       BibliotecaExercicioTag
                 │ N        │
                 ▼          │
          BibliotecaTag     │
                            │
              BibliotecaExercicioAlias
                            │ N
                            ▼
                     BibliotecaAlias

Referências diretas do exercício:

BibliotecaExercicio
├── movimentoCodigo ─────► BibliotecaMovimento
├── variacaoCodigo ──────► BibliotecaVariacao
├── padraoMotorCodigo ───► BibliotecaPadraoMotor
└── nivelCodigo ─────────► BibliotecaNivel
10. Modelo físico previsto no Drift

Todos os catálogos utilizados nas consultas normais serão persistidos no SQLite.

A aplicação não deverá consultar os JSONs depois da instalação.

10.1 BibliotecaMetadata

Campos previstos:

id;
versao;
dataVersao;
instaladoEm;
atualizadoEm;
hash;
quantidadeGrupos;
quantidadeCategoriasEquipamento;
quantidadeEquipamentos;
quantidadePadroesMotores;
quantidadeMovimentos;
quantidadeVariacoes;
quantidadeNiveis;
quantidadeTags;
quantidadeAliases;
quantidadeExercicios.

Deverá existir no máximo um registro ativo de metadados da Biblioteca instalada.

10.2 Campos comuns dos catálogos

Quando aplicável:

id local;
codigo permanente;
nome;
ordem;
ativo;
criadoEm;
atualizadoEm.
10.3 BibliotecaExercicio

Campos previstos:

id local;
codigo;
nome;
nomeNormalizado;
movimentoCodigo;
variacaoCodigo;
padraoMotorCodigo;
nivelCodigo;
descricao;
instrucoes;
dicas;
errosComuns;
unilateral;
usaPesoCorporal;
usaMaquina;
velocidadeExecucao;
descansoPadraoSegundos;
popularidade;
ativo;
criadoEm;
atualizadoEm.
10.4 BibliotecaExercicioGrupo

Campos previstos:

id local;
exercicioCodigo;
grupoCodigo;
tipoParticipacao;
ordem.

Valores de tipoParticipacao:

principal;
secundario.

Regras:

exatamente um grupo principal por exercício ativo;
nenhum grupo duplicado no mesmo exercício;
um grupo não pode ser simultaneamente principal e secundário.
10.5 BibliotecaExercicioEquipamento

Campos previstos:

id local;
exercicioCodigo;
equipamentoCodigo;
obrigatorio;
ordem.
10.6 BibliotecaExercicioTag

Campos previstos:

id local;
exercicioCodigo;
tagCodigo.
10.7 BibliotecaExercicioAlias

Campos previstos:

id local;
exercicioCodigo;
aliasCodigo.
11. Arquivos oficiais
assets/
└── biblioteca/
    ├── versao.json
    ├── grupos_musculares.json
    ├── categorias_equipamentos.json
    ├── equipamentos.json
    ├── padroes_motores.json
    ├── movimentos.json
    ├── variacoes.json
    ├── niveis.json
    ├── tags.json
    ├── aliases.json
    ├── exercicios.json
    ├── exercicio_grupos.json
    ├── exercicio_equipamentos.json
    ├── exercicio_tags.json
    └── exercicio_aliases.json

Os arquivos antigos que não fizerem parte desta estrutura deverão ser migrados ou removidos antes da instalação completa.

12. Contrato dos arquivos JSON
12.1 versao.json
{
  "versao": 1,
  "data": "2026-07-27",
  "grupos": 12,
  "categoriasEquipamentos": 8,
  "equipamentos": 25,
  "padroesMotores": 12,
  "movimentos": 40,
  "variacoes": 30,
  "niveis": 3,
  "tags": 30,
  "aliases": 100,
  "exercicios": 250
}
12.2 grupos_musculares.json
[
  {
    "codigo": "GM000001",
    "nome": "Peitoral",
    "ordem": 1,
    "ativo": true
  }
]
12.3 categorias_equipamentos.json
[
  {
    "codigo": "CE000001",
    "nome": "Pesos livres",
    "ordem": 1,
    "ativo": true
  }
]
12.4 equipamentos.json
[
  {
    "codigo": "EQ000001",
    "categoriaCodigo": "CE000001",
    "nome": "Halter",
    "ordem": 1,
    "ativo": true
  }
]
12.5 padroes_motores.json
[
  {
    "codigo": "PM000001",
    "nome": "Empurrar horizontal",
    "ordem": 1,
    "ativo": true
  }
]
12.6 movimentos.json
[
  {
    "codigo": "MV000001",
    "nome": "Supino",
    "ordem": 1,
    "ativo": true
  }
]
12.7 variacoes.json
[
  {
    "codigo": "VR000001",
    "nome": "Reto",
    "ordem": 1,
    "ativo": true
  }
]
12.8 niveis.json
[
  {
    "codigo": "NV000001",
    "nome": "Iniciante",
    "ordem": 1,
    "ativo": true
  }
]
12.9 tags.json
[
  {
    "codigo": "TG000001",
    "nome": "Composto",
    "ordem": 1,
    "ativo": true
  }
]
12.10 aliases.json
[
  {
    "codigo": "AL000001",
    "nome": "Bench press",
    "nomeNormalizado": "bench press",
    "ativo": true
  }
]
12.11 exercicios.json
[
  {
    "codigo": "EX000001",
    "nome": "Supino Reto com Barra",
    "nomeNormalizado": "supino reto com barra",
    "movimentoCodigo": "MV000001",
    "variacaoCodigo": "VR000001",
    "padraoMotorCodigo": "PM000001",
    "nivelCodigo": "NV000001",
    "descricao": "Exercício de empurrar horizontal para o peitoral.",
    "instrucoes": [
      "Deite-se no banco com os pés apoiados.",
      "Retire a barra do suporte.",
      "Desça a barra de forma controlada.",
      "Empurre até retornar à posição inicial."
    ],
    "dicas": [
      "Mantenha as escápulas estáveis.",
      "Evite perder o apoio dos pés."
    ],
    "errosComuns": [
      "Abrir excessivamente os cotovelos.",
      "Retirar o quadril do banco."
    ],
    "unilateral": false,
    "usaPesoCorporal": false,
    "usaMaquina": false,
    "velocidadeExecucao": "controlada",
    "descansoPadraoSegundos": 90,
    "popularidade": 100,
    "ativo": true
  }
]
12.12 exercicio_grupos.json
[
  {
    "exercicioCodigo": "EX000001",
    "grupoCodigo": "GM000001",
    "tipoParticipacao": "principal",
    "ordem": 1
  }
]
12.13 exercicio_equipamentos.json
[
  {
    "exercicioCodigo": "EX000001",
    "equipamentoCodigo": "EQ000002",
    "obrigatorio": true,
    "ordem": 1
  }
]
12.14 exercicio_tags.json
[
  {
    "exercicioCodigo": "EX000001",
    "tagCodigo": "TG000001"
  }
]
12.15 exercicio_aliases.json
[
  {
    "exercicioCodigo": "EX000001",
    "aliasCodigo": "AL000001"
  }
]
13. Normalização de textos

Campos de pesquisa poderão possuir uma versão normalizada.

Exemplo:

Nome exibido: Supino Reto com Barra
Nome normalizado: supino reto com barra

A normalização poderá:

converter para minúsculas;
remover acentos;
reduzir espaços repetidos;
remover espaços no início e no fim.

A versão exibida deve preservar a grafia correta em português do Brasil.

14. Fluxo de instalação
Assets JSON
    ↓
BibliotecaLoader
    ↓
Modelos Dart
    ↓
BibliotecaValidator
    ↓
BibliotecaInstaller
    ↓
Transação Drift
    ↓
SQLite
    ↓
BibliotecaService
    ↓
Interface
14.1 Primeira instalação
Abrir o banco.
Verificar se há metadados da Biblioteca.
Carregar versao.json.
Carregar todos os catálogos.
Converter os JSONs em modelos Dart.
Validar arquivos, códigos e referências.
Iniciar uma transação.
Inserir catálogos.
Inserir exercícios.
Inserir relacionamentos.
Registrar os metadados.
Confirmar a transação.

A Biblioteca só é considerada instalada depois da confirmação da transação.

15. Fluxo de atualização
Ler a versão instalada no banco.
Ler a versão presente nos assets.
Comparar as versões.
Não fazer nada quando forem iguais e a integridade estiver válida.
Validar completamente a nova Biblioteca.
Iniciar uma transação.
Inserir ou atualizar itens oficiais pelo código permanente.
Marcar como inativos os itens oficiais removidos da distribuição.
Atualizar relacionamentos oficiais.
Preservar todos os dados do usuário.
Atualizar os metadados.
Confirmar a transação.

Uma atualização não deve apagar fisicamente registros já referenciados por históricos.

16. Estratégia de exclusão

A Biblioteca Oficial usará inativação lógica.

Itens removidos de uma versão futura:

permanecem no banco;
recebem ativo = false;
não aparecem em novas pesquisas comuns;
continuam disponíveis para referências históricas;
não têm seus códigos reutilizados.
17. Integridade e validação

Antes de instalar ou atualizar, deverão ser verificadas pelo menos as seguintes regras.

17.1 Arquivos
todos os arquivos obrigatórios existem;
todos contêm JSON válido;
as raízes possuem o tipo esperado;
os textos usam UTF-8;
os campos obrigatórios estão presentes.
17.2 Códigos
nenhum código é vazio;
os códigos seguem o prefixo do catálogo;
não há códigos duplicados;
nenhum código publicado é reutilizado.
17.3 Referências
toda categoria de equipamento referenciada existe;
todo movimento referenciado existe;
toda variação referenciada existe;
todo padrão motor referenciado existe;
todo nível referenciado existe;
todo grupo relacionado existe;
todo equipamento relacionado existe;
toda tag relacionada existe;
todo alias relacionado existe;
todo exercício relacionado existe.
17.4 Exercícios
todo exercício possui nome;
todo exercício ativo possui exatamente um grupo principal;
grupos secundários não se repetem;
equipamentos não se repetem;
tags não se repetem;
aliases não se repetem;
descanso padrão não é negativo;
popularidade não é negativa.
17.5 Quantidades

As quantidades reais devem corresponder aos valores declarados em versao.json.

18. Transações

Toda instalação ou atualização deve ocorrer dentro de uma única transação Drift.

Em caso de erro:

nenhuma alteração parcial é preservada;
a versão instalada anterior continua válida;
o erro pode ser apresentado ao usuário ou registrado localmente;
o aplicativo não deve marcar a nova versão como instalada.
19. Hash e integridade

A Biblioteca poderá possuir um hash global ou hashes por arquivo.

Objetivos:

detectar arquivos alterados;
verificar consistência;
ajudar em diagnósticos;
evitar considerar instalada uma Biblioteca incompleta.

A implementação inicial poderá começar sem hash obrigatório, desde que o modelo físico esteja preparado para incluí-lo.

20. Pesquisa

A pesquisa deverá considerar:

nome oficial;
nome normalizado;
aliases;
grupo muscular;
equipamento;
movimento;
padrão motor;
tags;
popularidade;
estado ativo.

Resultados oficiais e personalizados poderão ser exibidos juntos, mas devem preservar a indicação de origem.

21. Exercícios personalizados

Exercícios personalizados pertencem ao usuário e não à Biblioteca Oficial.

Eles devem:

coexistir com exercícios oficiais;
possuir identidade local;
poder usar grupos musculares existentes;
poder usar equipamentos e classificações oficiais;
nunca ser alterados pelo instalador da Biblioteca;
permanecer válidos em backups e restaurações.

A possibilidade de criar catálogos personalizados além de exercícios poderá ser avaliada em uma evolução futura.

22. Relação com dados históricos

O histórico não deve depender apenas de nomes atuais da Biblioteca.

Quando um exercício for utilizado em uma ficha ou treino realizado, a modelagem dos domínios de planejamento e execução deverá preservar informações suficientes para apresentar o registro no futuro.

A estratégia poderá combinar:

referência ao código permanente;
snapshot do nome no momento do uso;
snapshots de dados planejados ou realizados.

Essa decisão será detalhada na arquitetura dos domínios de Fichas e Treinos.

23. Compatibilidade entre versões

Uma nova versão da Biblioteca deve:

manter os códigos existentes;
adicionar novos códigos quando necessário;
corrigir nomes sem trocar códigos;
inativar itens obsoletos;
preservar referências históricas;
não depender de conexão com internet;
poder ser instalada sobre uma versão anterior.

Mudanças incompatíveis exigirão uma decisão arquitetural específica e uma migração explícita.

24. Responsabilidades das classes
24.1 BibliotecaLoader

Responsável por:

ler arquivos dos assets;
devolver texto ou estruturas decodificadas;
não acessar o banco;
não aplicar regras de negócio.
24.2 Modelos da Biblioteca

Responsáveis por:

representar os contratos JSON;
converter de e para JSON;
não acessar o banco;
não conter regras de instalação.
24.3 BibliotecaValidator

Responsável por:

validar estrutura;
validar códigos;
validar referências;
validar contagens;
impedir instalação inconsistente.
24.4 BibliotecaInstaller

Responsável por:

coordenar gravações;
usar transação;
inserir ou atualizar registros;
inativar registros oficiais ausentes;
registrar metadados;
não permitir instalação parcial.
24.5 BibliotecaService

Responsável por:

decidir se a instalação ou atualização é necessária;
coordenar Loader, Validator e Installer;
disponibilizar estado da Biblioteca para a aplicação.
25. Organização prevista no código
lib/
└── core/
    └── biblioteca/
        ├── installer/
        ├── loader/
        ├── models/
        │   ├── aliases/
        │   ├── categorias_equipamentos/
        │   ├── equipamentos/
        │   ├── exercicios/
        │   ├── grupos/
        │   ├── movimentos/
        │   ├── niveis/
        │   ├── padroes/
        │   ├── relacionamentos/
        │   ├── tags/
        │   ├── variacoes/
        │   └── versao/
        ├── services/
        └── validators/

A estrutura poderá ser refinada quando a quantidade de arquivos justificar, sem alterar as responsabilidades.

26. Decisões arquiteturais
DA-001 — Biblioteca Oficial separada dos dados do usuário

Atualizações da Biblioteca não podem alterar fichas, treinos, histórico, peso ou medidas do usuário.

DA-002 — Distribuição por JSON

Os dados oficiais são distribuídos nos assets do aplicativo.

DA-003 — Consulta pelo SQLite

Após a instalação, a aplicação consulta exclusivamente o banco local.

DA-004 — Códigos permanentes

Toda identidade oficial é representada por um código imutável.

DA-005 — Persistência dos catálogos

Todos os catálogos usados em pesquisas e relacionamentos serão persistidos.

DA-006 — Relacionamentos próprios

Relações N não serão armazenadas como listas aninhadas na tabela principal.

DA-007 — Inativação em vez de exclusão

Registros publicados não serão apagados de forma destrutiva.

DA-008 — Instalação transacional

Nenhuma instalação ou atualização parcial é aceita.

DA-009 — Exercícios personalizados independentes

O instalador oficial nunca altera exercícios criados pelo usuário.

DA-010 — Grupo muscular definido por relacionamento

O exercício não possui um campo direto de grupo muscular.

DA-011 — Equipamento definido por relacionamento

O exercício pode exigir nenhum, um ou vários equipamentos.

DA-012 — Categoria de equipamento como entidade

Equipamentos são organizados em categorias oficiais reutilizáveis.

DA-013 — Nível como catálogo

O nível não será armazenado como texto livre.

DA-014 — Biblioteca imutável para o usuário

Itens oficiais não poderão ser editados diretamente pela interface.

DA-015 — Histórico preservado

A evolução da Biblioteca não pode tornar registros antigos ilegíveis.

27. Evoluções futuras

A arquitetura permite acrescentar futuramente:

traduções;
imagens;
vídeos;
animações;
instruções por etapa;
contraindicações informativas;
músculos com estimativa de participação;
exercícios equivalentes;
substituições por equipamento disponível;
favoritos;
avaliação de exercícios;
recomendações;
download opcional de mídias;
bibliotecas adicionais;
importação de pacotes;
atualização remota opcional, sem retirar o funcionamento offline.

Essas evoluções não fazem parte da primeira implementação.

28. Checklist de conformidade

Antes de publicar uma versão:

versao.json foi atualizado.

Todos os arquivos obrigatórios existem.

Todos os JSONs são válidos.

Todos os códigos são únicos.

Todos os prefixos são válidos.

Todas as referências existem.

As contagens conferem.

Todo exercício ativo possui um grupo principal.

Não existem relacionamentos duplicados.

Não existem códigos reutilizados.

Itens removidos foram inativados.

Exercícios personalizados não são afetados.

A instalação ocorre em transação.

O flutter analyze não apresenta problemas.

Os testes da Biblioteca foram aprovados.

29. Glossário
Biblioteca Oficial

Conjunto de conhecimento distribuído pelo aplicativo e instalado localmente.

Catálogo

Conjunto oficial reutilizável, como grupos, equipamentos ou tags.

Exercício Oficial

Exercício fornecido pela Biblioteca Oficial.

Exercício Personalizado

Exercício criado pelo usuário.

Código permanente

Identificador oficial imutável.

Grupo principal

Grupo muscular predominante do exercício.

Grupo secundário

Grupo muscular auxiliar ou relevante.

Movimento

Família funcional do exercício.

Variação

Forma específica de execução.

Padrão motor

Classificação biomecânica predominante.

Equipamento obrigatório

Item necessário para a execução prevista.

Equipamento opcional

Item que pode auxiliar ou representar uma alternativa.

Alias

Nome alternativo usado em pesquisas.

Tag

Classificação complementar para filtros e organização.

Installer

Componente responsável pela persistência da Biblioteca.

Validator

Componente responsável por impedir a instalação de dados inconsistentes.

30. Encerramento

Este documento é a fonte oficial para a implementação da Biblioteca Oficial do GymControl.

A partir da versão 2.0:

os catálogos serão persistidos;
os relacionamentos serão normalizados;
os códigos serão permanentes;
os JSONs serão usados apenas para distribuição;
o SQLite será usado para consultas;
as atualizações preservarão os dados do usuário;
a implementação deverá seguir as decisões arquiteturais registradas.

Qualquer mudança estrutural futura deverá atualizar este documento e registrar uma nova decisão arquitetural.

Biblioteca
/
ArquiteturaBiblioteca_v2.md
Arquitetura da Biblioteca Oficial

Projeto: GymControl
Versão do documento: 2.0
Status: Aprovado para implementação
Última atualização: 2026-07-27

1. Objetivo

A Biblioteca Oficial é o domínio responsável por armazenar, organizar, validar, versionar e disponibilizar o conhecimento de musculação utilizado pelo GymControl.

Ela reúne informações independentes do usuário, como:

grupos musculares;
categorias de equipamentos;
equipamentos;
padrões motores;
movimentos;
variações;
níveis de dificuldade;
tags;
aliases;
exercícios;
relacionamentos entre exercícios e os demais catálogos.

A Biblioteca Oficial deve funcionar completamente offline, ser distribuída junto com o aplicativo e ser consultada pelo banco SQLite durante o funcionamento normal do GymControl.

2. Escopo
2.1 Faz parte da Biblioteca Oficial
metadados e versão da Biblioteca;
grupos musculares;
categorias de equipamentos;
equipamentos;
padrões motores;
movimentos;
variações;
níveis de dificuldade;
tags;
aliases;
exercícios oficiais;
músculos principais e secundários de cada exercício;
equipamentos obrigatórios e opcionais de cada exercício;
tags associadas aos exercícios;
nomes alternativos dos exercícios.
2.2 Não faz parte da Biblioteca Oficial
fichas de treino;
ordem de exercícios nas fichas;
séries planejadas;
treinos realizados;
séries executadas;
cargas utilizadas;
repetições realizadas;
histórico;
recordes pessoais;
peso corporal;
medidas corporais;
anexos do usuário;
preferências pessoais;
exercícios personalizados.

Esses dados pertencem aos domínios do usuário e nunca deverão ser sobrescritos por uma atualização da Biblioteca Oficial.

3. Separação de domínios

O GymControl mantém dois universos de dados independentes.

3.1 Biblioteca Oficial

É fornecida junto com o aplicativo.

Características:

somente leitura para o usuário;
distribuída por arquivos JSON;
instalada no SQLite;
atualizável por novas versões do aplicativo;
identificada por códigos permanentes;
validada antes da instalação;
totalmente offline.
3.2 Dados do Usuário

São criados ou gerados pelo uso do aplicativo.

Características:

editáveis pelo usuário;
nunca substituídos por atualização da Biblioteca;
preservados em backup;
responsáveis pelo planejamento, execução e histórico;
podem referenciar exercícios oficiais ou personalizados.
4. Princípios arquiteturais

A Biblioteca Oficial segue os seguintes princípios:

Todo item possui um código permanente.
O código representa a identidade do item e nunca muda.
O nome exibido pode ser corrigido ou traduzido sem alterar o código.
Nenhuma funcionalidade principal depende de internet.
Os JSONs são usados para distribuição, não para consultas normais.
O SQLite é a fonte de consulta durante a execução do aplicativo.
A instalação e a atualização são transacionais.
Uma falha de validação cancela toda a instalação ou atualização.
Dados do usuário nunca são sobrescritos.
Relacionamentos N são representados por estruturas próprias.
A Biblioteca Oficial é imutável para o usuário.
O modelo conceitual pode ser mais rico que a interface inicial.
O histórico do usuário deve continuar legível mesmo após mudanças na Biblioteca.
A modelagem deve permitir crescimento sem exigir reformulação completa.
5. Visão geral
Biblioteca Oficial
│
├── Versionamento
│   └── Metadados da Biblioteca
│
├── Conhecimento
│   ├── Grupos Musculares
│   ├── Categorias de Equipamentos
│   ├── Equipamentos
│   ├── Padrões Motores
│   ├── Movimentos
│   ├── Variações
│   ├── Níveis
│   └── Tags
│
├── Exercícios
│   ├── Dados principais
│   ├── Instruções
│   ├── Dicas
│   └── Erros comuns
│
└── Relacionamentos
    ├── Exercício × Grupo Muscular
    ├── Exercício × Equipamento
    ├── Exercício × Tag
    └── Exercício × Alias
6. Códigos permanentes

Todos os códigos devem ser:

únicos dentro do respectivo catálogo;
imutáveis;
independentes do nome exibido;
sem significado operacional obrigatório;
usados em referências entre arquivos;
preservados em todas as versões futuras.
6.1 Formatos recomendados
BV000001  Biblioteca/versão lógica, quando necessário
GM000001  Grupo muscular
CE000001  Categoria de equipamento
EQ000001  Equipamento
PM000001  Padrão motor
MV000001  Movimento
VR000001  Variação
NV000001  Nível
TG000001  Tag
AL000001  Alias
EX000001  Exercício

O tamanho numérico pode crescer sem alterar o significado.

6.2 Regra de imutabilidade

Depois que um código for publicado:

ele não poderá ser reutilizado;
ele não poderá ser atribuído a outro item;
ele não poderá mudar por correção de nome;
ele poderá ser marcado como inativo, mas não apagado de forma destrutiva.
7. Modelo conceitual
7.1 Grupo muscular

Representa uma região muscular usada para classificar a participação de um exercício.

Exemplos:

Peitoral;
Costas;
Ombros;
Bíceps;
Tríceps;
Antebraços;
Abdômen;
Lombar;
Glúteos;
Quadríceps;
Posteriores da coxa;
Panturrilhas.

Um exercício deve possuir:

exatamente um grupo principal;
zero ou mais grupos secundários.

A participação principal e secundária é definida pelo relacionamento, não pelo exercício.

7.2 Categoria de equipamento

Agrupa equipamentos por natureza ou utilização.

Exemplos:

Peso corporal;
Pesos livres;
Barras;
Máquinas;
Cabos e polias;
Bancos;
Estruturas;
Acessórios.

Uma categoria pode possuir vários equipamentos.

7.3 Equipamento

Representa algo necessário ou opcional para executar um exercício.

Exemplos:

Halter;
Barra reta;
Barra W;
Barra olímpica;
Banco reto;
Banco inclinado;
Polia;
Corda;
Máquina Smith;
Barra fixa;
Faixa elástica.

Um exercício pode exigir vários equipamentos.

O relacionamento define se cada equipamento é:

obrigatório;
opcional.
7.4 Padrão motor

Representa a classificação biomecânica predominante do exercício.

Exemplos:

Empurrar horizontal;
Empurrar vertical;
Puxar horizontal;
Puxar vertical;
Agachar;
Hinge;
Flexão de cotovelo;
Extensão de cotovelo;
Elevação;
Core anti-extensão;
Core anti-rotação.

Cada exercício possui zero ou um padrão motor principal na primeira versão.

7.5 Movimento

Representa a família funcional do exercício.

Exemplos:

Supino;
Crucifixo;
Remada;
Puxada;
Rosca;
Tríceps;
Agachamento;
Levantamento terra;
Elevação lateral.

Um movimento não precisa pertencer exclusivamente a um grupo muscular.

A associação muscular é definida no exercício.

7.6 Variação

Representa uma forma reconhecível de execução.

Exemplos:

Reto;
Inclinado;
Declinado;
Sentado;
Em pé;
Alternado;
Unilateral;
Bilateral;
Pegada pronada;
Pegada supinada;
Pegada neutra.

Uma variação pode ser compartilhada por vários movimentos.

7.7 Nível de dificuldade

Classifica a complexidade técnica predominante.

Valores iniciais:

Iniciante;
Intermediário;
Avançado.

O nível não representa força, carga ou condicionamento do usuário.

7.8 Tag

Complementa filtros e pesquisas sem substituir os relacionamentos estruturais.

Exemplos:

Composto;
Isolado;
Unilateral;
Bilateral;
Casa;
Academia;
Peso corporal;
Estabilidade;
Força;
Hipertrofia.
7.9 Alias

Representa um nome alternativo usado na pesquisa.

Exemplos para Supino Reto com Barra:

Supino barra;
Bench press;
Supino reto;
Barbell bench press.

O alias não cria um novo exercício.

7.10 Exercício

É a entidade central da Biblioteca Oficial.

Um exercício contém seus dados próprios e referencia catálogos por códigos permanentes.

Ele não armazena diretamente:

grupo muscular principal;
grupos secundários;
equipamentos;
tags;
aliases.

Essas informações são representadas pelos relacionamentos.

8. Modelo lógico
8.1 Entidades principais
BibliotecaMetadata
BibliotecaGrupoMuscular
BibliotecaCategoriaEquipamento
BibliotecaEquipamento
BibliotecaPadraoMotor
BibliotecaMovimento
BibliotecaVariacao
BibliotecaNivel
BibliotecaTag
BibliotecaAlias
BibliotecaExercicio
8.2 Relacionamentos
BibliotecaExercicioGrupo
BibliotecaExercicioEquipamento
BibliotecaExercicioTag
BibliotecaExercicioAlias
8.3 Cardinalidades
CategoriaEquipamento 1 ─── N Equipamento

Movimento 1 ─── N Exercício
Variação 1 ─── N Exercício
PadrãoMotor 1 ─── N Exercício
Nível 1 ─── N Exercício

Exercício N ─── N GrupoMuscular
Exercício N ─── N Equipamento
Exercício N ─── N Tag
Exercício N ─── N Alias

Movimento, variação, padrão motor e nível poderão ser opcionais quando o exercício não se encaixar adequadamente em um catálogo.

9. Diagrama entidade-relacionamento
BibliotecaCategoriaEquipamento
              │ 1
              │
              │ N
BibliotecaEquipamento
              ▲
              │ N
              │
BibliotecaExercicioEquipamento
              │
              │ N
              ▼
BibliotecaExercicio
       ▲         ▲          ▲
       │ N       │ N        │ N
       │         │          │
BibliotecaExercicioGrupo
       │         │          │
       │ N       │          │
       ▼         │          │
BibliotecaGrupoMuscular     │
                 │          │
       BibliotecaExercicioTag
                 │ N        │
                 ▼          │
          BibliotecaTag     │
                            │
              BibliotecaExercicioAlias
                            │ N
                            ▼
                     BibliotecaAlias

Referências diretas do exercício:

BibliotecaExercicio
├── movimentoCodigo ─────► BibliotecaMovimento
├── variacaoCodigo ──────► BibliotecaVariacao
├── padraoMotorCodigo ───► BibliotecaPadraoMotor
└── nivelCodigo ─────────► BibliotecaNivel
10. Modelo físico previsto no Drift

Todos os catálogos utilizados nas consultas normais serão persistidos no SQLite.

A aplicação não deverá consultar os JSONs depois da instalação.

10.1 BibliotecaMetadata

Campos previstos:

id;
versao;
dataVersao;
instaladoEm;
atualizadoEm;
hash;
quantidadeGrupos;
quantidadeCategoriasEquipamento;
quantidadeEquipamentos;
quantidadePadroesMotores;
quantidadeMovimentos;
quantidadeVariacoes;
quantidadeNiveis;
quantidadeTags;
quantidadeAliases;
quantidadeExercicios.

Deverá existir no máximo um registro ativo de metadados da Biblioteca instalada.

10.2 Campos comuns dos catálogos

Quando aplicável:

id local;
codigo permanente;
nome;
ordem;
ativo;
criadoEm;
atualizadoEm.
10.3 BibliotecaExercicio

Campos previstos:

id local;
codigo;
nome;
nomeNormalizado;
movimentoCodigo;
variacaoCodigo;
padraoMotorCodigo;
nivelCodigo;
descricao;
instrucoes;
dicas;
errosComuns;
unilateral;
usaPesoCorporal;
usaMaquina;
velocidadeExecucao;
descansoPadraoSegundos;
popularidade;
ativo;
criadoEm;
atualizadoEm.
10.4 BibliotecaExercicioGrupo

Campos previstos:

id local;
exercicioCodigo;
grupoCodigo;
tipoParticipacao;
ordem.

Valores de tipoParticipacao:

principal;
secundario.

Regras:

exatamente um grupo principal por exercício ativo;
nenhum grupo duplicado no mesmo exercício;
um grupo não pode ser simultaneamente principal e secundário.
10.5 BibliotecaExercicioEquipamento

Campos previstos:

id local;
exercicioCodigo;
equipamentoCodigo;
obrigatorio;
ordem.
10.6 BibliotecaExercicioTag

Campos previstos:

id local;
exercicioCodigo;
tagCodigo.
10.7 BibliotecaExercicioAlias

Campos previstos:

id local;
exercicioCodigo;
aliasCodigo.
11. Arquivos oficiais
assets/
└── biblioteca/
    ├── versao.json
    ├── grupos_musculares.json
    ├── categorias_equipamentos.json
    ├── equipamentos.json
    ├── padroes_motores.json
    ├── movimentos.json
    ├── variacoes.json
    ├── niveis.json
    ├── tags.json
    ├── aliases.json
    ├── exercicios.json
    ├── exercicio_grupos.json
    ├── exercicio_equipamentos.json
    ├── exercicio_tags.json
    └── exercicio_aliases.json

Os arquivos antigos que não fizerem parte desta estrutura deverão ser migrados ou removidos antes da instalação completa.

12. Contrato dos arquivos JSON
12.1 versao.json
{
  "versao": 1,
  "data": "2026-07-27",
  "grupos": 12,
  "categoriasEquipamentos": 8,
  "equipamentos": 25,
  "padroesMotores": 12,
  "movimentos": 40,
  "variacoes": 30,
  "niveis": 3,
  "tags": 30,
  "aliases": 100,
  "exercicios": 250
}
12.2 grupos_musculares.json
[
  {
    "codigo": "GM000001",
    "nome": "Peitoral",
    "ordem": 1,
    "ativo": true
  }
]
12.3 categorias_equipamentos.json
[
  {
    "codigo": "CE000001",
    "nome": "Pesos livres",
    "ordem": 1,
    "ativo": true
  }
]
12.4 equipamentos.json
[
  {
    "codigo": "EQ000001",
    "categoriaCodigo": "CE000001",
    "nome": "Halter",
    "ordem": 1,
    "ativo": true
  }
]
12.5 padroes_motores.json
[
  {
    "codigo": "PM000001",
    "nome": "Empurrar horizontal",
    "ordem": 1,
    "ativo": true
  }
]
12.6 movimentos.json
[
  {
    "codigo": "MV000001",
    "nome": "Supino",
    "ordem": 1,
    "ativo": true
  }
]
12.7 variacoes.json
[
  {
    "codigo": "VR000001",
    "nome": "Reto",
    "ordem": 1,
    "ativo": true
  }
]
12.8 niveis.json
[
  {
    "codigo": "NV000001",
    "nome": "Iniciante",
    "ordem": 1,
    "ativo": true
  }
]
12.9 tags.json
[
  {
    "codigo": "TG000001",
    "nome": "Composto",
    "ordem": 1,
    "ativo": true
  }
]
12.10 aliases.json
[
  {
    "codigo": "AL000001",
    "nome": "Bench press",
    "nomeNormalizado": "bench press",
    "ativo": true
  }
]
12.11 exercicios.json
[
  {
    "codigo": "EX000001",
    "nome": "Supino Reto com Barra",
    "nomeNormalizado": "supino reto com barra",
    "movimentoCodigo": "MV000001",
    "variacaoCodigo": "VR000001",
    "padraoMotorCodigo": "PM000001",
    "nivelCodigo": "NV000001",
    "descricao": "Exercício de empurrar horizontal para o peitoral.",
    "instrucoes": [
      "Deite-se no banco com os pés apoiados.",
      "Retire a barra do suporte.",
      "Desça a barra de forma controlada.",
      "Empurre até retornar à posição inicial."
    ],
    "dicas": [
      "Mantenha as escápulas estáveis.",
      "Evite perder o apoio dos pés."
    ],
    "errosComuns": [
      "Abrir excessivamente os cotovelos.",
      "Retirar o quadril do banco."
    ],
    "unilateral": false,
    "usaPesoCorporal": false,
    "usaMaquina": false,
    "velocidadeExecucao": "controlada",
    "descansoPadraoSegundos": 90,
    "popularidade": 100,
    "ativo": true
  }
]
12.12 exercicio_grupos.json
[
  {
    "exercicioCodigo": "EX000001",
    "grupoCodigo": "GM000001",
    "tipoParticipacao": "principal",
    "ordem": 1
  }
]
12.13 exercicio_equipamentos.json
[
  {
    "exercicioCodigo": "EX000001",
    "equipamentoCodigo": "EQ000002",
    "obrigatorio": true,
    "ordem": 1
  }
]
12.14 exercicio_tags.json
[
  {
    "exercicioCodigo": "EX000001",
    "tagCodigo": "TG000001"
  }
]
12.15 exercicio_aliases.json
[
  {
    "exercicioCodigo": "EX000001",
    "aliasCodigo": "AL000001"
  }
]
13. Normalização de textos

Campos de pesquisa poderão possuir uma versão normalizada.

Exemplo:

Nome exibido: Supino Reto com Barra
Nome normalizado: supino reto com barra

A normalização poderá:

converter para minúsculas;
remover acentos;
reduzir espaços repetidos;
remover espaços no início e no fim.

A versão exibida deve preservar a grafia correta em português do Brasil.

14. Fluxo de instalação
Assets JSON
    ↓
BibliotecaLoader
    ↓
Modelos Dart
    ↓
BibliotecaValidator
    ↓
BibliotecaInstaller
    ↓
Transação Drift
    ↓
SQLite
    ↓
BibliotecaService
    ↓
Interface
14.1 Primeira instalação
Abrir o banco.
Verificar se há metadados da Biblioteca.
Carregar versao.json.
Carregar todos os catálogos.
Converter os JSONs em modelos Dart.
Validar arquivos, códigos e referências.
Iniciar uma transação.
Inserir catálogos.
Inserir exercícios.
Inserir relacionamentos.
Registrar os metadados.
Confirmar a transação.

A Biblioteca só é considerada instalada depois da confirmação da transação.

15. Fluxo de atualização
Ler a versão instalada no banco.
Ler a versão presente nos assets.
Comparar as versões.
Não fazer nada quando forem iguais e a integridade estiver válida.
Validar completamente a nova Biblioteca.
Iniciar uma transação.
Inserir ou atualizar itens oficiais pelo código permanente.
Marcar como inativos os itens oficiais removidos da distribuição.
Atualizar relacionamentos oficiais.
Preservar todos os dados do usuário.
Atualizar os metadados.
Confirmar a transação.

Uma atualização não deve apagar fisicamente registros já referenciados por históricos.

16. Estratégia de exclusão

A Biblioteca Oficial usará inativação lógica.

Itens removidos de uma versão futura:

permanecem no banco;
recebem ativo = false;
não aparecem em novas pesquisas comuns;
continuam disponíveis para referências históricas;
não têm seus códigos reutilizados.
17. Integridade e validação

Antes de instalar ou atualizar, deverão ser verificadas pelo menos as seguintes regras.

17.1 Arquivos
todos os arquivos obrigatórios existem;
todos contêm JSON válido;
as raízes possuem o tipo esperado;
os textos usam UTF-8;
os campos obrigatórios estão presentes.
17.2 Códigos
nenhum código é vazio;
os códigos seguem o prefixo do catálogo;
não há códigos duplicados;
nenhum código publicado é reutilizado.
17.3 Referências
toda categoria de equipamento referenciada existe;
todo movimento referenciado existe;
toda variação referenciada existe;
todo padrão motor referenciado existe;
todo nível referenciado existe;
todo grupo relacionado existe;
todo equipamento relacionado existe;
toda tag relacionada existe;
todo alias relacionado existe;
todo exercício relacionado existe.
17.4 Exercícios
todo exercício possui nome;
todo exercício ativo possui exatamente um grupo principal;
grupos secundários não se repetem;
equipamentos não se repetem;
tags não se repetem;
aliases não se repetem;
descanso padrão não é negativo;
popularidade não é negativa.
17.5 Quantidades

As quantidades reais devem corresponder aos valores declarados em versao.json.

18. Transações

Toda instalação ou atualização deve ocorrer dentro de uma única transação Drift.

Em caso de erro:

nenhuma alteração parcial é preservada;
a versão instalada anterior continua válida;
o erro pode ser apresentado ao usuário ou registrado localmente;
o aplicativo não deve marcar a nova versão como instalada.
19. Hash e integridade

A Biblioteca poderá possuir um hash global ou hashes por arquivo.

Objetivos:

detectar arquivos alterados;
verificar consistência;
ajudar em diagnósticos;
evitar considerar instalada uma Biblioteca incompleta.

A implementação inicial poderá começar sem hash obrigatório, desde que o modelo físico esteja preparado para incluí-lo.

20. Pesquisa

A pesquisa deverá considerar:

nome oficial;
nome normalizado;
aliases;
grupo muscular;
equipamento;
movimento;
padrão motor;
tags;
popularidade;
estado ativo.

Resultados oficiais e personalizados poderão ser exibidos juntos, mas devem preservar a indicação de origem.

21. Exercícios personalizados

Exercícios personalizados pertencem ao usuário e não à Biblioteca Oficial.

Eles devem:

coexistir com exercícios oficiais;
possuir identidade local;
poder usar grupos musculares existentes;
poder usar equipamentos e classificações oficiais;
nunca ser alterados pelo instalador da Biblioteca;
permanecer válidos em backups e restaurações.

A possibilidade de criar catálogos personalizados além de exercícios poderá ser avaliada em uma evolução futura.

22. Relação com dados históricos

O histórico não deve depender apenas de nomes atuais da Biblioteca.

Quando um exercício for utilizado em uma ficha ou treino realizado, a modelagem dos domínios de planejamento e execução deverá preservar informações suficientes para apresentar o registro no futuro.

A estratégia poderá combinar:

referência ao código permanente;
snapshot do nome no momento do uso;
snapshots de dados planejados ou realizados.

Essa decisão será detalhada na arquitetura dos domínios de Fichas e Treinos.

23. Compatibilidade entre versões

Uma nova versão da Biblioteca deve:

manter os códigos existentes;
adicionar novos códigos quando necessário;
corrigir nomes sem trocar códigos;
inativar itens obsoletos;
preservar referências históricas;
não depender de conexão com internet;
poder ser instalada sobre uma versão anterior.

Mudanças incompatíveis exigirão uma decisão arquitetural específica e uma migração explícita.

24. Responsabilidades das classes
24.1 BibliotecaLoader

Responsável por:

ler arquivos dos assets;
devolver texto ou estruturas decodificadas;
não acessar o banco;
não aplicar regras de negócio.
24.2 Modelos da Biblioteca

Responsáveis por:

representar os contratos JSON;
converter de e para JSON;
não acessar o banco;
não conter regras de instalação.
24.3 BibliotecaValidator

Responsável por:

validar estrutura;
validar códigos;
validar referências;
validar contagens;
impedir instalação inconsistente.
24.4 BibliotecaInstaller

Responsável por:

coordenar gravações;
usar transação;
inserir ou atualizar registros;
inativar registros oficiais ausentes;
registrar metadados;
não permitir instalação parcial.
24.5 BibliotecaService

Responsável por:

decidir se a instalação ou atualização é necessária;
coordenar Loader, Validator e Installer;
disponibilizar estado da Biblioteca para a aplicação.
25. Organização prevista no código
lib/
└── core/
    └── biblioteca/
        ├── installer/
        ├── loader/
        ├── models/
        │   ├── aliases/
        │   ├── categorias_equipamentos/
        │   ├── equipamentos/
        │   ├── exercicios/
        │   ├── grupos/
        │   ├── movimentos/
        │   ├── niveis/
        │   ├── padroes/
        │   ├── relacionamentos/
        │   ├── tags/
        │   ├── variacoes/
        │   └── versao/
        ├── services/
        └── validators/

A estrutura poderá ser refinada quando a quantidade de arquivos justificar, sem alterar as responsabilidades.

26. Decisões arquiteturais
DA-001 — Biblioteca Oficial separada dos dados do usuário

Atualizações da Biblioteca não podem alterar fichas, treinos, histórico, peso ou medidas do usuário.

DA-002 — Distribuição por JSON

Os dados oficiais são distribuídos nos assets do aplicativo.

DA-003 — Consulta pelo SQLite

Após a instalação, a aplicação consulta exclusivamente o banco local.

DA-004 — Códigos permanentes

Toda identidade oficial é representada por um código imutável.

DA-005 — Persistência dos catálogos

Todos os catálogos usados em pesquisas e relacionamentos serão persistidos.

DA-006 — Relacionamentos próprios

Relações N não serão armazenadas como listas aninhadas na tabela principal.

DA-007 — Inativação em vez de exclusão

Registros publicados não serão apagados de forma destrutiva.

DA-008 — Instalação transacional

Nenhuma instalação ou atualização parcial é aceita.

DA-009 — Exercícios personalizados independentes

O instalador oficial nunca altera exercícios criados pelo usuário.

DA-010 — Grupo muscular definido por relacionamento

O exercício não possui um campo direto de grupo muscular.

DA-011 — Equipamento definido por relacionamento

O exercício pode exigir nenhum, um ou vários equipamentos.

DA-012 — Categoria de equipamento como entidade

Equipamentos são organizados em categorias oficiais reutilizáveis.

DA-013 — Nível como catálogo

O nível não será armazenado como texto livre.

DA-014 — Biblioteca imutável para o usuário

Itens oficiais não poderão ser editados diretamente pela interface.

DA-015 — Histórico preservado

A evolução da Biblioteca não pode tornar registros antigos ilegíveis.

27. Evoluções futuras

A arquitetura permite acrescentar futuramente:

traduções;
imagens;
vídeos;
animações;
instruções por etapa;
contraindicações informativas;
músculos com estimativa de participação;
exercícios equivalentes;
substituições por equipamento disponível;
favoritos;
avaliação de exercícios;
recomendações;
download opcional de mídias;
bibliotecas adicionais;
importação de pacotes;
atualização remota opcional, sem retirar o funcionamento offline.

Essas evoluções não fazem parte da primeira implementação.

28. Checklist de conformidade

Antes de publicar uma versão:

versao.json foi atualizado.

Todos os arquivos obrigatórios existem.

Todos os JSONs são válidos.

Todos os códigos são únicos.

Todos os prefixos são válidos.

Todas as referências existem.

As contagens conferem.

Todo exercício ativo possui um grupo principal.

Não existem relacionamentos duplicados.

Não existem códigos reutilizados.

Itens removidos foram inativados.

Exercícios personalizados não são afetados.

A instalação ocorre em transação.

O flutter analyze não apresenta problemas.

Os testes da Biblioteca foram aprovados.

29. Glossário
Biblioteca Oficial

Conjunto de conhecimento distribuído pelo aplicativo e instalado localmente.

Catálogo

Conjunto oficial reutilizável, como grupos, equipamentos ou tags.

Exercício Oficial

Exercício fornecido pela Biblioteca Oficial.

Exercício Personalizado

Exercício criado pelo usuário.

Código permanente

Identificador oficial imutável.

Grupo principal

Grupo muscular predominante do exercício.

Grupo secundário

Grupo muscular auxiliar ou relevante.

Movimento

Família funcional do exercício.

Variação

Forma específica de execução.

Padrão motor

Classificação biomecânica predominante.

Equipamento obrigatório

Item necessário para a execução prevista.

Equipamento opcional

Item que pode auxiliar ou representar uma alternativa.

Alias

Nome alternativo usado em pesquisas.

Tag

Classificação complementar para filtros e organização.

Installer

Componente responsável pela persistência da Biblioteca.

Validator

Componente responsável por impedir a instalação de dados inconsistentes.

30. Encerramento

Este documento é a fonte oficial para a implementação da Biblioteca Oficial do GymControl.

A partir da versão 2.0:

os catálogos serão persistidos;
os relacionamentos serão normalizados;
os códigos serão permanentes;
os JSONs serão usados apenas para distribuição;
o SQLite será usado para consultas;
as atualizações preservarão os dados do usuário;
a implementação deverá seguir as decisões arquiteturais registradas.

Qualquer mudança estrutural futura deverá atualizar este documento e registrar uma nova decisão arquitetural.

