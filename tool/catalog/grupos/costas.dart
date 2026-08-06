import '../catalog_models.dart';

CatalogoExercicio remadaCurvadaBarra() {
  return const CatalogoExercicio(
    codigo: 'remada_curvada_barra',
    nome: 'Remada curvada (barra)',
    nomeCurto: 'Remada curvada',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'barra',
    familia: 'Remada',
    variante: 'Curvada',
    nivel: 'intermediario',
    popularidade: 100,
    ordem: 1,
    aliases: ['Barbell Row', 'Bent Over Row', 'Remada com barra'],
    gruposSecundarios: ['biceps', 'ombros', 'lombar'],
  );
}

CatalogoExercicio remadaCurvadaHalteres() {
  return const CatalogoExercicio(
    codigo: 'remada_curvada_halteres',
    nome: 'Remada curvada (halteres)',
    nomeCurto: 'Remada curvada',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'halteres',
    familia: 'Remada',
    variante: 'Curvada',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 2,
    aliases: ['Dumbbell Bent Over Row', 'Remada curvada com halteres'],
    gruposSecundarios: ['biceps', 'ombros', 'lombar'],
  );
}

CatalogoExercicio remadaUnilateralHalter() {
  return const CatalogoExercicio(
    codigo: 'remada_unilateral_halter',
    nome: 'Remada unilateral (halter)',
    nomeCurto: 'Remada unilateral',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'halteres',
    familia: 'Remada',
    variante: 'Unilateral',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 3,
    aliases: ['One Arm Dumbbell Row', 'Dumbbell Row', 'Serrote'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio remadaBaixaPolia() {
  return const CatalogoExercicio(
    codigo: 'remada_baixa_polia',
    nome: 'Remada baixa (polia)',
    nomeCurto: 'Remada baixa',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Remada',
    variante: 'Baixa',
    nivel: 'iniciante',
    popularidade: 100,
    ordem: 4,
    aliases: ['Seated Cable Row', 'Cable Row', 'Remada sentada'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio remadaBaixaPegadaNeutra() {
  return const CatalogoExercicio(
    codigo: 'remada_baixa_pegada_neutra',
    nome: 'Remada baixa (pegada neutra)',
    nomeCurto: 'Remada baixa',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Remada',
    variante: 'Pegada neutra',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 5,
    aliases: ['Neutral Grip Cable Row', 'Remada triângulo'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio remadaMaquina() {
  return const CatalogoExercicio(
    codigo: 'remada_maquina',
    nome: 'Remada (máquina)',
    nomeCurto: 'Remada máquina',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'maquina',
    familia: 'Remada',
    variante: 'Máquina',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 6,
    aliases: ['Machine Row', 'Remada articulada', 'Remada convergente'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio remadaCavalinhoBarra() {
  return const CatalogoExercicio(
    codigo: 'remada_cavalinho_barra',
    nome: 'Remada cavalinho (barra)',
    nomeCurto: 'Remada cavalinho',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'barra',
    familia: 'Remada',
    variante: 'Cavalinho',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 7,
    aliases: ['T-Bar Row', 'Landmine Row', 'Remada T'],
    gruposSecundarios: ['biceps', 'ombros', 'lombar'],
  );
}

CatalogoExercicio remadaCavalinhoMaquina() {
  return const CatalogoExercicio(
    codigo: 'remada_cavalinho_maquina',
    nome: 'Remada cavalinho (máquina)',
    nomeCurto: 'Remada cavalinho',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'maquina',
    familia: 'Remada',
    variante: 'Cavalinho',
    nivel: 'iniciante',
    popularidade: 70,
    ordem: 8,
    aliases: ['Machine T-Bar Row', 'Remada T máquina'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio remadaAltaPolia() {
  return const CatalogoExercicio(
    codigo: 'remada_alta_polia',
    nome: 'Remada alta para costas (polia)',
    nomeCurto: 'Remada alta',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Remada',
    variante: 'Alta',
    nivel: 'intermediario',
    popularidade: 60,
    ordem: 9,
    aliases: ['High Cable Row', 'Remada alta sentada'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio puxadaFrenteAberta() {
  return const CatalogoExercicio(
    codigo: 'puxada_frente_aberta',
    nome: 'Puxada frente (pegada aberta)',
    nomeCurto: 'Puxada frente',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Puxada',
    variante: 'Pegada aberta',
    nivel: 'iniciante',
    popularidade: 100,
    ordem: 10,
    aliases: ['Lat Pulldown', 'Wide Grip Lat Pulldown', 'Puxada aberta'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio puxadaFrenteFechada() {
  return const CatalogoExercicio(
    codigo: 'puxada_frente_fechada',
    nome: 'Puxada frente (pegada fechada)',
    nomeCurto: 'Puxada frente',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Puxada',
    variante: 'Pegada fechada',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 11,
    aliases: ['Close Grip Lat Pulldown', 'Puxada fechada'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio puxadaFrenteNeutra() {
  return const CatalogoExercicio(
    codigo: 'puxada_frente_neutra',
    nome: 'Puxada frente (pegada neutra)',
    nomeCurto: 'Puxada frente',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Puxada',
    variante: 'Pegada neutra',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 12,
    aliases: ['Neutral Grip Lat Pulldown', 'Puxada triângulo'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio puxadaSupinada() {
  return const CatalogoExercicio(
    codigo: 'puxada_supinada',
    nome: 'Puxada frente (pegada supinada)',
    nomeCurto: 'Puxada supinada',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Puxada',
    variante: 'Supinada',
    nivel: 'iniciante',
    popularidade: 80,
    ordem: 13,
    aliases: ['Reverse Grip Lat Pulldown', 'Underhand Lat Pulldown'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio puxadaUnilateralPolia() {
  return const CatalogoExercicio(
    codigo: 'puxada_unilateral_polia',
    nome: 'Puxada unilateral (polia)',
    nomeCurto: 'Puxada unilateral',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Puxada',
    variante: 'Unilateral',
    nivel: 'intermediario',
    popularidade: 70,
    ordem: 14,
    aliases: ['Single Arm Lat Pulldown', 'One Arm Lat Pulldown'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio barraFixaPronada() {
  return const CatalogoExercicio(
    codigo: 'barra_fixa_pronada',
    nome: 'Barra fixa (pegada pronada)',
    nomeCurto: 'Barra fixa',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'pesoCorporal',
    familia: 'Puxada',
    variante: 'Pronada',
    nivel: 'intermediario',
    popularidade: 95,
    ordem: 15,
    aliases: ['Pull-up', 'Pullup', 'Barra fixa aberta'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio barraFixaSupinada() {
  return const CatalogoExercicio(
    codigo: 'barra_fixa_supinada',
    nome: 'Barra fixa (pegada supinada)',
    nomeCurto: 'Barra fixa',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'pesoCorporal',
    familia: 'Puxada',
    variante: 'Supinada',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 16,
    aliases: ['Chin-up', 'Chinup', 'Barra fixa supinada'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio barraFixaAssistida() {
  return const CatalogoExercicio(
    codigo: 'barra_fixa_assistida',
    nome: 'Barra fixa assistida (máquina)',
    nomeCurto: 'Barra fixa assistida',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'maquina',
    familia: 'Puxada',
    variante: 'Assistida',
    nivel: 'iniciante',
    popularidade: 80,
    ordem: 17,
    aliases: ['Assisted Pull-up', 'Graviton', 'Barra fixa no gravitron'],
    gruposSecundarios: ['biceps', 'ombros'],
  );
}

CatalogoExercicio pulldownRetoPolia() {
  return const CatalogoExercicio(
    codigo: 'pulldown_reto_polia',
    nome: 'Pulldown reto (polia)',
    nomeCurto: 'Pulldown reto',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Pulldown',
    variante: 'Reto',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 18,
    aliases: [
      'Straight Arm Pulldown',
      'Pullover na polia',
      'Pulldown braços retos',
    ],
    gruposSecundarios: ['triceps', 'ombros'],
  );
}

CatalogoExercicio pulldownUnilateralPolia() {
  return const CatalogoExercicio(
    codigo: 'pulldown_unilateral_polia',
    nome: 'Pulldown unilateral (polia)',
    nomeCurto: 'Pulldown unilateral',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Pulldown',
    variante: 'Unilateral',
    nivel: 'intermediario',
    popularidade: 60,
    ordem: 19,
    aliases: [
      'Single Arm Straight Arm Pulldown',
      'Pullover unilateral na polia',
    ],
    gruposSecundarios: ['triceps', 'ombros'],
  );
}

CatalogoExercicio levantamentoTerraBarra() {
  return const CatalogoExercicio(
    codigo: 'levantamento_terra_barra',
    nome: 'Levantamento terra (barra)',
    nomeCurto: 'Levantamento terra',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'barra',
    familia: 'Levantamento',
    variante: 'Convencional',
    nivel: 'intermediario',
    popularidade: 90,
    ordem: 20,
    aliases: ['Deadlift', 'Conventional Deadlift', 'Terra'],
    gruposSecundarios: ['lombar', 'gluteos', 'posteriores_coxa', 'antebracos'],
  );
}

CatalogoExercicio rackPullBarra() {
  return const CatalogoExercicio(
    codigo: 'rack_pull_barra',
    nome: 'Rack Pull (barra)',
    nomeCurto: 'Rack Pull',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'barra',
    familia: 'Levantamento',
    variante: 'Parcial',
    nivel: 'intermediario',
    popularidade: 50,
    ordem: 21,
    aliases: ['Rack Deadlift', 'Levantamento terra parcial'],
    gruposSecundarios: ['lombar', 'gluteos', 'posteriores_coxa', 'antebracos'],
  );
}

CatalogoExercicio encolhimentoEscapularPolia() {
  return const CatalogoExercicio(
    codigo: 'encolhimento_escapular_polia',
    nome: 'Depressão escapular (polia)',
    nomeCurto: 'Depressão escapular',
    grupoPrincipalCodigo: 'costas',
    equipamento: 'polia',
    familia: 'Controle escapular',
    variante: 'Polia',
    nivel: 'intermediario',
    popularidade: 40,
    ordem: 22,
    aliases: ['Scapular Pulldown', 'Straight Arm Scapular Pulldown'],
    gruposSecundarios: ['ombros'],
  );
}

final catalogoCostas = CatalogoGrupo(
  codigo: 'costas',
  nome: 'Costas',
  exercicios: [
    remadaCurvadaBarra(),
    remadaCurvadaHalteres(),
    remadaUnilateralHalter(),
    remadaBaixaPolia(),
    remadaBaixaPegadaNeutra(),
    remadaMaquina(),
    remadaCavalinhoBarra(),
    remadaCavalinhoMaquina(),
    remadaAltaPolia(),
    puxadaFrenteAberta(),
    puxadaFrenteFechada(),
    puxadaFrenteNeutra(),
    puxadaSupinada(),
    puxadaUnilateralPolia(),
    barraFixaPronada(),
    barraFixaSupinada(),
    barraFixaAssistida(),
    pulldownRetoPolia(),
    pulldownUnilateralPolia(),
    levantamentoTerraBarra(),
    rackPullBarra(),
    encolhimentoEscapularPolia(),
  ],
);
