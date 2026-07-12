# Contador de Água

App Flutter de lembretes de hidratação. Você monta um cronograma de copos ao
longo do dia, o app agenda as notificações e acompanha o consumo real contra a
meta — mostrando se você está em dia ou atrasado.

Tudo roda **local no aparelho**: não há backend, contas nem rede. Os dados ficam
em `shared_preferences` e os lembretes são notificações locais agendadas.

## Rodando

```bash
flutter pub get
flutter run
```

## Estrutura

| Caminho | Papel |
|---|---|
| `lib/models/` | `WaterConfig` — meta diária, tamanho do copo, janela de horários |
| `lib/services/schedule.dart` | Deriva a lista de lembretes a partir da config |
| `lib/services/notifications.dart` | Agenda/cancela as notificações locais |
| `lib/services/storage.dart` | Persistência em `shared_preferences` |
| `lib/state/app_state.dart` | Estado da aplicação |
| `lib/theme/` | Tema **Deep Ocean** (navy + ciano, Manrope) e tokens de cor |

## Notas de plataforma

**Alarmes inexatos.** Os lembretes usam `inexactAllowWhileIdle`. A política da
Play restringe alarme exato (`USE_EXACT_ALARM`/`SCHEDULE_EXACT_ALARM`) a apps
cuja função principal é despertador, calendário ou timer — lembrete de
hidratação não se qualifica. Na prática o sistema pode atrasar o lembrete alguns
minutos, o que é irrelevante aqui.

**Assets gerados.** Após alterar as artes ou as cores do tema:

```bash
dart run flutter_launcher_icons       # mipmaps do launcher (a partir de assets/icon/)
dart run flutter_native_splash:create # splash nativa
```

O ícone em si é desenhado por [`assets/icon/gen_icon.py`](assets/icon/gen_icon.py)
(precisa de Pillow), que gera a gota com o gradiente do tema.

## Build de release

A assinatura lê `android/key.properties`, que **não é versionado**. Sem ele o
build de release cai na chave de debug — suficiente para `flutter run --release`,
mas não para publicar. Para gerar o bundle de upload:

```bash
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab
```
