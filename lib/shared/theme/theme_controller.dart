import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _chaveTema = 'tema_app';

  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();

  ThemeMode _themeMode = ThemeMode.system;
  bool _carregando = true;

  ThemeMode get themeMode => _themeMode;

  bool get carregando => _carregando;

  Future<void> carregar() async {
    final valorSalvo = await _preferencias.getString(_chaveTema);

    _themeMode = _converterValorSalvo(valorSalvo);
    _carregando = false;
    notifyListeners();
  }

  Future<void> alterarTema(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();

    await _preferencias.setString(
      _chaveTema,
      _converterTemaParaValor(themeMode),
    );
  }

  ThemeMode _converterValorSalvo(String? valor) {
    return switch (valor) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  String _converterTemaParaValor(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
