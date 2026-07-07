import 'package:flutter/foundation.dart';

import '../models/water_config.dart';
import '../services/notifications.dart';
import '../services/schedule.dart';
import '../services/storage.dart';

/// Estado central do app: configuração, copos bebidos e reset diário.
class AppState extends ChangeNotifier {
  AppState(this._storage, this._notifications);

  final Storage _storage;
  final NotificationsService _notifications;

  WaterConfig _config = WaterConfig.padrao;
  Set<int> _coposBebidos = <int>{};
  List<Lembrete> _lembretes = const [];
  bool _carregando = true;

  WaterConfig get config => _config;
  Set<int> get coposBebidos => _coposBebidos;
  List<Lembrete> get lembretes => _lembretes;
  bool get carregando => _carregando;

  int get totalCopos => _config.totalCopos;
  int get coposRestantes =>
      (totalCopos - _coposBebidos.length).clamp(0, totalCopos);
  int get mlBebidos => _coposBebidos.length * _config.copoMl;
  double get progresso =>
      totalCopos == 0 ? 0 : (_coposBebidos.length / totalCopos).clamp(0.0, 1.0);

  Future<void> inicializar() async {
    _config = await _storage.carregarConfig();
    _lembretes = calcularLembretes(_config);
    await _garantirDiaAtual();
    final salvos = await _storage.carregarCoposBebidos();
    _coposBebidos = salvos.where((i) => i < totalCopos).toSet();
    _carregando = false;
    notifyListeners();
  }

  /// Pede permissões e agenda os lembretes. Chamado após o primeiro frame,
  /// para o diálogo de permissão aparecer com o app já visível.
  Future<void> pedirPermissoesEReagendar() async {
    await _notifications.pedirPermissoes();
    await _notifications.reagendar(_lembretes, copoMl: _config.copoMl);
  }

  Future<void> alternarCopo(int index) async {
    if (!_coposBebidos.add(index)) {
      _coposBebidos.remove(index);
    }
    await _storage.salvarCoposBebidos(_coposBebidos);
    notifyListeners();
  }

  /// Marca o próximo copo ainda não bebido (ação do botão principal).
  Future<void> beberProximo() async {
    for (var i = 0; i < totalCopos; i++) {
      if (!_coposBebidos.contains(i)) {
        await alternarCopo(i);
        return;
      }
    }
  }

  Future<void> atualizarConfig(WaterConfig novo) async {
    _config = novo;
    await _storage.salvarConfig(novo);
    _lembretes = calcularLembretes(novo);
    _coposBebidos = _coposBebidos.where((i) => i < totalCopos).toSet();
    await _storage.salvarCoposBebidos(_coposBebidos);
    await _notifications.reagendar(_lembretes, copoMl: novo.copoMl);
    notifyListeners();
  }

  /// Verifica, ao voltar para o app, se o dia lógico virou e reseta se preciso.
  Future<void> aoRetomar() async {
    if (await _garantirDiaAtual()) {
      final salvos = await _storage.carregarCoposBebidos();
      _coposBebidos = salvos.where((i) => i < totalCopos).toSet();
      notifyListeners();
    }
  }

  /// Reseta o progresso se o dia lógico (que começa na hora de início) mudou.
  /// Retorna `true` se resetou.
  Future<bool> _garantirDiaAtual() async {
    final hoje = _diaLogicoAtual();
    final salvo = await _storage.carregarDiaLogico();
    if (salvo == hoje) return false;
    await _storage.salvarCoposBebidos(<int>{});
    await _storage.salvarDiaLogico(hoje);
    _coposBebidos = <int>{};
    return true;
  }

  /// Data (yyyy-MM-dd) do "dia lógico" atual. O limite entre um dia e outro é a
  /// hora de início configurada — antes dela, ainda conta como o dia anterior.
  String _diaLogicoAtual() {
    final agora = DateTime.now();
    final minutosAgora = agora.hour * 60 + agora.minute;
    final base = minutosAgora < _config.inicioMinutos
        ? agora.subtract(const Duration(days: 1))
        : agora;
    final y = base.year.toString().padLeft(4, '0');
    final m = base.month.toString().padLeft(2, '0');
    final d = base.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
