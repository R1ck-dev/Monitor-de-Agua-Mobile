import 'package:flutter/material.dart';

import '../state/app_state.dart';
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contador de Água'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configurações',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(appState: s),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: s.carregando || s.coposRestantes == 0
              ? null
              : FloatingActionButton.extended(
                  onPressed: s.beberProximo,
                  icon: const Icon(Icons.local_drink),
                  label: const Text('Bebi um copo'),
                ),
          body: s.carregando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _Cabecalho(state: s),
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pct = (state.progresso * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: state.progresso,
                        strokeWidth: 7,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Text('$pct%', style: textTheme.labelLarge),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.coposBebidos.length} de ${state.totalCopos} copos',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.mlBebidos} ml de ${state.config.metaMl} ml',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.coposRestantes > 0
                          ? 'Faltam ${state.coposRestantes} copos'
                          : 'Meta atingida! 🎉',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusHorario(state: state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compara o consumo com o cronograma: mostra quantos copos o usuário já
/// deveria ter bebido neste horário e se está atrasado, em dia ou adiantado.
class _StatusHorario extends StatelessWidget {
  const _StatusHorario({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final esperados = state.coposEsperados;
    final atraso = state.coposAtrasados; // >0 atrasado, 0 em dia, <0 adiantado

    final IconData icone;
    final Color cor;
    final String texto;
    if (atraso > 0) {
      icone = Icons.warning_amber_rounded;
      cor = scheme.error;
      texto = 'Você está $atraso ${_copos(atraso)} atrás do horário';
    } else if (atraso < 0) {
      icone = Icons.trending_up;
      cor = scheme.primary;
      texto = 'Adiantado em ${-atraso} ${_copos(-atraso)}';
    } else {
      icone = Icons.check_circle_outline;
      cor = scheme.primary;
      texto = 'Em dia com o horário';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 16, color: cor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                texto,
                style: textTheme.bodyMedium?.copyWith(
                  color: cor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Ideal até agora: $esperados de ${state.totalCopos} copos',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  static String _copos(int n) => n == 1 ? 'copo' : 'copos';
}

class _GradeCopos extends StatelessWidget {
  const _GradeCopos({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.totalCopos == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Defina sua meta nas configurações (ícone de engrenagem).'),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 88,
        childAspectRatio: 0.78,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: state.totalCopos,
      itemBuilder: (context, i) => WaterCup(
        bebido: state.coposBebidos.contains(i),
        atrasado: state.estaAtrasado(i),
        onTap: () => state.alternarCopo(i),
      ),
    );
  }
}
