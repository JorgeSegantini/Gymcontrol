import '../catalog_models.dart';

CatalogoExercicio tricepsCordaPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_corda_polia',
    nome: 'Tríceps corda (polia)',
    nomeCurto: 'Tríceps corda',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Pushdown',
    variante: 'Corda',
    nivel: 'iniciante',
    popularidade: 100,
    ordem: 1,
    aliases: ['Rope Pushdown', 'Cable Rope Pushdown', 'Tríceps na corda'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio tricepsBarraRetaPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_barra_reta_polia',
    nome: 'Tríceps barra reta (polia)',
    nomeCurto: 'Tríceps barra reta',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Pushdown',
    variante: 'Barra reta',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 2,
    aliases: [
      'Straight Bar Pushdown',
      'Cable Triceps Pushdown',
      'Tríceps pulley',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio tricepsBarraVPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_barra_v_polia',
    nome: 'Tríceps barra V (polia)',
    nomeCurto: 'Tríceps barra V',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Pushdown',
    variante: 'Barra V',
    nivel: 'iniciante',
    popularidade: 85,
    ordem: 3,
    aliases: ['V-Bar Pushdown', 'Cable V-Bar Pushdown', 'Tríceps no puxador V'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio tricepsUnilateralPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_unilateral_polia',
    nome: 'Tríceps unilateral (polia)',
    nomeCurto: 'Tríceps unilateral',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Pushdown',
    variante: 'Unilateral',
    nivel: 'iniciante',
    popularidade: 80,
    ordem: 4,
    aliases: [
      'Single Arm Cable Pushdown',
      'One Arm Triceps Pushdown',
      'Tríceps unilateral no cabo',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio tricepsPegadaSupinadaPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_pegada_supinada_polia',
    nome: 'Tríceps pegada supinada (polia)',
    nomeCurto: 'Tríceps supinado',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Pushdown',
    variante: 'Supinada',
    nivel: 'intermediario',
    popularidade: 60,
    ordem: 5,
    aliases: [
      'Reverse Grip Pushdown',
      'Underhand Triceps Pushdown',
      'Tríceps inverso',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio tricepsFrancesHalter() {
  return const CatalogoExercicio(
    codigo: 'triceps_frances_halter',
    nome: 'Tríceps francês (halter)',
    nomeCurto: 'Tríceps francês',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'halteres',
    familia: 'Extensão acima da cabeça',
    variante: 'Halter',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 6,
    aliases: [
      'Dumbbell Overhead Triceps Extension',
      'French Press Dumbbell',
      'Extensão de tríceps acima da cabeça',
    ],
  );
}

CatalogoExercicio tricepsFrancesUnilateralHalter() {
  return const CatalogoExercicio(
    codigo: 'triceps_frances_unilateral_halter',
    nome: 'Tríceps francês unilateral (halter)',
    nomeCurto: 'Tríceps francês unilateral',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'halteres',
    familia: 'Extensão acima da cabeça',
    variante: 'Unilateral',
    nivel: 'iniciante',
    popularidade: 75,
    ordem: 7,
    aliases: [
      'Single Arm Overhead Triceps Extension',
      'One Arm Dumbbell Triceps Extension',
    ],
  );
}

CatalogoExercicio tricepsFrancesCordaPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_frances_corda_polia',
    nome: 'Tríceps francês (corda)',
    nomeCurto: 'Tríceps francês',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Extensão acima da cabeça',
    variante: 'Corda',
    nivel: 'iniciante',
    popularidade: 85,
    ordem: 8,
    aliases: [
      'Overhead Rope Triceps Extension',
      'Cable Overhead Triceps Extension',
      'Tríceps francês na polia',
    ],
  );
}

CatalogoExercicio tricepsTestaBarraW() {
  return const CatalogoExercicio(
    codigo: 'triceps_testa_barra_w',
    nome: 'Tríceps testa (barra W)',
    nomeCurto: 'Tríceps testa',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'barra',
    familia: 'Tríceps testa',
    variante: 'Barra W',
    nivel: 'intermediario',
    popularidade: 90,
    ordem: 9,
    aliases: [
      'EZ Bar Skull Crusher',
      'Lying Triceps Extension',
      'Skull Crusher',
    ],
  );
}

CatalogoExercicio tricepsTestaBarraReta() {
  return const CatalogoExercicio(
    codigo: 'triceps_testa_barra_reta',
    nome: 'Tríceps testa (barra reta)',
    nomeCurto: 'Tríceps testa',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'barra',
    familia: 'Tríceps testa',
    variante: 'Barra reta',
    nivel: 'intermediario',
    popularidade: 75,
    ordem: 10,
    aliases: ['Barbell Skull Crusher', 'Straight Bar Lying Triceps Extension'],
  );
}

CatalogoExercicio tricepsTestaHalteres() {
  return const CatalogoExercicio(
    codigo: 'triceps_testa_halteres',
    nome: 'Tríceps testa (halteres)',
    nomeCurto: 'Tríceps testa',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'halteres',
    familia: 'Tríceps testa',
    variante: 'Halteres',
    nivel: 'intermediario',
    popularidade: 70,
    ordem: 11,
    aliases: ['Dumbbell Skull Crusher', 'Dumbbell Lying Triceps Extension'],
  );
}

CatalogoExercicio tricepsTestaPolia() {
  return const CatalogoExercicio(
    codigo: 'triceps_testa_polia',
    nome: 'Tríceps testa (polia)',
    nomeCurto: 'Tríceps testa',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Tríceps testa',
    variante: 'Polia',
    nivel: 'intermediario',
    popularidade: 65,
    ordem: 12,
    aliases: ['Cable Skull Crusher', 'Cable Lying Triceps Extension'],
  );
}

CatalogoExercicio coiceTricepsHalter() {
  return const CatalogoExercicio(
    codigo: 'coice_triceps_halter',
    nome: 'Coice de tríceps (halter)',
    nomeCurto: 'Coice de tríceps',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'halteres',
    familia: 'Coice',
    variante: 'Halter',
    nivel: 'iniciante',
    popularidade: 65,
    ordem: 13,
    aliases: [
      'Dumbbell Triceps Kickback',
      'Triceps Kickback',
      'Coice com halter',
    ],
  );
}

CatalogoExercicio coiceTricepsPolia() {
  return const CatalogoExercicio(
    codigo: 'coice_triceps_polia',
    nome: 'Coice de tríceps (polia)',
    nomeCurto: 'Coice de tríceps',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'polia',
    familia: 'Coice',
    variante: 'Polia',
    nivel: 'iniciante',
    popularidade: 60,
    ordem: 14,
    aliases: [
      'Cable Triceps Kickback',
      'Triceps Kickback Cable',
      'Coice no cabo',
    ],
  );
}

CatalogoExercicio paralelasPesoCorporal() {
  return const CatalogoExercicio(
    codigo: 'paralelas_peso_corporal',
    nome: 'Paralelas (peso corporal)',
    nomeCurto: 'Paralelas',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'pesoCorporal',
    familia: 'Paralelas',
    variante: 'Peso corporal',
    nivel: 'intermediario',
    popularidade: 90,
    ordem: 15,
    aliases: [
      'Dips',
      'Parallel Bar Dips',
      'Triceps Dips',
      'Mergulho nas paralelas',
    ],
    gruposSecundarios: ['peitoral', 'ombros'],
  );
}

CatalogoExercicio paralelasAssistidaMaquina() {
  return const CatalogoExercicio(
    codigo: 'paralelas_assistida_maquina',
    nome: 'Paralelas assistida (máquina)',
    nomeCurto: 'Paralelas assistida',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'maquina',
    familia: 'Paralelas',
    variante: 'Assistida',
    nivel: 'iniciante',
    popularidade: 75,
    ordem: 16,
    aliases: [
      'Assisted Dips',
      'Machine Assisted Dips',
      'Paralelas no gravitron',
    ],
    gruposSecundarios: ['peitoral', 'ombros'],
  );
}

CatalogoExercicio mergulhoBanco() {
  return const CatalogoExercicio(
    codigo: 'mergulho_banco',
    nome: 'Mergulho no banco',
    nomeCurto: 'Mergulho no banco',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'banco',
    familia: 'Paralelas',
    variante: 'Banco',
    nivel: 'iniciante',
    popularidade: 70,
    ordem: 17,
    aliases: ['Bench Dips', 'Triceps Bench Dips', 'Tríceps banco'],
    gruposSecundarios: ['peitoral', 'ombros'],
  );
}

CatalogoExercicio supinoFechadoBarra() {
  return const CatalogoExercicio(
    codigo: 'supino_fechado_barra',
    nome: 'Supino fechado (barra)',
    nomeCurto: 'Supino fechado',
    grupoPrincipalCodigo: 'triceps',
    equipamento: 'barra',
    familia: 'Press',
    variante: 'Pegada fechada',
    nivel: 'intermediario',
    popularidade: 85,
    ordem: 18,
    aliases: [
      'Close Grip Bench Press',
      'Narrow Grip Bench Press',
      'Supino pegada fechada',
    ],
    gruposSecundarios: ['peitoral', 'ombros'],
  );
}

final catalogoTriceps = CatalogoGrupo(
  codigo: 'triceps',
  nome: 'Tríceps',
  exercicios: [
    tricepsCordaPolia(),
    tricepsBarraRetaPolia(),
    tricepsBarraVPolia(),
    tricepsUnilateralPolia(),
    tricepsPegadaSupinadaPolia(),
    tricepsFrancesHalter(),
    tricepsFrancesUnilateralHalter(),
    tricepsFrancesCordaPolia(),
    tricepsTestaBarraW(),
    tricepsTestaBarraReta(),
    tricepsTestaHalteres(),
    tricepsTestaPolia(),
    coiceTricepsHalter(),
    coiceTricepsPolia(),
    paralelasPesoCorporal(),
    paralelasAssistidaMaquina(),
    mergulhoBanco(),
    supinoFechadoBarra(),
  ],
);
