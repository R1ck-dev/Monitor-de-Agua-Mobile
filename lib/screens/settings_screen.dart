import 'package:flutter/material.dart';

import '../models/water_config.dart';
import '../services/schedule.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _metaCtrl;
  late final TextEditingController _copoCtrl;
  late TimeOfDay _inicio;
  late TimeOfDay _fim;

  @override
  void initState() {
    super.initState();
    final c = widget.appState.config;
    _metaCtrl = TextEditingController(text: c.metaMl.toString());
    _copoCtrl = TextEditingController(text: c.copoMl.toString());
    _inicio = TimeOfDay(hour: c.inicioMinutos ~/ 60, minute: c.inicioMinutos % 60);
    _fim = TimeOfDay(hour: c.fimMinutos ~/ 60, minute: c.fimMinutos % 60);
  }

  @override
  void dispose() {
    _metaCtrl.dispose();
    _copoCtrl.dispose();
    super.dispose();
  }

  int get _inicioMin => _inicio.hour * 60 + _inicio.minute;
  int get _fimMin => _fim.hour * 60 + _fim.minute;

  WaterConfig? _configAtual() {
    final meta = int.tryParse(_metaCtrl.text);
    final copo = int.tryParse(_copoCtrl.text);
    if (meta == null || copo == null || meta <= 0 || copo <= 0) return null;
    return WaterConfig(
      metaMl: meta,
      copoMl: copo,
      inicioMinutos: _inicioMin,
      fimMinutos: _fimMin,
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fimMin <= _inicioMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A hora de fim deve ser depois da hora de início.'),
        ),
      );
      return;
    }
    final cfg = _configAtual();
    if (cfg == null) return;
    await widget.appState.atualizarConfig(cfg);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _metaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meta diária',
                suffixText: 'ml',
                helperText: 'Ex.: 3000 ml = 3 litros',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'Informe um valor válido',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _copoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidade do copo/garrafinha',
                suffixText: 'ml',
                helperText: 'Ex.: 250 ml',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'Informe um valor válido',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _TileHora(
              titulo: 'Início do dia',
              hora: _inicio,
              onEscolher: (t) => setState(() => _inicio = t),
            ),
            _TileHora(
              titulo: 'Fim do dia',
              hora: _fim,
              onEscolher: (t) => setState(() => _fim = t),
            ),
            const SizedBox(height: 16),
            _Previa(config: _configAtual(), inicioMin: _inicioMin, fimMin: _fimMin),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileHora extends StatelessWidget {
  const _TileHora({
    required this.titulo,
    required this.hora,
    required this.onEscolher,
  });

  final String titulo;
  final TimeOfDay hora;
  final ValueChanged<TimeOfDay> onEscolher;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(titulo),
      trailing: Text(
        hora.format(context),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: hora);
        if (t != null) onEscolher(t);
      },
    );
  }
}

class _Previa extends StatelessWidget {
  const _Previa({
    required this.config,
    required this.inicioMin,
    required this.fimMin,
  });

  final WaterConfig? config;
  final int inicioMin;
  final int fimMin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (config == null) return const SizedBox.shrink();
    if (fimMin <= inicioMin) {
      return Text(
        'Ajuste os horários: o fim precisa ser depois do início.',
        style: TextStyle(color: scheme.error),
      );
    }

    final lembretes = calcularLembretes(config!);
    final espaco = lembretes.length > 1
        ? ((fimMin - inicioMin) / (lembretes.length - 1)).round()
        : 0;
    final agrupa = lembretes.any((l) => l.copos > 1);

    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prévia', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text('• ${config!.totalCopos} copos no dia'),
            Text('• ${lembretes.length} lembretes'),
            if (espaco > 0) Text('• 1 lembrete a cada ~$espaco min'),
            if (agrupa) const Text('• alguns lembretes agrupam mais de 1 copo'),
          ],
        ),
      ),
    );
  }
}
