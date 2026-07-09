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
  late int _meta;
  late int _copo;
  late TimeOfDay _inicio;
  late TimeOfDay _fim;

  @override
  void initState() {
    super.initState();
    final c = widget.appState.config;
    _meta = c.metaMl;
    _copo = c.copoMl;
    _inicio = TimeOfDay(hour: c.inicioMinutos ~/ 60, minute: c.inicioMinutos % 60);
    _fim = TimeOfDay(hour: c.fimMinutos ~/ 60, minute: c.fimMinutos % 60);
  }

  int get _inicioMin => _inicio.hour * 60 + _inicio.minute;
  int get _fimMin => _fim.hour * 60 + _fim.minute;

  WaterConfig get _configAtual => WaterConfig(
    metaMl: _meta,
    copoMl: _copo,
    inicioMinutos: _inicioMin,
    fimMinutos: _fimMin,
  );

  Future<void> _salvar() async {
    if (_fimMin <= _inicioMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A hora de fim deve ser depois da hora de início.'),
        ),
      );
      return;
    }
    await widget.appState.atualizarConfig(_configAtual);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _StepperCard(
            titulo: 'Meta diária',
            helper: 'Ex.: 3000 ml = 3 litros',
            valor: _meta,
            suffix: 'ml',
            step: 250,
            min: 250,
            onChanged: (v) => setState(() => _meta = v),
          ),
          const SizedBox(height: 12),
          _StepperCard(
            titulo: 'Capacidade do copo',
            helper: 'Copo ou garrafinha. Ex.: 250 ml',
            valor: _copo,
            suffix: 'ml',
            step: 50,
            min: 50,
            onChanged: (v) => setState(() => _copo = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  rotulo: 'Início do dia',
                  icone: Icons.wb_sunny_outlined,
                  hora: _inicio,
                  onEscolher: (t) => setState(() => _inicio = t),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeCard(
                  rotulo: 'Fim do dia',
                  icone: Icons.bedtime_outlined,
                  hora: _fim,
                  onEscolher: (t) => setState(() => _fim = t),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Previa(config: _configAtual, inicioMin: _inicioMin, fimMin: _fimMin),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _salvar,
            icon: const Icon(Icons.check),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

/// Card com título + helper à esquerda e um stepper (− valor +) à direita.
/// Tocar no valor abre um campo para digitar livremente.
class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.titulo,
    required this.helper,
    required this.valor,
    required this.suffix,
    required this.step,
    required this.min,
    required this.onChanged,
  });

  final String titulo;
  final String helper;
  final int valor;
  final String suffix;
  final int step;
  final int min;
  final ValueChanged<int> onChanged;

  Future<void> _editar(BuildContext context) async {
    final ctrl = TextEditingController(text: valor.toString());
    final novo = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: suffix),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (novo != null && novo >= min) onChanged(novo);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    helper,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    onTap: valor - step >= min
                        ? () => onChanged(valor - step)
                        : null,
                  ),
                  GestureDetector(
                    onTap: () => _editar(context),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 68),
                      child: Text(
                        '$valor',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    onTap: () => onChanged(valor + step),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 20),
      color: cs.primary,
      disabledColor: cs.onSurfaceVariant.withValues(alpha: 0.4),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.rotulo,
    required this.icone,
    required this.hora,
    required this.onEscolher,
  });

  final String rotulo;
  final IconData icone;
  final TimeOfDay hora;
  final ValueChanged<TimeOfDay> onEscolher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final t = await showTimePicker(context: context, initialTime: hora);
          if (t != null) onEscolher(t);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icone, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    rotulo,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(hora.format(context), style: textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Previa extends StatelessWidget {
  const _Previa({
    required this.config,
    required this.inicioMin,
    required this.fimMin,
  });

  final WaterConfig config;
  final int inicioMin;
  final int fimMin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (fimMin <= inicioMin) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Ajuste os horários: o fim precisa ser depois do início.',
          style: textTheme.bodyMedium?.copyWith(color: cs.error),
        ),
      );
    }

    final lembretes = calcularLembretes(config);
    final espaco = lembretes.length > 1
        ? ((fimMin - inicioMin) / (lembretes.length - 1)).round()
        : 0;
    final agrupa = lembretes.any((l) => l.copos > 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surfaceContainer, cs.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined,
                  size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text('Prévia dos lembretes', style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          _LinhaPrevia(rotulo: 'Copos no dia', valor: '${config.totalCopos}'),
          _LinhaPrevia(rotulo: 'Lembretes', valor: '${lembretes.length}'),
          if (espaco > 0)
            _LinhaPrevia(rotulo: 'Intervalo', valor: '~$espaco min'),
          if (agrupa)
            const _LinhaPrevia(
              rotulo: 'Agrupamento',
              valor: 'alguns lembretes juntam copos',
            ),
        ],
      ),
    );
  }
}

class _LinhaPrevia extends StatelessWidget {
  const _LinhaPrevia({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            rotulo,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
