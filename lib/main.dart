import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/notifications.dart';
import 'services/storage.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A inicialização de notificações/timezone (que carrega o banco de fusos e
  // faz chamadas de plataforma) NÃO bloqueia o primeiro frame: ela roda de
  // forma preguiçosa dentro de `pedirPermissoesEReagendar`, chamado num
  // post-frame callback com o app já visível. Aqui só carregamos o estado
  // local (SharedPreferences), que é rápido, antes de pintar a tela.
  final notifications = NotificationsService.instance;
  final appState = AppState(const Storage(), notifications);
  await appState.inicializar();

  runApp(ContadorDeAguaApp(appState: appState));
}

class ContadorDeAguaApp extends StatelessWidget {
  const ContadorDeAguaApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador de Água',
      debugShowCheckedModeBanner: false,
      theme: appTheme(oceanLight, oceanLightTokens),
      darkTheme: appTheme(oceanDark, oceanDarkTokens),
      themeAnimationDuration: const Duration(milliseconds: 300),
      home: HomeScreen(appState: appState),
    );
  }
}
