class CodigoFormatador {
  const CodigoFormatador._();

  static String grupoMuscular(int id) {
    return 'GM-${id.toString().padLeft(6, '0')}';
  }

  static String exercicio(int id) {
    return 'EX-${id.toString().padLeft(6, '0')}';
  }

  static String fichaTreino(int id) {
    return 'FT-${id.toString().padLeft(6, '0')}';
  }

  static String treino(int id) {
    return 'TR-${id.toString().padLeft(6, '0')}';
  }

  static String serie(int id) {
    return 'SR-${id.toString().padLeft(6, '0')}';
  }

  static String pesoCorporal(int id) {
    return 'PC-${id.toString().padLeft(6, '0')}';
  }

  static String medidaCorporal(int id) {
    return 'MC-${id.toString().padLeft(6, '0')}';
  }
}
