# MacFaceKit

The shared SwiftUI design system for 400faces macOS apps (RememBar, TermTile, …). One canonical token
set + componentized UI, so every app renders with the same brand and the apps feel like UI-twins — only
their general-purpose functionality differs.

**Fixed-dark brand palette** (not system-adaptive) — the apps share one look rather than each adapting
differently. Lean by design: extend only as a real need appears.

## Tokens (`Tokens`)
One source for **spacing** (`micro`, `space`), **radius**, **size** (`control`, `controlButton`),
**color** (panel/field/row/rowActive/line/lineStrong/text/muted/quiet/warning/accent), and
**typography** (`title`/`body`/`caption`/`label`). Nothing in the kit hardcodes a raw value.

## Components
- `ActionRow` — icon + title action row; hover highlight; destructive = red-fill/white on hover.
- `ExternalLink` — label + ↗, hover underline (opens outside the app).
- `MadeWithSignoff` / `RobotGlyph` — the "Made with ♥ & 🤖" sign-off.
- `IconButtonStyle` — square icon-control button style (brightens on hover/active/press).
- `HoverIconButton` — self-contained borderless icon button.
- `ActionPillButton` — short tinted call-to-action pill.

Grow as needed: fields/chips, loading skeletons, the Sparkle update flow, and the settings-window shell
are next tiers (see `DESIGN.md`).

## Use
```swift
.package(url: "https://github.com/400faces/MacFaceKit", from: "0.1.0")  // once tagged
.package(path: "../MacFaceKit")                                          // local, fast iteration
```
Then `import MacFaceKit`.
