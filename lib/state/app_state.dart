import 'dart:async';

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
  Timer? _timerVirada;

  WaterConfig get config => _config;
  Set<int> get coposBebidos => _coposBebidos;
  List<Lembrete> get lembretes => _lembretes;
  bool get carregando => _carregando;

  int get totalCopos => _config.totalCopos;
  int get coposRestantes =>
      (totalCopos - _coposBebidos.length).clamp(0, totalCopos);

  /// Volume consumido hoje. Modelo simples: copos bebidos × tamanho atual do
  /// copo. Consequência conhecida: mudar o tamanho do copo reescala o total do
  /// dia (a unidade do app é "copos", não ml gravados individualmente).
  int get mlBebidos => _coposBebidos.length * _config.copoMl;

  double get progresso =>
      totalCopos == 0 ? 0 : (_coposBebidos.length / totalCopos).clamp(0.0, 1.0);

  Future<void> inicializar() async {
    _config = await _storage.carregarConfig();
    _lembretes = calcularLembretes(_config);
    await _garantirDiaAtual();
    final salvos = await _storage.carregarCoposBebidos();
    _coposBebidos = _preservarContagem(salvos, totalCopos);
    _carregando = false;
    _agendarViradaDeDia();
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
    // Preserva a CONTAGEM de copos bebidos (reindexando só se o total encolheu),
    // em vez de descartar índices altos — evita perda de dados.
    _coposBebidos = _preservarContagem(_coposBebidos, totalCopos);
    await _storage.salvarCoposBebidos(_coposBebidos);
    // Reancora o dia lógico à nova config: a hora de início pode ter mudado, e
    // sem isso o próximo resume detectaria uma "virada" falsa e resetaria tudo.
    await _storage.salvarDiaLogico(_diaLogicoAtual());
    await _notifications.reagendar(_lembretes, copoMl: novo.copoMl);
    _agendarViradaDeDia();
    notifyListeners();
  }

  /// Verifica, ao voltar para o app, se o dia lógico virou e reseta se preciso.
  Future<void> aoRetomar() async {
    if (await _garantirDiaAtual()) {
      final salvos = await _storage.carregarCoposBebidos();
      _coposBebidos = _preservarContagem(salvos, totalCopos);
      notifyListeners();
    }
    _agendarViradaDeDia();
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

  /// Mantém a quantidade de copos bebidos ao mudar a config: se nada estourou o
  /// novo total, preserva os índices exatos; se o total encolheu, reindexa para
  /// os primeiros índices, preservando a contagem (nunca perde dados).
  Set<int> _preservarContagem(Set<int> bebidos, int total) {
    if (total <= 0) return <int>{};
    final dentro = bebidos.where((i) => i < total);
    if (dentro.length == bebidos.length) return bebidos.toSet();
    final n = bebidos.length < total ? bebidos.length : total;
    return {for (var i = 0; i < n; i++) i};
  }

  /// Agenda uma verificação para a próxima virada de dia lógico. Cobre o caso do
  /// app ficar aberto em foreground quando o relógio cruza a hora de início
  /// (quando não há transição de ciclo de vida que dispararia [aoRetomar]).
  void _agendarViradaDeDia() {
    _timerVirada?.cancel();
    final agora = DateTime.now();
    var alvo = DateTime(
      agora.year,
      agora.month,
      agora.day,
      _config.inicioMinutos ~/ 60,
      _config.inicioMinutos % 60,
    );
    if (!alvo.isAfter(agora)) {
      alvo = DateTime(
        agora.year,
        agora.month,
        agora.day + 1,
        _config.inicioMinutos ~/ 60,
        _config.inicioMinutos % 60,
      );
    }
    // Pequeno buffer para garantir que o relógio já passou da fronteira.
    final espera = alvo.difference(agora) + const Duration(seconds: 2);
    _timerVirada = Timer(espera, aoRetomar);
  }

  /// Data (yyyy-MM-dd) do "dia lógico" atual. O limite entre um dia e outro é a
  /// hora de início configurada — antes dela, ainda conta como o dia anterior.
  String _diaLogicoAtual() {
    final agora = DateTime.now();
    final minutosAgora = agora.hour * 60 + agora.minute;
    // Constrói a data por componentes (não subtrai 24h fixas) para não cair no
    // dia errado em transições de horário de verão (dias de 23h/25h).
    final base = minutosAgora < _config.inicioMinutos
        ? DateTime(agora.year, agora.month, agora.day - 1)
        : DateTime(agora.year, agora.month, agora.day);
    final y = base.year.toString().padLeft(4, '0');
    final m = base.month.toString().padLeft(2, '0');
    final d = base.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  void dispose() {
    _timerVirada?.cancel();
    super.dispose();
  }
}
