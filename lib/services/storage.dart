import 'package:shared_preferences/shared_preferences.dart';

import '../models/water_config.dart';

/// Persistência local (offline) via SharedPreferences.
class Storage {
  const Storage();

  static const String _kConfig = 'config';
  static const String _kCopos = 'coposBebidosIdx';
  static const String _kDia = 'diaLogico';

  Future<WaterConfig> carregarConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kConfig);
    if (raw == null) return WaterConfig.padrao;
    try {
      return WaterConfig.fromJson(raw);
    } catch (_) {
      return WaterConfig.padrao;
    }
  }

  Future<void> salvarConfig(WaterConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kConfig, config.toJson());
  }

  /// Índices dos copos já bebidos no dia atual.
  Future<Set<int>> carregarCoposBebidos() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_kCopos) ?? const [];
    return lista.map(int.parse).toSet();
  }

  Future<void> salvarCoposBebidos(Set<int> indices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kCopos,
      indices.map((e) => e.toString()).toList(),
    );
  }

  /// Data (yyyy-MM-dd) do último dia lógico registrado, para o reset diário.
  Future<String?> carregarDiaLogico() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDia);
  }

  Future<void> salvarDiaLogico(String dia) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDia, dia);
  }
}
