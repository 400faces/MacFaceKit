# MacFaceKit

The shared SwiftUI design system for 400faces macOS apps (RememBar, TermTile, …). One canonical token
set + componentized UI, so every app renders with the same brand and the apps feel like UI-twins — only
their general-purpose functionality differs.

**Fixed-dark brand palette** (not system-adaptive) — the apps share one look rather than each adapting
differently. Lean by design: extend only as a real need appears.

## Tokens (`Tokens`)
One source for **spacing** (`micro`, `space`), **radius**, **size** (`control`, `controlButton`,
`attentionDot`), **color** (panel/field/row/rowActive/line/lineStrong/text/muted/quiet/warning/accent), and
**typography** (`title`/`body`/`caption`/`label`). Nothing in the kit hardcodes a raw value.

## Components
- `ActionRow` — icon + title action row; hover highlight; destructive = red-fill/white on hover.
- `ExternalLink` — label + ↗, hover underline (opens outside the app).
- `MadeWithSignoff` / `RobotGlyph` — the "Made with ♥ & 🤖" sign-off.
- `AttentionDot` — reusable warning-colored attention mark for app controls.
- `IconButtonStyle` / `IconButton` — square icon-control button style; optional upper-right attention dot.
- `GhostIconButton` — borderless "ghost" icon button (inline/secondary); optional `rowActive` hover fill.
- `ActionPillButton` — short tinted call-to-action pill.
- `PrimaryButton` — the accent-filled hero call-to-action (left-aligned icon+label, optional trailing
  shortcut hint). Both apps' one hero action (RememBar's primary; TermTile's "Rearrange now").
- `UpdateDialog` — the shared update-flow dialog (7 states via named factories: permission / checking /
  available+notes / progress / ready / up-to-date / error). Sparkle-FREE — each app's Sparkle user driver
  maps its callbacks to a state and supplies the app `name` (strings) + `icon`. Ships `UpdateActionButton`,
  `UpdateProgressBar`, `ReleaseNotesSection` primitives + the `Tokens.updateWindow` chrome color.
- `UpdateWindowController` — the Sparkle-FREE machinery behind `UpdateDialog`: owns the update window
  (morphs between states), the flow model, escape/acknowledgement bookkeeping, and the download byte→
  fraction math. Each app pairs it with a thin `SPUUserDriver` adapter that calls its semantic `show*`
  API — so everything that isn't a Sparkle type lives here once (Sparkle can't: it's a vendored binary).
- `ReleaseNotesParser` / `ReleaseNotesFormat` — turn appcast release-notes markup (markdown / plain / HTML)
  into the flat `[String]` the dialog renders. Sparkle-free (the app passes the raw payload).
- `OverflowMenu` / `MenuAction` — shared ellipsis menu. Actions can opt into generic attention state,
  surfaced on the upper-right ellipsis corner and attended row through `AttentionDot`; the owning app
  supplies any attention accessibility hint used by both the closed trigger and row.

Grow as needed: fields/chips, loading skeletons and the settings-window shell are next tiers (see `DESIGN.md`).

## Use
```swift
// Public + tagged — resolves on any clone / CI, no local checkout. Pin to a minor line:
.package(url: "https://github.com/400faces/MacFaceKit.git", .upToNextMinor(from: "0.4.1"))
```
Then `import MacFaceKit`. For co-developing the kit alongside a consumer, temporarily override with
`swift package edit MacFaceKit --path ../MacFaceKit` (then `unedit` + `update` to re-pin the tag).
