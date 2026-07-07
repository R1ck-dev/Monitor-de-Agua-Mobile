import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/notifications.dart';
import 'services/storage.dart';
import 'state/app_state.dart';

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
    const seed = Color(0xFF1E88E5); // azul água
    return MaterialApp(
      title: 'Contador de Água',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(appState: appState),
    );
  }
}
