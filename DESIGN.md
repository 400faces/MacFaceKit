# MacFaceKit — shared design system for 400faces macOS apps

Goal: **RememBar and TermTile feel like UI-twins** — same buttons, links, rows, fields, loading, sign-off,
tokens. Only each app's general-purpose functionality differs. MacFaceKit is the single source of that UI
vocabulary; every app composes from it. RememBar (`~/Desktop/safari-history-export/BrowserMemoryBar`) is
the mature reference we extract from.

## 1. Token decision — carry RememBar's palette (NOT system-adaptive)

MacFaceKit v0 used system-adaptive colors. **Reversed:** for the apps to feel identical, the kit must carry
RememBar's actual **fixed-dark `Tokens`** — palette + spacing + fonts — as the shared brand. Every RememBar
component is built on them, and "identical feel" *is* the shared palette. Consequence: TermTile's menu
popover becomes RememBar-dark (a deliberate brand choice) instead of system material.

Ship as a public `Palette` (colors) + `Metrics` (space/micro/radius/controlHeight) + `Typography`, sourced
from RememBar's `Tokens.swift`: panel/field/row/rowActive/line/lineStrong/text/muted/quiet/accent/warning.

## 2. Component set (extract from RememBar, generalize, build on the tokens)

Tier 1 — foundation: `Palette` · `Metrics` · `Typography` (from Tokens.swift).
Tier 2 — buttons/controls: `IconButtonStyle` · `IconButton` with optional `AttentionDot` · `GhostIconButton` · `PrimaryButton` (accent hero, left-aligned) · `ActionPillButton` · `ActionRow` (done, rebuild on tokens) · `SettingsTabButton`.
Tier 3 — links/text: `ExternalLink`/`LearnMoreLink` (globe + label + ↗ + hover underline).
Tier 4 — identity: `MadeWithSignoff`/`RobotGlyph` (done, rebuild on tokens) · `AppIconView` (bundled-icon-with-fallback).
Tier 5 — update flow: `UpdateDialog` (+ `UpdateActionButton`/`UpdateProgressBar`/`ReleaseNotesSection`) — the
branded Sparkle-flow dialog, Sparkle-FREE. Each app's `SPUUserDriver` maps callbacks → a state and feeds the
dialog its `name` (via the 7 factories) + `icon` (applied once). Window chrome = `Tokens.updateWindow`.
`UpdateWindowController` owns the window + model + escape/ack + byte→fraction math behind a semantic `show*`
API (Sparkle-free); `ReleaseNotesParser`/`ReleaseNotesFormat` flatten the notes markup. The per-app split:
everything that is NOT a Sparkle type is in the kit; the thin `SPUUserDriver` adapter + the `SPUUpdater`
lazy-start/stock-fallback stay app-local — irreducibly, because Sparkle is a per-app vendored `binaryTarget`
that can't live in the public kit (pulling it in via SPM would give consumers two Sparkles).
Tier 6 — loading: `Shimmer` (ViewModifier) · `SkeletonBlock` · `LoadingRows`.
Tier 7 — fields/chips: `CommandField`/text-field style · `WordChip` · `SortToggle`.
Tier 8 — settings shell: the settings-window scaffold (tab bar + `SettingsTabButton` + `SettingsRootView`
pattern) — the proven container RememBar hosts its rich rows in. **This is what TermTile needs** to host
About/actions with the polished rows (the container question resolves to "adopt RememBar's settings window").

App-specific, stays out: search results/thumbnails, alias/catalog editor, `RememBarGlyph`, memory panel.

## 3. Adoption plan (order chosen so a shipping app is never destabilized)

1. **MacFaceKit build-out** — carry Tokens → `Palette`/`Metrics`/`Typography`; rebuild the 4 existing
   components on them; add Tier 2/3/4 (buttons, links, identity). Each with a smoke test. Tag `0.1.0`.
2. **TermTile adopts first** (safe to experiment) — depend on MacFaceKit; recompose the menu panel from kit
   components; add the shared **settings-window shell** to host About + action rows (becoming
   architecturally like RememBar). Render-validate. This proves the kit end-to-end.
3. **RememBar migrates last** (shipping — careful) — replace its local component copies with kit imports,
   one tier at a time, its existing tests gating each step. Net: dedupe, zero visual change.
4. **Loading/fields/update (Tier 5–7)** — extract as each app needs them; the Sparkle update UI is shared
   the moment both import it.

Outcome: one kit, two apps, identical vocabulary; new 400faces macOS apps start pre-dressed.

## 4. Rules — icon buttons (there are exactly TWO treatments)

Both share ONE hover token — `Tokens.rowActive` fill at `Tokens.radius`. They differ ONLY in the rest state.
Do not invent a third; pick by whether the control is prominent-standalone or inline-secondary.

- **Boxed** — `IconButtonStyle` / `IconButton` (and RememBar's `IconControlButton`). Always-visible box:
  `row` fill + `line` border at rest → `rowActive` + `lineStrong` on hover. For **prominent standalone**
  controls: the `···` overflow, the settings gear, pager arrows. Match the control's height to its row.
  Use the optional bottom-right `AttentionDot` for generic pending/available states; the owning app remains
  responsible for the semantic label or surrounding context.
- **Menu attention** — `MenuAction.attention` marks the overflow button and its row. `MenuAction` may carry
  an app-owned accessibility hint for the closed trigger and attended row; MacFaceKit must not hardcode
  app-specific state copy.
- **Ghost** — `GhostIconButton`. Transparent at rest; glyph brightens `restColor`→`hoverColor`; an OPT-IN
  (`fill: true`) rounded `rowActive` fill appears on hover. For **inline/secondary** controls: search-field
  ✕/↵, chip-remove, inline delete.

Ghost `fill` rules (default OFF):
- Turn `fill: true` ONLY for a roomy (≈28pt), field-scoped control on a **non-`rowActive`** backdrop
  (e.g. the search field's ✕/↵ on the `field` surface).
- NEVER fill a glyph that sits on a `rowActive` surface (e.g. a chip-✕ inside a `rowActive` capsule) — the
  fill collides with the backdrop and reads muddy. Tiny chips stay color-only.
- Destructive glyphs use `hoverColor: Tokens.destructive` (never raw `.red`).
