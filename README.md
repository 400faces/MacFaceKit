# MacFaceKit

Shared SwiftUI components for ECN macOS apps (RememBar, TermTile, …). Write once, import everywhere —
so every app's dropdowns, links, and sign-off render identically and cost nothing to reuse.

System-adaptive colors (no fixed palette); neutral spacing tokens in `UI`.

## Components
- `ActionRow` — icon + title menu/action row; hover highlight; destructive = red-fill/white on hover.
- `ExternalLink` — label + ↗, hover underline + link cursor (opens outside the app).
- `MadeWithSignoff` / `RobotGlyph` — the "Made with ♥ & 🤖" sign-off.
- `UI` — spacing/radius tokens.

## Use
Add as a dependency (local path for now; a git URL once hosted):
```swift
.package(path: "../MacFaceKit")   // or .package(url: "https://github.com/400faces/MacFaceKit", from: "0.1.0")
```
Then `import MacFaceKit`.

## Status
v0 — extracted from RememBar (the mature source). Not yet wired into an app or pushed to a remote;
name/hosting TBD.
