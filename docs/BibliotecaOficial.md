# Biblioteca Oficial do GymControl

Versão inicial: 1.0  
Idioma principal: Português do Brasil  
Status: Em construção

---

## 1. Objetivo

A Biblioteca Oficial do GymControl organiza os exercícios distribuídos com o aplicativo.

Ela deve ser:

- fácil de entender;
- simples de pesquisar;
- útil em academias reais;
- livre de duplicações desnecessárias;
- preparada para imagens, vídeos e conteúdo técnico;
- independente dos exercícios personalizados criados pelo usuário.

O aplicativo registra e apresenta informações. As decisões de treino pertencem ao atleta ou ao treinador.

---

## 2. Fonte da verdade

Este documento é a referência editorial da biblioteca.

```text
BibliotecaOficial.md
        ↓
Arquivos JSON
        ↓
BibliotecaInstaller
        ↓
SQLite
        ↓
GymControl
```

Os JSONs e o banco devem refletir as decisões documentadas aqui.

---

## 3. Identificadores permanentes

Cada item deve possuir um identificador legível, em minúsculas, sem acentos e separado por sublinhados.

Exemplos:

```text
peitoral
costas
supino_reto_barra
supino_inclinado_halteres
crucifixo_cabo
```

Regras:

- o identificador não deve mudar depois de publicado;
- o nome visível pode ser corrigido sem alterar o identificador;
- o mesmo identificador poderá ser usado em JSON, Markdown, imagens e vídeos;
- não usar números quando um nome legível for suficiente;
- não usar espaços, acentos ou caracteres especiais.

---

## 4. Idioma e nomenclatura

### 4.1 Nome oficial

Usar português quando existir um nome consolidado no Brasil.

Exemplos:

```text
Supino reto (barra)
Supino inclinado (halteres)
Crucifixo no cabo
Flexão de braço
```

### 4.2 Termos em inglês

O termo em inglês deve ser usado como alias de pesquisa.

Quando o nome em inglês for amplamente conhecido e a tradução não for natural, ele pode aparecer entre parênteses ou permanecer como nome principal.

Exemplos:

```text
Pulôver (Pullover)
Voador (Peck Deck)
Chest Press
Svend Press
```

### 4.3 Nome curto

O nome curto será usado em espaços reduzidos, especialmente durante o treino.

```text
Nome oficial: Supino reto (barra)
Nome curto: Supino reto
```

Quando duas variações de equipamentos puderem aparecer juntas na mesma tela, a interface poderá acrescentar o equipamento para evitar ambiguidade.

---

## 5. Aliases

Aliases ajudam a pesquisa, mas não criam exercícios duplicados.

```text
Exercício: Supino reto (barra)

Aliases:
- Bench Press
- Barbell Bench Press
- Flat Bench Press
- Supino com barra
```

Regras:

- um alias não deve aparecer como exercício separado;
- incluir nomes comuns em português e inglês;
- evitar variações apenas de maiúsculas, acentos ou pontuação;
- aliases não alteram o nome mostrado ao usuário.

---

## 6. Grupos musculares oficiais

| Identificador | Nome | Ordem |
|---|---|---:|
| `peitoral` | Peitoral | 1 |
| `costas` | Costas | 2 |
| `ombros` | Ombros | 3 |
| `biceps` | Bíceps | 4 |
| `triceps` | Tríceps | 5 |
| `antebracos` | Antebraços | 6 |
| `quadriceps` | Quadríceps | 7 |
| `posteriores_coxa` | Posteriores de coxa | 8 |
| `gluteos` | Glúteos | 9 |
| `panturrilhas` | Panturrilhas | 10 |
| `abdomen` | Abdômen | 11 |
| `lombar` | Lombar | 12 |
| `corpo_inteiro` | Corpo inteiro | 13 |

Um exercício pode possuir um grupo principal e grupos secundários. Na primeira etapa, a tabela principal `Exercicios` continuará usando um grupo principal.

---

## 7. Equipamentos oficiais

| Identificador | Nome |
|---|---|
| `barra` | Barra |
| `halteres` | Halteres |
| `maquina` | Máquina |
| `polia` | Polia |
| `smith` | Smith |
| `peso_corporal` | Peso corporal |
| `kettlebell` | Kettlebell |
| `elastico` | Elástico |
| `bola_suica` | Bola suíça |
| `trx` | TRX |
| `banco` | Banco |
| `outro` | Outro |

Regras:

- a marca do equipamento não faz parte do nome oficial;
- características como convergente, articulada ou guiada são variações, não novos tipos gerais de equipamento;
- criar exercícios diferentes quando a posição ou o padrão do movimento mudar de forma relevante.

---

## 8. Estrutura editorial de um exercício

Cada exercício poderá possuir:

```text
Identificador
Nome oficial
Nome curto
Aliases
Grupo principal
Grupos secundários
Família
Variante
Equipamento
Tipo
Nível
Velocidade padrão
Popularidade
Descrição
Instruções
Dicas
Erros comuns
Mídias
Status editorial
```

Nem todos os campos precisam estar completos na primeira versão.

Status editorial:

- `estrutura`: cadastro básico concluído;
- `parcial`: possui parte do conteúdo técnico;
- `revisado`: conteúdo técnico e mídias revisados.

---

## 9. Conteúdo e mídias

O banco deve guardar os dados estruturados usados nas telas e consultas.

Conteúdo técnico extenso poderá ficar em arquivos Markdown.

Mídias devem ficar fora do SQLite. O banco armazenará somente referências.

```text
assets/biblioteca/
├── exercicios/
│   └── supino_reto_barra.md
├── imagens/
│   └── supino_reto_barra.webp
└── videos/
    └── supino_reto_barra.mp4
```

Também serão aceitos links externos, como YouTube, Google Drive ou outras URLs.

---

## 10. Regras de desempenho

- listagens carregam apenas dados essenciais;
- conteúdo técnico é carregado quando o usuário abre os detalhes;
- vídeos não ficam dentro do banco;
- imagens e vídeos locais são arquivos separados;
- o histórico e a execução do treino não carregam conteúdo técnico ou mídias sem necessidade.

---

# 11. Peitoral

Status do grupo: Em revisão  
Grupo principal: `peitoral`

## 11.1 Família: Supino

### `supino_reto_barra`

- Nome oficial: Supino reto (barra)
- Nome curto: Supino reto
- Equipamento: Barra
- Família: Supino
- Variante: Reto
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 100
- Status editorial: Estrutura
- Aliases: Bench Press; Barbell Bench Press; Flat Bench Press; Supino com barra

### `supino_reto_halteres`

- Nome oficial: Supino reto (halteres)
- Nome curto: Supino reto
- Equipamento: Halteres
- Família: Supino
- Variante: Reto
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 95
- Status editorial: Estrutura
- Aliases: Dumbbell Bench Press; Flat Dumbbell Press; Supino com halteres

### `supino_reto_maquina`

- Nome oficial: Supino reto (máquina)
- Nome curto: Supino reto
- Equipamento: Máquina
- Família: Supino
- Variante: Reto
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 90
- Status editorial: Estrutura
- Aliases: Machine Chest Press; Supino máquina; Máquina de supino reto; Supino sentado

### `supino_inclinado_barra`

- Nome oficial: Supino inclinado (barra)
- Nome curto: Supino inclinado
- Equipamento: Barra
- Família: Supino
- Variante: Inclinado
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 95
- Status editorial: Estrutura
- Aliases: Incline Bench Press; Incline Barbell Bench Press; Supino inclinado com barra

### `supino_inclinado_halteres`

- Nome oficial: Supino inclinado (halteres)
- Nome curto: Supino inclinado
- Equipamento: Halteres
- Família: Supino
- Variante: Inclinado
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 95
- Status editorial: Estrutura
- Aliases: Incline Dumbbell Press; Incline Dumbbell Bench Press; Supino inclinado com halteres

### `supino_inclinado_maquina`

- Nome oficial: Supino inclinado (máquina)
- Nome curto: Supino inclinado
- Equipamento: Máquina
- Família: Supino
- Variante: Inclinado
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 90
- Status editorial: Estrutura
- Aliases: Incline Machine Press; Incline Chest Press; Máquina de supino inclinado; Supino inclinado máquina

### `supino_declinado_barra`

- Nome oficial: Supino declinado (barra)
- Nome curto: Supino declinado
- Equipamento: Barra
- Família: Supino
- Variante: Declinado
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 75
- Status editorial: Estrutura
- Aliases: Decline Bench Press; Decline Barbell Bench Press; Supino declinado com barra

### `supino_declinado_halteres`

- Nome oficial: Supino declinado (halteres)
- Nome curto: Supino declinado
- Equipamento: Halteres
- Família: Supino
- Variante: Declinado
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 65
- Status editorial: Estrutura
- Aliases: Decline Dumbbell Press; Decline Dumbbell Bench Press; Supino declinado com halteres

### `supino_declinado_maquina`

- Nome oficial: Supino declinado (máquina)
- Nome curto: Supino declinado
- Equipamento: Máquina
- Família: Supino
- Variante: Declinado
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 75
- Status editorial: Estrutura
- Aliases: Decline Machine Press; Decline Chest Press; Máquina de supino declinado; Supino declinado máquina

---

## 11.2 Família: Crucifixo

### `crucifixo_reto_halteres`

- Nome oficial: Crucifixo reto (halteres)
- Nome curto: Crucifixo reto
- Equipamento: Halteres
- Família: Crucifixo
- Variante: Reto
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 80
- Status editorial: Estrutura
- Aliases: Dumbbell Fly; Flat Dumbbell Fly; Crucifixo com halteres

### `crucifixo_inclinado_halteres`

- Nome oficial: Crucifixo inclinado (halteres)
- Nome curto: Crucifixo inclinado
- Equipamento: Halteres
- Família: Crucifixo
- Variante: Inclinado
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 70
- Status editorial: Estrutura
- Aliases: Incline Dumbbell Fly; Crucifixo inclinado com halteres

### `crucifixo_declinado_halteres`

- Nome oficial: Crucifixo declinado (halteres)
- Nome curto: Crucifixo declinado
- Equipamento: Halteres
- Família: Crucifixo
- Variante: Declinado
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 45
- Status editorial: Estrutura
- Aliases: Decline Dumbbell Fly; Crucifixo declinado com halteres

### `crucifixo_cabo`

- Nome oficial: Crucifixo no cabo
- Nome curto: Crucifixo no cabo
- Equipamento: Polia
- Família: Crucifixo
- Variante: Cabo
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 85
- Status editorial: Estrutura
- Aliases: Cable Fly; Cable Crossover; Crossover; Crucifixo na polia

### `crucifixo_inclinado_cabo`

- Nome oficial: Crucifixo inclinado no cabo
- Nome curto: Crucifixo inclinado
- Equipamento: Polia
- Família: Crucifixo
- Variante: Inclinado
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 65
- Status editorial: Estrutura
- Aliases: Incline Cable Fly; Low to High Cable Fly; Crossover de baixo para cima

### `voador_peck_deck`

- Nome oficial: Voador (Peck Deck)
- Nome curto: Voador
- Equipamento: Máquina
- Família: Crucifixo
- Variante: Máquina
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 90
- Status editorial: Estrutura
- Aliases: Peck Deck; Pec Deck; Fly Machine; Crucifixo máquina

---

## 11.3 Família: Press

### `chest_press_maquina`

- Nome oficial: Chest Press (máquina)
- Nome curto: Chest Press
- Equipamento: Máquina
- Família: Press
- Variante: Sentado
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 90
- Status editorial: Estrutura
- Aliases: Chest Press; Machine Chest Press; Press de peito; Supino sentado; Máquina de peito

> Antes de gerar o JSON definitivo, revisar a possível sobreposição entre `chest_press_maquina` e `supino_reto_maquina`.

---

## 11.4 Família: Peso corporal

### `flexao_braco`

- Nome oficial: Flexão de braço
- Nome curto: Flexão
- Equipamento: Peso corporal
- Família: Flexão
- Variante: Reta
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 90
- Status editorial: Estrutura
- Aliases: Push-up; Pushup; Flexão

### `flexao_inclinada`

- Nome oficial: Flexão inclinada
- Nome curto: Flexão inclinada
- Equipamento: Peso corporal
- Família: Flexão
- Variante: Inclinada
- Tipo: Musculação
- Nível inicial: Iniciante
- Popularidade inicial: 65
- Status editorial: Estrutura
- Aliases: Incline Push-up; Flexão com mãos elevadas

### `flexao_declinada`

- Nome oficial: Flexão declinada
- Nome curto: Flexão declinada
- Equipamento: Peso corporal
- Família: Flexão
- Variante: Declinada
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 60
- Status editorial: Estrutura
- Aliases: Decline Push-up; Flexão com pés elevados

---

## 11.5 Família: Extras

### `pulover_halter`

- Nome oficial: Pulôver (halter)
- Nome curto: Pulôver
- Equipamento: Halteres
- Família: Pulôver
- Variante: Halter
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 55
- Status editorial: Estrutura
- Aliases: Pullover; Dumbbell Pullover; Pulôver com halter
- Grupo secundário previsto: Costas

### `svend_press_anilha`

- Nome oficial: Svend Press (anilha)
- Nome curto: Svend Press
- Equipamento: Outro
- Família: Press
- Variante: Anilha
- Tipo: Musculação
- Nível inicial: Intermediário
- Popularidade inicial: 35
- Status editorial: Estrutura
- Aliases: Plate Press; Plate Squeeze Press; Press com anilha

---

## 12. Pendências antes de gerar os JSONs

- definir se `Chest Press (máquina)` e `Supino reto (máquina)` serão mantidos como exercícios distintos;
- confirmar se o nome principal será `Voador (Peck Deck)` ou `Peck Deck (Voador)`;
- definir como grupos secundários serão levados para o banco principal;
- definir o campo `nomeCurto` na tabela `Exercicios`;
- definir se `popularidade` será incluída no banco já na primeira versão;
- criar o gerador dos arquivos JSON;
- criar a estrutura futura de mídias sem armazenar vídeos no SQLite.

---

## 13. Histórico de alterações

### 1.0 — Estrutura inicial

- definidas as convenções da Biblioteca Oficial;
- adotados identificadores legíveis;
- definidos os grupos musculares e equipamentos iniciais;
- criada a primeira revisão do grupo Peitoral;
- incluídas as máquinas de supino reto, inclinado e declinado;
- definidas regras iniciais para aliases, conteúdo e mídias.
