import '../catalog_models.dart';

CatalogoExercicio desenvolvimentoMilitarBarra() {
  return const CatalogoExercicio(
    codigo: 'desenvolvimento_militar_barra',
    nome: 'Desenvolvimento militar (barra)',
    nomeCurto: 'Desenvolvimento militar',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'barra',
    familia: 'Desenvolvimento',
    variante: 'Barra',
    nivel: 'intermediario',
    popularidade: 95,
    ordem: 1,
    aliases: [
      'Military Press',
      'Barbell Overhead Press',
      'Overhead Press',
      'OHP',
    ],
    gruposSecundarios: ['triceps', 'corpo_inteiro'],
  );
}

CatalogoExercicio desenvolvimentoMilitarHalteres() {
  return const CatalogoExercicio(
    codigo: 'desenvolvimento_militar_halteres',
    nome: 'Desenvolvimento militar (halteres)',
    nomeCurto: 'Desenvolvimento militar',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Desenvolvimento',
    variante: 'Halteres',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 2,
    aliases: [
      'Dumbbell Shoulder Press',
      'Dumbbell Overhead Press',
      'Desenvolvimento com halteres',
    ],
    gruposSecundarios: ['triceps'],
  );
}

CatalogoExercicio desenvolvimentoSmith() {
  return const CatalogoExercicio(
    codigo: 'desenvolvimento_smith',
    nome: 'Desenvolvimento (Smith)',
    nomeCurto: 'Desenvolvimento Smith',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'smith',
    familia: 'Desenvolvimento',
    variante: 'Smith',
    nivel: 'iniciante',
    popularidade: 80,
    ordem: 3,
    aliases: [
      'Smith Machine Shoulder Press',
      'Smith Overhead Press',
      'Desenvolvimento no Smith',
    ],
    gruposSecundarios: ['triceps'],
  );
}

CatalogoExercicio desenvolvimentoMaquina() {
  return const CatalogoExercicio(
    codigo: 'desenvolvimento_maquina',
    nome: 'Desenvolvimento (máquina)',
    nomeCurto: 'Desenvolvimento máquina',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'maquina',
    familia: 'Desenvolvimento',
    variante: 'Máquina',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 4,
    aliases: [
      'Machine Shoulder Press',
      'Shoulder Press Machine',
      'Desenvolvimento articulado',
    ],
    gruposSecundarios: ['triceps'],
  );
}

CatalogoExercicio desenvolvimentoUnilateralHalter() {
  return const CatalogoExercicio(
    codigo: 'desenvolvimento_unilateral_halter',
    nome: 'Desenvolvimento unilateral (halter)',
    nomeCurto: 'Desenvolvimento unilateral',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Desenvolvimento',
    variante: 'Unilateral',
    nivel: 'intermediario',
    popularidade: 65,
    ordem: 5,
    aliases: ['Single Arm Dumbbell Shoulder Press', 'One Arm Shoulder Press'],
    gruposSecundarios: ['triceps'],
  );
}

CatalogoExercicio arnoldPress() {
  return const CatalogoExercicio(
    codigo: 'arnold_press',
    nome: 'Arnold Press',
    nomeCurto: 'Arnold Press',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Desenvolvimento',
    variante: 'Arnold',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 6,
    aliases: ['Arnold Dumbbell Press', 'Desenvolvimento Arnold'],
    gruposSecundarios: ['triceps'],
  );
}

CatalogoExercicio elevacaoLateralHalteres() {
  return const CatalogoExercicio(
    codigo: 'elevacao_lateral_halteres',
    nome: 'Elevação lateral (halteres)',
    nomeCurto: 'Elevação lateral',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Elevação lateral',
    variante: 'Halteres',
    nivel: 'iniciante',
    popularidade: 100,
    ordem: 7,
    aliases: [
      'Dumbbell Lateral Raise',
      'Side Lateral Raise',
      'Elevação lateral',
    ],
  );
}

CatalogoExercicio elevacaoLateralUnilateralHalter() {
  return const CatalogoExercicio(
    codigo: 'elevacao_lateral_unilateral_halter',
    nome: 'Elevação lateral unilateral (halter)',
    nomeCurto: 'Elevação lateral unilateral',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Elevação lateral',
    variante: 'Unilateral',
    nivel: 'iniciante',
    popularidade: 70,
    ordem: 8,
    aliases: ['Single Arm Dumbbell Lateral Raise', 'One Arm Lateral Raise'],
  );
}

CatalogoExercicio elevacaoLateralPolia() {
  return const CatalogoExercicio(
    codigo: 'elevacao_lateral_polia',
    nome: 'Elevação lateral (polia)',
    nomeCurto: 'Elevação lateral',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'polia',
    familia: 'Elevação lateral',
    variante: 'Polia',
    nivel: 'iniciante',
    popularidade: 85,
    ordem: 9,
    aliases: ['Cable Lateral Raise', 'Elevação lateral no cabo'],
  );
}

CatalogoExercicio elevacaoLateralMaquina() {
  return const CatalogoExercicio(
    codigo: 'elevacao_lateral_maquina',
    nome: 'Elevação lateral (máquina)',
    nomeCurto: 'Elevação lateral',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'maquina',
    familia: 'Elevação lateral',
    variante: 'Máquina',
    nivel: 'iniciante',
    popularidade: 85,
    ordem: 10,
    aliases: [
      'Machine Lateral Raise',
      'Lateral Raise Machine',
      'Elevação lateral articulada',
    ],
  );
}

CatalogoExercicio elevacaoFrontalBarra() {
  return const CatalogoExercicio(
    codigo: 'elevacao_frontal_barra',
    nome: 'Elevação frontal (barra)',
    nomeCurto: 'Elevação frontal',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'barra',
    familia: 'Elevação frontal',
    variante: 'Barra',
    nivel: 'iniciante',
    popularidade: 60,
    ordem: 11,
    aliases: ['Barbell Front Raise', 'Elevação frontal com barra'],
  );
}

CatalogoExercicio elevacaoFrontalHalteres() {
  return const CatalogoExercicio(
    codigo: 'elevacao_frontal_halteres',
    nome: 'Elevação frontal (halteres)',
    nomeCurto: 'Elevação frontal',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Elevação frontal',
    variante: 'Halteres',
    nivel: 'iniciante',
    popularidade: 70,
    ordem: 12,
    aliases: ['Dumbbell Front Raise', 'Elevação frontal com halteres'],
  );
}

CatalogoExercicio elevacaoFrontalPolia() {
  return const CatalogoExercicio(
    codigo: 'elevacao_frontal_polia',
    nome: 'Elevação frontal (polia)',
    nomeCurto: 'Elevação frontal',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'polia',
    familia: 'Elevação frontal',
    variante: 'Polia',
    nivel: 'iniciante',
    popularidade: 55,
    ordem: 13,
    aliases: ['Cable Front Raise', 'Elevação frontal no cabo'],
  );
}

CatalogoExercicio crucifixoInvertidoHalteres() {
  return const CatalogoExercicio(
    codigo: 'crucifixo_invertido_halteres',
    nome: 'Crucifixo invertido (halteres)',
    nomeCurto: 'Crucifixo invertido',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Deltoide posterior',
    variante: 'Halteres',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 14,
    aliases: [
      'Reverse Dumbbell Fly',
      'Bent Over Reverse Fly',
      'Crucifixo inverso',
    ],
    gruposSecundarios: ['costas'],
  );
}

CatalogoExercicio crucifixoInvertidoMaquina() {
  return const CatalogoExercicio(
    codigo: 'crucifixo_invertido_maquina',
    nome: 'Crucifixo invertido (máquina)',
    nomeCurto: 'Crucifixo invertido',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'maquina',
    familia: 'Deltoide posterior',
    variante: 'Máquina',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 15,
    aliases: ['Reverse Peck Deck', 'Reverse Fly Machine', 'Voador inverso'],
    gruposSecundarios: ['costas'],
  );
}

CatalogoExercicio facePullPolia() {
  return const CatalogoExercicio(
    codigo: 'face_pull_polia',
    nome: 'Face Pull (polia)',
    nomeCurto: 'Face Pull',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'polia',
    familia: 'Deltoide posterior',
    variante: 'Polia',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 16,
    aliases: ['Face Pull', 'Cable Face Pull', 'Puxada para o rosto'],
    gruposSecundarios: ['costas'],
  );
}

CatalogoExercicio remadaAltaBarra() {
  return const CatalogoExercicio(
    codigo: 'remada_alta_barra',
    nome: 'Remada alta (barra)',
    nomeCurto: 'Remada alta',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'barra',
    familia: 'Remada alta',
    variante: 'Barra',
    nivel: 'intermediario',
    popularidade: 65,
    ordem: 17,
    aliases: ['Barbell Upright Row', 'Upright Row', 'Remada vertical'],
    gruposSecundarios: ['costas', 'biceps'],
  );
}

CatalogoExercicio remadaAltaPoliaOmbros() {
  return const CatalogoExercicio(
    codigo: 'remada_alta_polia_ombros',
    nome: 'Remada alta (polia)',
    nomeCurto: 'Remada alta',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'polia',
    familia: 'Remada alta',
    variante: 'Polia',
    nivel: 'intermediario',
    popularidade: 60,
    ordem: 18,
    aliases: ['Cable Upright Row', 'Remada alta no cabo'],
    gruposSecundarios: ['costas', 'biceps'],
  );
}

CatalogoExercicio cubanPressHalteres() {
  return const CatalogoExercicio(
    codigo: 'cuban_press_halteres',
    nome: 'Cuban Press (halteres)',
    nomeCurto: 'Cuban Press',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Estabilização',
    variante: 'Halteres',
    nivel: 'avancado',
    popularidade: 35,
    ordem: 19,
    aliases: ['Cuban Press', 'Dumbbell Cuban Press', 'Rotação cubana'],
    gruposSecundarios: ['costas'],
  );
}

CatalogoExercicio yRaiseHalteres() {
  return const CatalogoExercicio(
    codigo: 'y_raise_halteres',
    nome: 'Y Raise (halteres)',
    nomeCurto: 'Y Raise',
    grupoPrincipalCodigo: 'ombros',
    equipamento: 'halteres',
    familia: 'Estabilização',
    variante: 'Halteres',
    nivel: 'intermediario',
    popularidade: 45,
    ordem: 20,
    aliases: ['Y Raise', 'Dumbbell Y Raise', 'Elevação em Y', 'Trap-3 Raise'],
    gruposSecundarios: ['costas'],
  );
}

final catalogoOmbros = CatalogoGrupo(
  codigo: 'ombros',
  nome: 'Ombros',
  exercicios: [
    desenvolvimentoMilitarBarra(),
    desenvolvimentoMilitarHalteres(),
    desenvolvimentoSmith(),
    desenvolvimentoMaquina(),
    desenvolvimentoUnilateralHalter(),
    arnoldPress(),
    elevacaoLateralHalteres(),
    elevacaoLateralUnilateralHalter(),
    elevacaoLateralPolia(),
    elevacaoLateralMaquina(),
    elevacaoFrontalBarra(),
    elevacaoFrontalHalteres(),
    elevacaoFrontalPolia(),
    crucifixoInvertidoHalteres(),
    crucifixoInvertidoMaquina(),
    facePullPolia(),
    remadaAltaBarra(),
    remadaAltaPoliaOmbros(),
    cubanPressHalteres(),
    yRaiseHalteres(),
  ],
);
