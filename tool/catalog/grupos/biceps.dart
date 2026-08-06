import '../catalog_models.dart';

CatalogoExercicio roscaDiretaBarra() {
  return const CatalogoExercicio(
    codigo: 'rosca_direta_barra',
    nome: 'Rosca direta (barra)',
    nomeCurto: 'Rosca direta',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'barra',
    familia: 'Rosca direta',
    variante: 'Barra',
    nivel: 'iniciante',
    popularidade: 100,
    ordem: 1,
    aliases: ['Barbell Curl', 'Standing Barbell Curl', 'Rosca com barra'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaDiretaBarraW() {
  return const CatalogoExercicio(
    codigo: 'rosca_direta_barra_w',
    nome: 'Rosca direta (barra W)',
    nomeCurto: 'Rosca direta',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'barra',
    familia: 'Rosca direta',
    variante: 'Barra W',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 2,
    aliases: ['EZ Bar Curl', 'EZ Curl', 'Rosca direta barra EZ'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaDiretaHalteres() {
  return const CatalogoExercicio(
    codigo: 'rosca_direta_halteres',
    nome: 'Rosca direta (halteres)',
    nomeCurto: 'Rosca direta',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca direta',
    variante: 'Halteres',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 3,
    aliases: ['Dumbbell Curl', 'Standing Dumbbell Curl', 'Rosca com halteres'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaAlternadaHalteres() {
  return const CatalogoExercicio(
    codigo: 'rosca_alternada_halteres',
    nome: 'Rosca alternada (halteres)',
    nomeCurto: 'Rosca alternada',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca alternada',
    variante: 'Em pé',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 4,
    aliases: [
      'Alternating Dumbbell Curl',
      'Alternate Dumbbell Curl',
      'Rosca alternada',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaAlternadaSentada() {
  return const CatalogoExercicio(
    codigo: 'rosca_alternada_sentada',
    nome: 'Rosca alternada sentada (halteres)',
    nomeCurto: 'Rosca alternada sentada',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca alternada',
    variante: 'Sentada',
    nivel: 'iniciante',
    popularidade: 80,
    ordem: 5,
    aliases: ['Seated Alternating Dumbbell Curl', 'Seated Dumbbell Curl'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaAlternadaInclinada() {
  return const CatalogoExercicio(
    codigo: 'rosca_alternada_inclinada',
    nome: 'Rosca alternada inclinada (halteres)',
    nomeCurto: 'Rosca inclinada',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca alternada',
    variante: 'Banco inclinado',
    nivel: 'intermediario',
    popularidade: 80,
    ordem: 6,
    aliases: [
      'Incline Dumbbell Curl',
      'Incline Alternating Dumbbell Curl',
      'Rosca inclinada',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaMarteloHalteres() {
  return const CatalogoExercicio(
    codigo: 'rosca_martelo_halteres',
    nome: 'Rosca martelo (halteres)',
    nomeCurto: 'Rosca martelo',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca martelo',
    variante: 'Halteres',
    nivel: 'iniciante',
    popularidade: 95,
    ordem: 7,
    aliases: ['Hammer Curl', 'Dumbbell Hammer Curl', 'Rosca neutra'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaMarteloCruzada() {
  return const CatalogoExercicio(
    codigo: 'rosca_martelo_cruzada',
    nome: 'Rosca martelo cruzada (halteres)',
    nomeCurto: 'Rosca martelo cruzada',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca martelo',
    variante: 'Cruzada',
    nivel: 'iniciante',
    popularidade: 75,
    ordem: 8,
    aliases: [
      'Cross Body Hammer Curl',
      'Cross Hammer Curl',
      'Rosca martelo transversal',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaMarteloCorda() {
  return const CatalogoExercicio(
    codigo: 'rosca_martelo_corda',
    nome: 'Rosca martelo (corda)',
    nomeCurto: 'Rosca martelo',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'polia',
    familia: 'Rosca martelo',
    variante: 'Corda',
    nivel: 'iniciante',
    popularidade: 85,
    ordem: 9,
    aliases: [
      'Rope Hammer Curl',
      'Cable Rope Hammer Curl',
      'Rosca martelo na polia',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaScottBarraW() {
  return const CatalogoExercicio(
    codigo: 'rosca_scott_barra_w',
    nome: 'Rosca Scott (barra W)',
    nomeCurto: 'Rosca Scott',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'barra',
    familia: 'Rosca Scott',
    variante: 'Barra W',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 10,
    aliases: ['EZ Bar Preacher Curl', 'Preacher Curl', 'Rosca no banco Scott'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaScottMaquina() {
  return const CatalogoExercicio(
    codigo: 'rosca_scott_maquina',
    nome: 'Rosca Scott (máquina)',
    nomeCurto: 'Rosca Scott',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'maquina',
    familia: 'Rosca Scott',
    variante: 'Máquina',
    nivel: 'iniciante',
    popularidade: 90,
    ordem: 11,
    aliases: [
      'Machine Preacher Curl',
      'Preacher Curl Machine',
      'Rosca Scott articulada',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaScottUnilateral() {
  return const CatalogoExercicio(
    codigo: 'rosca_scott_unilateral',
    nome: 'Rosca Scott unilateral (halter)',
    nomeCurto: 'Rosca Scott unilateral',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca Scott',
    variante: 'Unilateral',
    nivel: 'intermediario',
    popularidade: 70,
    ordem: 12,
    aliases: [
      'Single Arm Preacher Curl',
      'One Arm Preacher Curl',
      'Rosca Scott com halter',
    ],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaConcentradaHalter() {
  return const CatalogoExercicio(
    codigo: 'rosca_concentrada_halter',
    nome: 'Rosca concentrada (halter)',
    nomeCurto: 'Rosca concentrada',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'halteres',
    familia: 'Rosca concentrada',
    variante: 'Halter',
    nivel: 'iniciante',
    popularidade: 75,
    ordem: 13,
    aliases: ['Concentration Curl', 'Dumbbell Concentration Curl'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaConcentradaPolia() {
  return const CatalogoExercicio(
    codigo: 'rosca_concentrada_polia',
    nome: 'Rosca concentrada (polia)',
    nomeCurto: 'Rosca concentrada',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'polia',
    familia: 'Rosca concentrada',
    variante: 'Polia',
    nivel: 'intermediario',
    popularidade: 50,
    ordem: 14,
    aliases: ['Cable Concentration Curl', 'Concentration Cable Curl'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaBaixaBarraReta() {
  return const CatalogoExercicio(
    codigo: 'rosca_baixa_barra_reta',
    nome: 'Rosca baixa (barra reta)',
    nomeCurto: 'Rosca baixa',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'polia',
    familia: 'Rosca na polia',
    variante: 'Barra reta',
    nivel: 'iniciante',
    popularidade: 85,
    ordem: 15,
    aliases: ['Straight Bar Cable Curl', 'Cable Curl', 'Rosca na polia baixa'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaBaixaBarraW() {
  return const CatalogoExercicio(
    codigo: 'rosca_baixa_barra_w',
    nome: 'Rosca baixa (barra W)',
    nomeCurto: 'Rosca baixa',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'polia',
    familia: 'Rosca na polia',
    variante: 'Barra W',
    nivel: 'iniciante',
    popularidade: 80,
    ordem: 16,
    aliases: ['EZ Bar Cable Curl', 'Cable EZ Curl', 'Rosca baixa barra EZ'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaBaixaCorda() {
  return const CatalogoExercicio(
    codigo: 'rosca_baixa_corda',
    nome: 'Rosca baixa (corda)',
    nomeCurto: 'Rosca baixa',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'polia',
    familia: 'Rosca na polia',
    variante: 'Corda',
    nivel: 'iniciante',
    popularidade: 75,
    ordem: 17,
    aliases: ['Rope Cable Curl', 'Cable Rope Curl', 'Rosca com corda'],
    gruposSecundarios: ['antebracos'],
  );
}

CatalogoExercicio roscaInversaBarra() {
  return const CatalogoExercicio(
    codigo: 'rosca_inversa_barra',
    nome: 'Rosca inversa (barra)',
    nomeCurto: 'Rosca inversa',
    grupoPrincipalCodigo: 'biceps',
    equipamento: 'barra',
    familia: 'Rosca inversa',
    variante: 'Barra',
    nivel: 'intermediario',
    popularidade: 65,
    ordem: 18,
    aliases: ['Reverse Barbell Curl', 'Reverse Curl', 'Rosca pronada'],
    gruposSecundarios: ['antebracos'],
  );
}

final catalogoBiceps = CatalogoGrupo(
  codigo: 'biceps',
  nome: 'Bíceps',
  exercicios: [
    roscaDiretaBarra(),
    roscaDiretaBarraW(),
    roscaDiretaHalteres(),
    roscaAlternadaHalteres(),
    roscaAlternadaSentada(),
    roscaAlternadaInclinada(),
    roscaMarteloHalteres(),
    roscaMarteloCruzada(),
    roscaMarteloCorda(),
    roscaScottBarraW(),
    roscaScottMaquina(),
    roscaScottUnilateral(),
    roscaConcentradaHalter(),
    roscaConcentradaPolia(),
    roscaBaixaBarraReta(),
    roscaBaixaBarraW(),
    roscaBaixaCorda(),
    roscaInversaBarra(),
  ],
);
