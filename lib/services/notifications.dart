import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'schedule.dart';

/// Encapsula o flutter_local_notifications: inicialização, permissões e
/// agendamento dos lembretes silenciosos.
class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _canalId = 'lembretes_agua';
  static const String _canalNome = 'Lembretes de água';
  static const String _canalDescricao =
      'Lembretes silenciosos para beber água ao longo do dia';

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    tzdata.initializeTimeZones();
    final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _inicializado = true;
  }

  /// Pede permissão de notificação (Android 13+/iOS).
  Future<void> pedirPermissoes() async {
    await inicializar();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: false, sound: false);
  }

  /// Cancela tudo e reagenda os lembretes, um por horário, repetindo todo dia.
  Future<void> reagendar(
    List<Lembrete> lembretes, {
    required int copoMl,
  }) async {
    await inicializar();
    await _plugin.cancelAll();

    final detalhes = NotificationDetails(
      android: AndroidNotificationDetails(
        _canalId,
        _canalNome,
        channelDescription: _canalDescricao,
        importance: Importance.low, // silencioso, sem heads-up nem som
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    );

    for (var i = 0; i < lembretes.length; i++) {
      final l = lembretes[i];
      final ml = l.copos * copoMl;
      final corpo = l.copos == 1
          ? 'Tome 1 copo ($ml ml) 💧'
          : 'Tome ${l.copos} copos ($ml ml) 💧';

      await _plugin.zonedSchedule(
        id: i,
        title: 'Hora de beber água',
        body: corpo,
        scheduledDate: _proximaOcorrencia(l.hora, l.minuto),
        notificationDetails: detalhes,
        // Inexato de propósito — ver o comentário no AndroidManifest. O
        // `allowWhileIdle` mantém a entrega mesmo em Doze, só sem hora cravada.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repete diariamente
      );
    }
  }

  Future<void> cancelarTudo() => _plugin.cancelAll();

  tz.TZDateTime _proximaOcorrencia(int hora, int minuto) {
    final agora = tz.TZDateTime.now(tz.local);
    var data = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      hora,
      minuto,
    );
    if (!data.isAfter(agora)) {
      data = data.add(const Duration(days: 1));
    }
    return data;
  }
}
