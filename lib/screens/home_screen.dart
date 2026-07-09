import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/progress_ring.dart';
import '../widgets/water_cup.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.pedirPermissoesEReagendar();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.appState.aoRetomar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final s = widget.appState;
        final cs = Theme.of(context).colorScheme;
        final metaAtingida = !s.carregando && s.coposRestantes == 0;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                Icon(Icons.water_drop, color: cs.primary, size: 24),
                const SizedBox(width: 8),
                const Text('Contador de Água'),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Material(
                  color: cs.surfaceContainerLow,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Configurações',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(appState: s),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: IgnorePointer(
            ignoring: metaAtingida,
            child: AnimatedScale(
              scale: metaAtingida ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: FloatingActionButton.extended(
                onPressed: s.beberProximo,
                icon: const Icon(Icons.local_drink),
                label: const Text('Bebi um copo'),
              ),
            ),
          ),
          body: s.carregando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _Cabecalho(state: s),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ChipStatus(state: s),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: _GradeCopos(state: s)),
                  ],
                ),
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ProgressRing(progress: state.progresso, size: 132),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.coposBebidos.length} de ${state.totalCopos}',
                    style: textTheme.displaySmall,
                  ),
                  Text(
                    'COPOS HOJE',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    '${state.mlBebidos} / ${state.config.metaMl} ml',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.coposRestantes > 0
                        ? 'Faltam ${state.coposRestantes} ${_copos(state.coposRestantes)}'
                        : 'Meta atingida',
                    style: textTheme.bodySmall?.copyWith(
                      color: state.coposRestantes > 0
                          ? cs.onSurfaceVariant
                          : Theme.of(context).extension<AppTokens>()!.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _copos(int n) => n == 1 ? 'copo' : 'copos';
}

/// Compara o consumo com o cronograma: mostra se o usuário está atrasado, em dia
/// ou adiantado. A cor de fundo e do texto interpolam sozinhas na transição.
class _ChipStatus extends StatelessWidget {
  const _ChipStatus({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;

    final esperados = state.coposEsperados;
    final atraso = state.coposAtrasados; // >0 atrasado, 0 em dia, <0 adiantado

    final IconData icone;
    final Color cor;
    final String texto;
    if (atraso > 0) {
      icone = Icons.error_outline_rounded;
      cor = tokens.overdue;
      texto = 'Você está $atraso ${_copos(atraso)} atrás do horário';
    } else if (atraso < 0) {
      icone = Icons.trending_up_rounded;
      cor = tokens.success;
      texto = 'Adiantado em ${-atraso} ${_copos(-atraso)}';
    } else {
      icone = Icons.check_circle_outline_rounded;
      cor = tokens.success;
      texto = 'Em dia com o horário';
    }

    final fundo = atraso > 0 ? tokens.overdueContainer : cs.surfaceContainer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 350),
                  style: textTheme.titleMedium!.copyWith(color: cor),
                  child: Text(texto),
                ),
                Text(
                  'Ideal até agora: $esperados de ${state.totalCopos} copos',
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _copos(int n) => n == 1 ? 'copo' : 'copos';
}

class _GradeCopos extends StatelessWidget {
  const _GradeCopos({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (state.totalCopos == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Defina sua meta nas configurações (ícone de engrenagem).',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COPOS DE HOJE',
                style: textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                'toque para marcar',
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: state.totalCopos,
            itemBuilder: (context, i) => WaterCup(
              bebido: state.coposBebidos.contains(i),
              atrasado: state.estaAtrasado(i),
              index: i,
              total: state.totalCopos,
              onTap: () => state.alternarCopo(i),
            ),
          ),
        ),
      ],
    );
  }
}
