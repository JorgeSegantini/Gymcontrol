import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreinoDoDiaController extends ChangeNotifier {
  static const String _chaveData = 'treino_do_dia_data';
  static const String _chaveFichaId = 'treino_do_dia_ficha_id';
  static const String _chaveFichaNome = 'treino_do_dia_ficha_nome';

  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();

  DateTime? _data;
  int? _fichaId;
  String? _fichaNome;

  int? get fichaId => _ehHoje(_data) ? _fichaId : null;
  String? get fichaNome => _ehHoje(_data) ? _fichaNome : null;
  bool get possuiSubstituicaoHoje => fichaId != null;

  Future<void> carregar() async {
    final dataSalva = await _preferencias.getString(_chaveData);
    final fichaIdSalvo = await _preferencias.getInt(_chaveFichaId);
    final fichaNomeSalvo = await _preferencias.getString(_chaveFichaNome);

    _data = dataSalva == null ? null : DateTime.tryParse(dataSalva);
    _fichaId = fichaIdSalvo;
    _fichaNome = fichaNomeSalvo;

    if (!_ehHoje(_data)) {
      await limpar();
      return;
    }

    notifyListeners();
  }

  Future<void> definir({
    required int fichaId,
    required String fichaNome,
  }) async {
    final hoje = DateTime.now();
    _data = DateTime(hoje.year, hoje.month, hoje.day);
    _fichaId = fichaId;
    _fichaNome = fichaNome.trim();

    await _preferencias.setString(_chaveData, _formatarData(_data!));
    await _preferencias.setInt(_chaveFichaId, fichaId);
    await _preferencias.setString(_chaveFichaNome, _fichaNome!);

    notifyListeners();
  }

  Future<void> limpar() async {
    _data = null;
    _fichaId = null;
    _fichaNome = null;

    await _preferencias.remove(_chaveData);
    await _preferencias.remove(_chaveFichaId);
    await _preferencias.remove(_chaveFichaNome);

    notifyListeners();
  }

  bool _ehHoje(DateTime? data) {
    if (data == null) {
      return false;
    }

    final hoje = DateTime.now();

    return data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;
  }

  String _formatarData(DateTime data) {
    return '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }
}
