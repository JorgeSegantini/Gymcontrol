import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilLocalController extends ChangeNotifier {
  static const String _chaveNome = 'perfil_nome';

  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();

  String? _nome;
  bool _carregando = true;

  String? get nome => _nome;
  bool get carregando => _carregando;
  bool get configurado => _nome != null && _nome!.trim().isNotEmpty;

  Future<void> carregar() async {
    final nomeSalvo = await _preferencias.getString(_chaveNome);
    final nomeNormalizado = nomeSalvo?.trim();

    _nome = nomeNormalizado == null || nomeNormalizado.isEmpty
        ? null
        : nomeNormalizado;
    _carregando = false;
    notifyListeners();
  }

  Future<void> alterarNome(String nome) async {
    final nomeNormalizado = nome.trim();

    if (nomeNormalizado.isEmpty) {
      throw ArgumentError('O nome é obrigatório.');
    }

    _nome = nomeNormalizado;
    notifyListeners();
    await _preferencias.setString(_chaveNome, nomeNormalizado);
  }
}
