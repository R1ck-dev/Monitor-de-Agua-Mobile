# Contador de Água — Guia de implementação Flutter

Handoff do redesign visual. Stack mantida: **Flutter + Material 3 (`useMaterial3: true`)**.
Escopo: só o visual — mesmas 2 telas (Home + Configurações) e o mesmo fluxo.

Duas direções foram prototipadas. Este guia entrega os tokens das **duas**; escolha uma
(ou misture). Onde há trade-off, a recomendação vem marcada com **▶**.

- **1a — Deep Ocean** (recomendada p/ “premium e sério”): navy + ciano, fonte **Manrope**, copo de vidro com reflexo.
- **1b — Aqua Fresh**: teal/aqua, fonte **Plus Jakarta Sans**, copo geométrico.

> Todos os hex abaixo são exatamente os usados no protótipo.

---

## 1. Conceito de design

Água como **luz atravessando líquido**: superfícies calmas e quase neutras, um único
azul/ciano vivo como “a água”, e todo o resto em tons frios de baixa saturação. A
identidade vem do **copo que enche** (nível real de água + menisco) e do **anel com
gradiente** — não de decoração. Menos cartões “pesados”, mais respiro, tipografia com
números tabulares (o app é cheio de ml / % / copos). Nada de gradiente de fundo, nada de
emoji: a celebração é o próprio anel brilhando + estado verde “em dia”.

O que muda vs. hoje: paleta única → paleta com papéis claros (primária/água/sucesso/
atraso); cards default → cantos 20–26, sombra suave; ícone de copo cônico cru → copo com
nível animado em 3 estados; `CircularProgressIndicator` → anel com gradiente e animação.

---

## 2. Sistema de design (tokens)

### 2.1 Paleta / `ColorScheme`

Material não tem papel “sucesso” nem “água”; use `ColorScheme.fromSeed` + `copyWith` para
ancorar os papéis e uma **`ThemeExtension`** para os tokens extras (água, sucesso, atraso).

```dart
import 'package:flutter/material.dart';

// ---- Tokens extras (água, sucesso, atraso) ----
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color waterTop, waterBottom, success, overdue, overdueContainer, cupLine;
  const AppTokens({
    required this.waterTop, required this.waterBottom, required this.success,
    required this.overdue, required this.overdueContainer, required this.cupLine,
  });
  @override
  AppTokens copyWith({Color? waterTop, Color? waterBottom, Color? success,
      Color? overdue, Color? overdueContainer, Color? cupLine}) => AppTokens(
    waterTop: waterTop ?? this.waterTop, waterBottom: waterBottom ?? this.waterBottom,
    success: success ?? this.success, overdue: overdue ?? this.overdue,
    overdueContainer: overdueContainer ?? this.overdueContainer, cupLine: cupLine ?? this.cupLine);
  @override
  AppTokens lerp(ThemeExtension<AppTokens>? o, double t) {
    if (o is! AppTokens) return this;
    return AppTokens(
      waterTop: Color.lerp(waterTop, o.waterTop, t)!,
      waterBottom: Color.lerp(waterBottom, o.waterBottom, t)!,
      success: Color.lerp(success, o.success, t)!,
      overdue: Color.lerp(overdue, o.overdue, t)!,
      overdueContainer: Color.lerp(overdueContainer, o.overdueContainer, t)!,
      cupLine: Color.lerp(cupLine, o.cupLine, t)!,
    );
  }
}
```

#### ▶ 1a — Deep Ocean

```dart
// LIGHT
final oceanLight = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0E6FE0), brightness: Brightness.light,
).copyWith(
  primary: const Color(0xFF0E6FE0),
  onPrimary: const Color(0xFFFFFFFF),
  surface: const Color(0xFFEDF3FA),               // fundo da tela
  surfaceContainerLowest: const Color(0xFFFFFFFF),// cards
  surfaceContainerLow: const Color(0xFFF2F7FC),   // campos / steppers
  surfaceContainer: const Color(0xFFEAF2FB),      // chips / prévia
  onSurface: const Color(0xFF0B2743),
  onSurfaceVariant: const Color(0xFF526478),      // texto secundário
  outlineVariant: const Color(0xFFE3ECF4),        // trilho do anel / divisórias
  error: const Color(0xFFDD4B36),
  errorContainer: const Color(0xFFFBEAE6),
);
const oceanLightTokens = AppTokens(
  waterTop: Color(0xFF57BBF6), waterBottom: Color(0xFF0E7CD8),
  success: Color(0xFF10A085), overdue: Color(0xFFDD4B36),
  overdueContainer: Color(0xFFFBEAE6), cupLine: Color(0x380B2743), // 22%
);

// DARK
final oceanDark = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0E6FE0), brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFF3AB6F4),
  onPrimary: const Color(0xFF052238),
  surface: const Color(0xFF08182A),
  surfaceContainerLowest: const Color(0xFF0C1E30),
  surfaceContainerLow: const Color(0xFF0F2438),
  surfaceContainer: const Color(0xFF152E46),
  onSurface: const Color(0xFFEAF3FB),
  onSurfaceVariant: const Color(0xFF9EB5CD),
  outlineVariant: const Color(0x17FFFFFF),         // ~9% branco
  error: const Color(0xFFFF6B54),
  errorContainer: const Color(0xFF331915),
);
const oceanDarkTokens = AppTokens(
  waterTop: Color(0xFF7CD0FB), waterBottom: Color(0xFF1E92E6),
  success: Color(0xFF2FD3B0), overdue: Color(0xFFFF6B54),
  overdueContainer: Color(0xFF331915), cupLine: Color(0x38FFFFFF),
);
```

#### 1b — Aqua Fresh

```dart
// LIGHT
final aquaLight = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0AA6B8), brightness: Brightness.light,
).copyWith(
  primary: const Color(0xFF0AA6B8), onPrimary: const Color(0xFFFFFFFF),
  surface: const Color(0xFFE9F6F7), surfaceContainerLowest: const Color(0xFFFFFFFF),
  surfaceContainerLow: const Color(0xFFF0FAFB), surfaceContainer: const Color(0xFFE3F7F8),
  onSurface: const Color(0xFF08363B), onSurfaceVariant: const Color(0xFF496C70),
  outlineVariant: const Color(0xFFDAEFF0),
  error: const Color(0xFFE76A4E), errorContainer: const Color(0xFFFCEBE6),
);
const aquaLightTokens = AppTokens(
  waterTop: Color(0xFF37D3DF), waterBottom: Color(0xFF0AA6B8),
  success: Color(0xFF10A085), overdue: Color(0xFFE76A4E),
  overdueContainer: Color(0xFFFCEBE6), cupLine: Color(0x3808363B));

// DARK
final aquaDark = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0AA6B8), brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFF22D3C4), onPrimary: const Color(0xFF042321),
  surface: const Color(0xFF042321), surfaceContainerLowest: const Color(0xFF072B28),
  surfaceContainerLow: const Color(0xFF0B332F), surfaceContainer: const Color(0xFF0F453F),
  onSurface: const Color(0xFFE6FBF8), onSurfaceVariant: const Color(0xFF8FBDB8),
  outlineVariant: const Color(0x17FFFFFF),
  error: const Color(0xFFFF7A5E), errorContainer: const Color(0xFF33201A),
);
const aquaDarkTokens = AppTokens(
  waterTop: Color(0xFF5EEAD8), waterBottom: Color(0xFF16B6A6),
  success: Color(0xFF34D39A), overdue: Color(0xFFFF7A5E),
  overdueContainer: Color(0xFF33201A), cupLine: Color(0x38FFFFFF));
```

**Como ler os papéis:** `surface` = fundo da tela · `surfaceContainerLowest` = cards ·
`surfaceContainerLow` = campos/steppers · `surfaceContainer` = chips/prévia ·
`onSurfaceVariant` = texto secundário · `outlineVariant` = trilho do anel e divisórias.
Nunca mais use `primary` puro para texto grande — ele é só para a “água” e ações.

### 2.2 Tipografia

▶ **Manrope** (1a) — geométrica, discreta, ótimos numerais; via `google_fonts`.
Alternativa 1b: **Plus Jakarta Sans**. Ative **números tabulares** nos estilos de número
(ml, %, copos) pra eles não “dançarem” ao animar.

```dart
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' show FontFeature;

TextTheme appTextTheme(TextTheme base) {
  final t = GoogleFonts.manropeTextTheme(base); // troque por .plusJakartaSansTextTheme p/ 1b
  const tnum = [FontFeature.tabularFigures()];
  return t.copyWith(
    displaySmall:  t.displaySmall !.copyWith(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6, fontFeatures: tnum), // “12 de 12”, % do anel
    headlineSmall: t.headlineSmall!.copyWith(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
    titleLarge:    t.titleLarge   !.copyWith(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.2), // AppBar
    titleMedium:   t.titleMedium  !.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
    bodyMedium:    t.bodyMedium   !.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.35),
    bodySmall:     t.bodySmall    !.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    labelLarge:    t.labelLarge   !.copyWith(fontSize: 15, fontWeight: FontWeight.w800), // botões
    labelSmall:    t.labelSmall   !.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.8), // “COPOS DE HOJE”
  );
}
```

### 2.3 Espaçamento · raios · elevação

- **Grid de espaço:** 4 · 8 · 12 · 16 · 20 · 24. Margem lateral da tela: **16**. Respiro entre blocos: **12–16**.
- **Raios:** campo/stepper **14–20**, card **20**, header de progresso **26**, FAB/botão **18–20**, chips **16**. (Material default é ~12 — subimos pra dar o ar “premium/soft”.)
- **Elevação:** troque `Card`/`elevation` por sombra própria suave. Light: `BoxShadow(color: 0x0F0B2743, blur: 10, y: 2)`. Dark: `BoxShadow(color: 0x66000000, blur: 20, y: 6)`. Borda de 1px em `outlineVariant` nos cards de config.
- **Alvos de toque:** copos e ícones ≥ 44dp (o copo ocupa a célula inteira do grid).

---

## 3. Redesign tela a tela

### 3.1 Home

```
┌───────────────────────────────┐
│ Contador de Água        ⚙︎     │  AppBar transparente, título titleLarge, gear em surfaceContainerLow
├───────────────────────────────┤
│ ┌───────────────────────────┐ │  Header card (surfaceContainerLowest, r26, sombra)
│ │  ⟳ 25%     3 de 12        │ │  anel 132  |  displaySmall + “copos hoje”
│ │            ────────────    │ │  divisória outlineVariant
│ │            750 / 3000 ml   │ │  titleMedium
│ │            Faltam 9 copos  │ │  bodySmall onSurfaceVariant
│ └───────────────────────────┘ │
│ ┌───────────────────────────┐ │  Chip de status (fundo = errorContainer se atrasado,
│ │ ⏱ Você está atrasado       │ │  senão surfaceContainer). Ícone+título na cor do estado,
│ │   Ideal até agora: 6 de 12 │ │  AnimatedContainer p/ transição de cor.
│ └───────────────────────────┘ │
│ COPOS DE HOJE     toque p/ marcar│  labelSmall / bodySmall
│ ▢ ▢ ▢ ▢                        │  GridView 4 col, gap 10, cada célula = WaterCup tocável
│ ▢ ▢ ▢ ▢                        │
│ ▢ ▢ ▢ ▢          [ 🥤 Bebi um copo ] │  FAB.extended, some quando meta batida
└───────────────────────────────┘
```

- **AppBar:** `backgroundColor: Colors.transparent`, `scrolledUnderElevation: 0`, sem sombra; gota `Icons.water_drop` em `primary` + título.
- **Header:** `Row` [anel 132] + [coluna de stats]. Números em `displaySmall`/`titleMedium`. Divisória = `Container(height:1, color: outlineVariant)`.
- **Status:** `AnimatedContainer(duration: 350ms)` — cor do fundo e do texto trocam sozinhas quando `bebidos` cruza o `ideal` (atrasado→em dia→adiantado).
- **Grid:** `GridView.count(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, padding: 20)`. Padding inferior ~120 pra o FAB não cobrir a última linha.
- **FAB:** `FloatingActionButton.extended(icon: Icons.local_drink, label: 'Bebi um copo')`, `AnimatedScale`/`AnimatedSlide` p/ sumir suave quando `bebidos == total`.

### 3.2 Configurações

- **Meta diária** e **Capacidade do copo:** card com título + helper à esquerda, **stepper** (− valor +) em pílula `surfaceContainerLow` à direita. Steppers substituem o `TextFormField`+`OutlineInputBorder` — menos teclado, mais “premium”. (Se precisar de entrada livre, mantenha um `TextField` discreto atrás de um toque no valor.)
- **Início / Fim do dia:** dois cards lado a lado (`Row` com `Expanded`), cada um com rótulo + botão grande que abre `showTimePicker`. Ícones `Icons.schedule` / `Icons.bedtime`.
- **Prévia:** card com leve gradiente `surfaceContainer → surfaceContainerLow`, header `Icons.notifications_active` “Prévia dos lembretes”, e 4 linhas rótulo→valor (total de copos, lembretes, intervalo, agrupamento). Recalcula em tempo real.
- **Salvar:** `FilledButton` largura total, r18, `Icons.check`.

---

## 4. `WaterCup` redesenhado (`CustomPainter`)

3 estados: **a beber** (vazio) · **bebido** (cheio + check) · **atrasado** (vazio, aro/água em vermelho + relógio).

> **Mudança recomendada de semântica:** hoje *cheio = pendente*. Inverta para
> **beber = encher** — assim a marcação ganha a animação de preenchimento (recompensa) e
> fica mais intuitivo. É só trocar o alvo do nível; o fluxo (tocar marca o copo) não muda.
> Se preferir manter o atual, basta inverter `fill`.

```dart
enum CupState { pending, done, overdue }

class WaterCupPainter extends CustomPainter {
  final double fill;          // 0..1 (animado)
  final CupState state;
  final ColorScheme cs;
  final AppTokens t;
  final double reflect;       // 0.55 no Ocean, 0 no Aqua
  final double radiusTop, radiusBottom; // Ocean 10/12 · Aqua 14/22
  WaterCupPainter(this.fill, this.state, this.cs, this.t,
      {this.reflect = 0.55, this.radiusTop = 10, this.radiusBottom = 12});

  @override
  void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    final glass = RRect.fromRectAndCorners(rect,
      topLeft: Radius.circular(radiusTop), topRight: Radius.circular(radiusTop),
      bottomLeft: Radius.circular(radiusBottom), bottomRight: Radius.circular(radiusBottom));

    // recorta tudo na silhueta do copo
    c.save();
    c.clipRRect(glass);

    // água
    final level = s.height * (1 - fill.clamp(0, 1));
    final waterRect = Rect.fromLTRB(0, level, s.width, s.height);
    if (state == CupState.done) {
      c.drawRect(waterRect, Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [t.waterTop, t.waterBottom]).createShader(waterRect));
      // menisco
      c.drawRect(Rect.fromLTWH(0, level, s.width, 3),
        Paint()..color = Colors.white.withOpacity(.42));
    } else {
      c.drawRect(waterRect, Paint()..color = (state == CupState.overdue)
        ? t.overdue.withOpacity(.14) : cs.primary.withOpacity(.10));
    }

    // reflexo (só Ocean)
    if (reflect > 0) {
      final r = Rect.fromLTWH(s.width * .16, s.height * .12, s.width * .10, s.height * .64);
      c.drawRRect(RRect.fromRectXY(r, 6, 6), Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(.65 * reflect), Colors.white.withOpacity(0)])
        .createShader(r));
    }
    c.restore();

    // aro
    final border = switch (state) {
      CupState.done => cs.primary,
      CupState.overdue => t.overdue,
      CupState.pending => t.cupLine,
    };
    c.drawRRect(glass.deflate(1),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = border);
  }

  @override
  bool shouldRepaint(WaterCupPainter o) =>
    o.fill != fill || o.state != state || o.cs != cs;
}
```

Ícone por cima (check / relógio) fica **fora** do painter, num `Stack`, pra herdar
`Icons` e `Semantics`:

```dart
Widget waterCup(BuildContext ctx, {required CupState state, required VoidCallback onTap}) {
  final cs = Theme.of(ctx).colorScheme;
  final t  = Theme.of(ctx).extension<AppTokens>()!;
  final target = state == CupState.done ? 0.88 : 0.13;
  return Semantics(
    button: true,
    label: switch (state) { CupState.done => 'Copo bebido',
      CupState.overdue => 'Copo atrasado', CupState.pending => 'Copo a beber' },
    child: InkResponse(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.70, // Aqua: 0.82
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: target, end: target),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, fill, __) => Stack(alignment: Alignment.center, children: [
            CustomPaint(painter: WaterCupPainter(fill, state, cs, t), size: Size.infinite),
            if (state == CupState.done)
              Icon(Icons.check_rounded, size: 22, color: cs.onPrimary),
            if (state == CupState.overdue)
              Icon(Icons.schedule_rounded, size: 17, color: t.overdue),
          ]),
        ),
      ),
    ),
  );
}
```

> Para uma escala “pop” ao marcar, embrulhe num `AnimatedScale` que vai a `1.1` por 250ms
> quando o índice recém-marcado == este copo, e volta a `1.0`.

---

## 5. Anel de progresso (`CustomPainter`)

Anel com **gradiente**, ponta arredondada, animação do percentual e **brilho ao bater a meta**.

```dart
class ProgressRingPainter extends CustomPainter {
  final double progress; // 0..1 (animado)
  final ColorScheme cs; final AppTokens t; final bool goal;
  ProgressRingPainter(this.progress, this.cs, this.t, this.goal);
  @override
  void paint(Canvas c, Size s) {
    final r = (s.shortestSide - 12) / 2;
    final center = s.center(Offset.zero);
    const stroke = 12.0;
    // trilho
    c.drawCircle(center, r, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = stroke..color = cs.outlineVariant);
    // progresso
    final rect = Rect.fromCircle(center: center, radius: r);
    final p = Paint()
      ..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round
      ..shader = SweepGradient(startAngle: -1.5708, endAngle: 4.712,
        colors: [t.waterTop, t.waterBottom]).createShader(rect);
    if (goal) p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6); // brilho
    c.drawArc(rect, -1.5708, 6.2832 * progress.clamp(0, 1), false, p);
  }
  @override
  bool shouldRepaint(ProgressRingPainter o) => o.progress != progress || o.goal != goal;
}
```

Uso com animação + `%` centralizado (números tabulares do `displaySmall`):

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: bebidos / total),
  duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic,
  builder: (ctx, v, _) => SizedBox(width: 132, height: 132, child: Stack(
    alignment: Alignment.center, children: [
      CustomPaint(painter: ProgressRingPainter(v, cs, tokens, bebidos >= total), size: const Size.square(132)),
      Text('${(v * 100).round()}%', style: Theme.of(ctx).textTheme.displaySmall),
    ])),
);
```

---

## 6. Micro-interações

- **Marcar copo:** nível sobe (`TweenAnimationBuilder` 600ms `easeOutCubic`) + `AnimatedScale` “pop” 1.0→1.1→1.0 (250ms). `HapticFeedback.selectionClick()` no toque.
- **Atrasado → em dia:** o chip de status é `AnimatedContainer`/`AnimatedDefaultTextStyle` (350ms) — cor de fundo (`errorContainer`↔`surfaceContainer`) e de texto interpolam sozinhas.
- **Anel:** anima sempre que `progress` muda; ao chegar a 100% ganha o `MaskFilter` de brilho + um leve `Transform.scale` pulsando 1.0→1.05→1.0.
- **Celebração (discreta):** sem emoji. Anel brilhando + status verde “Meta atingida”. Se quiser confete, um `OverlayEntry` com ~16 partículas caindo (300–500ms) — ou o pacote `confetti` em modo curto. FAB some com `AnimatedSlide`.
- **Troca de tema/tela:** como as cores vêm do `Theme`, um `AnimatedTheme` (ou o próprio `MaterialApp` com `themeAnimationDuration`) faz claro↔escuro cruzar suave.

---

## 7. Montando o `ThemeData`

```dart
ThemeData appTheme(ColorScheme cs, AppTokens tokens) {
  final base = ThemeData(useMaterial3: true, colorScheme: cs, brightness: cs.brightness);
  return base.copyWith(
    scaffoldBackgroundColor: cs.surface,
    textTheme: appTextTheme(base.textTheme),
    extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0,
      foregroundColor: cs.onSurface, centerTitle: false),
    cardTheme: CardTheme(
      color: cs.surfaceContainerLowest, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: appTextTheme(base.textTheme).labelLarge)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
      extendedTextStyle: appTextTheme(base.textTheme).labelLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  );
}

// MaterialApp
MaterialApp(
  theme: appTheme(oceanLight, oceanLightTokens),
  darkTheme: appTheme(oceanDark, oceanDarkTokens),
  themeAnimationDuration: const Duration(milliseconds: 300),
  // ...
);
```

---

## 8. Acessibilidade (não regredir)

- **`Semantics`** em cada copo com `button:true` + label do estado (ex.: “Copo 4 de 12, atrasado”). Já incluído no `waterCup()`.
- **Contraste:** todos os pares texto/fundo acima passam AA. Nunca use `primary` puro para corpo de texto — só ações e “água”.
- **Cor não é o único sinal:** estado do copo também tem forma (nível) e ícone (check / relógio); status tem ícone + texto além da cor.
- **Toque:** alvos ≥ 44dp; steppers e time pickers no lugar de campos minúsculos.

---

### Resumo da recomendação
**1a — Deep Ocean + Manrope** entrega melhor o “premium e sério”: navy profundo, ciano
como água, ótimo em dark. **1b — Aqua Fresh** é mais leve/fresco. O código acima é
parametrizado por `ColorScheme` + `AppTokens`, então trocar de direção (ou de light/dark)
é só trocar o par de tokens passado ao `appTheme(...)`.
