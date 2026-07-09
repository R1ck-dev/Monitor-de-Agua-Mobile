# Prompt para o Claude Design — Upgrade visual do app "Contador de Água"

## O que eu quero

Fazer um **upgrade de design** de um app mobile Flutter chamado **Contador de Água**
(controle de hidratação diária). Quero um visual **moderno e limpo**: refinamento do
Material 3 atual — melhor hierarquia, espaçamento, tipografia e micro-animações —
mantendo a cara de app nativo e sério.

**Restrições importantes (não mudar):**

- **Stack fixa:** Flutter + Material 3 (`useMaterial3: true`). Nada de trocar de
  framework ou propor web/React. As entregas devem ser aplicáveis em Flutter/Dart.
- **Escopo:** **só o visual.** Mantenha as **2 telas atuais** (Home + Configurações) e
  o fluxo de uso atual. Pode mudar cores, tipografia, cards, o desenho do copo,
  layout interno e animações — **sem** adicionar telas novas, onboarding, histórico
  ou reorganizar a navegação.
- **Identidade:** continua sendo um app **sobre água/hidratação**. Mantenha o tema
  água, mas pode **evoluir a paleta** (hoje é um azul único `#1E88E5` via seed do
  Material). Proponha uma paleta mais rica (tons de azul/ciano, gradientes sutis),
  desde que funcione em **light e dark mode**.
- **Acessibilidade:** o app usa `Semantics` nos copos e precisa manter contraste e
  labels acessíveis. Não regredir nisso.

---

## Contexto do app (o que ele faz)

O usuário define uma **meta diária de água** (em ml) e o **tamanho do copo/garrafinha**.
O app calcula quantos "copos" são necessários e distribui **lembretes/notificações** ao
longo de uma janela do dia (hora de início → hora de fim). Na Home o usuário marca cada
copo conforme bebe; o app mostra o progresso e se ele está **em dia, atrasado ou
adiantado** em relação ao cronograma ideal. O progresso reseta a cada "dia lógico"
(que começa na hora de início configurada).

Conceitos de domínio que aparecem na UI:

- **Meta diária** (ex.: 3000 ml) e **tamanho do copo** (ex.: 250 ml).
- **Total de copos** = meta ÷ copo (arredondado pra cima).
- **Copos bebidos** (marcados) vs **restantes**.
- **Status de horário:** atrasado (deve N copos) / em dia / adiantado — comparando o
  que já foi bebido com o "ideal até agora" segundo os lembretes.
- **Lembretes:** horários distribuídos na janela do dia; quando ficariam muito
  próximos (< 45 min), agrupam mais de 1 copo por lembrete.

---

## Estado visual ATUAL (ponto de partida)

- **Tema:** Material 3, `ColorScheme.fromSeed(seedColor: Color(0xFF1E88E5))` (azul água),
  com light e dark themes. Fonte padrão do Material, sem customização de tipografia.
- **Componentes padrão** do Material sem estilização própria: `AppBar`, `Card`,
  `FloatingActionButton.extended`, `CircularProgressIndicator`, `TextFormField` com
  `OutlineInputBorder`, `ListTile`, `FilledButton`.
- **Copo** é desenhado à mão com `CustomPaint`: um copo cônico simples; cheio (azul) =
  pendente, vazio com "check" = bebido, vermelho = atrasado.
- Sensação geral: **funcional, mas cru** — cara de app Material default, pouca
  personalidade, hierarquia visual fraca, sem animações de transição/recompensa.

### Tela 1 — Home (`home_screen.dart`)

- `AppBar` com título "Contador de Água" e ícone de engrenagem (→ Configurações).
- **Cabeçalho** dentro de um `Card`:
  - Anel de progresso circular (72×72) com **percentual %** no centro.
  - "**X de Y copos**" (título) + "**A ml de B ml**" + "Faltam N copos" / "Meta
    atingida! 🎉".
  - **Status de horário** com ícone + texto colorido (atrasado = vermelho/aviso,
    em dia / adiantado = azul) e subtítulo "Ideal até agora: N de Y copos".
- **Grade de copos** (`GridView`) preenchendo o resto da tela: cada célula é um copo
  tocável (marca/desmarca). Copos atrasados destacam em vermelho.
- **FAB estendido** "Bebi um copo" (ícone de bebida) — some quando a meta é atingida.
- Estado vazio: quando não há meta, mostra "Defina sua meta nas configurações".

### Tela 2 — Configurações (`settings_screen.dart`)

- `AppBar` "Configurações".
- Formulário em `ListView`:
  - Campo **Meta diária** (ml) com helper "Ex.: 3000 ml = 3 litros".
  - Campo **Capacidade do copo/garrafinha** (ml) com helper "Ex.: 250 ml".
  - **Início do dia** e **Fim do dia** — `ListTile` com ícone de relógio que abre
    `showTimePicker`.
  - **Card "Prévia"** (cor `secondaryContainer`) resumindo: nº de copos, nº de
    lembretes, intervalo aproximado entre lembretes, e se agrupa copos.
  - Botão **Salvar** (`FilledButton.icon`).

---

## O que eu espero de você (entregas)

Trabalhe dentro do Flutter/Material 3. Entregue de forma organizada:

1. **Conceito de design** — direção visual em 3–5 linhas: mood, o que muda em relação
   ao atual, e como "água/hidratação" se traduz visualmente sem virar clichê.

2. **Sistema de design (design tokens):**
   - **Paleta** completa para **light e dark**: primária/secundária/superfícies/
     estados de sucesso, aviso e erro — com códigos hex e o `ColorScheme` sugerido
     (ou seeds + harmonização). Diga como aplicar em `ThemeData`.
   - **Tipografia:** escala (display/title/body/label) e, se sugerir uma fonte
     (Google Fonts), qual e por quê; caso contrário, como ajustar o `TextTheme`.
   - **Espaçamento, raios de canto, elevação/sombras** e estilo de card.

3. **Redesign tela a tela** (Home e Configurações): descreva o layout novo,
   componente por componente, com **anotações de espaçamento, cor e estado**. Se
   puder, inclua um mock em ASCII/wireframe ou uma descrição precisa o suficiente
   para eu implementar direto no Flutter.

4. **O copo (`WaterCup`) redesenhado:** peça-chave da identidade. Proponha um novo
   desenho (ainda via `CustomPaint` ou alternativa) para os 3 estados — **a beber /
   bebido / atrasado** — com preenchimento de "nível de água", e uma **animação** de
   preenchimento ao marcar. Descreva formas, proporções e cores.

5. **Anel/indicador de progresso** do cabeçalho: proponha uma versão mais expressiva
   (ex.: anel com gradiente, animação ao progredir, destaque ao bater a meta).

6. **Micro-interações e animações:** feedback ao marcar um copo, transição de estado
   "atrasado→em dia", e uma **celebração** discreta ao atingir a meta (hoje é só um
   emoji 🎉). Nada exagerado — condizente com "moderno e limpo".

7. **Snippets Flutter** sempre que fizer diferença: `ThemeData`/`ColorScheme`,
   `TextTheme`, e o essencial de widgets/`CustomPainter` que eu possa colar e adaptar.

### Formato da resposta

Markdown organizado nas seções acima, do sistema de design para as telas.
Priorize decisões acionáveis em Flutter em vez de teoria. Onde houver trade-off
(ex.: fonte custom vs padrão, gradiente vs cor sólida), aponte a opção recomendada
e o porquê em uma linha.
