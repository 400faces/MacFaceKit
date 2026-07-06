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
Tier 2 — buttons/controls: `IconButtonStyle` · `GhostIconButton` · `ActionPillButton` · `ActionRow` (done, rebuild on tokens) · `SettingsTabButton`.
Tier 3 — links/text: `ExternalLink`/`LearnMoreLink` (globe + label + ↗ + hover underline).
Tier 4 — identity: `MadeWithSignoff`/`RobotGlyph` (done, rebuild on tokens) · `AppIconView` (bundled-icon-with-fallback).
Tier 5 — loading: `Shimmer` (ViewModifier) · `SkeletonBlock` · `LoadingRows`.
Tier 6 — fields/chips: `CommandField`/text-field style · `WordChip` · `SortToggle`.
Tier 7 — update flow (BOTH apps use Sparkle): `UpdateDialog` · `UpdateProgressBar` · `UpdateActionButton`.
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
