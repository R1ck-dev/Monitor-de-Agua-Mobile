import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/notifications.dart';
import 'services/storage.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notifications = NotificationsService.instance;
  await notifications.inicializar();

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
