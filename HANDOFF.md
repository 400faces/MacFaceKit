# MacFaceKit — Handoff

_Last updated: 2026-07-10. The single spot to pick up the shared design system. Consumers each have
their own handoff: `RememBar/HANDOFF.md`, `termtile/HANDOFF.md`._

## What it is

The shared 400faces macOS SwiftUI design system — fixed-dark tokens + components — consumed by **both**
RememBar and TermTile so they read as UI-twins. Public repo (`github.com/400faces/MacFaceKit`); both apps
pin it `.upToNextMinor(from: "0.3.2")` via the git URL (auto-resolved, no local checkout).

## Current state (all green)

| Check | State |
|---|---|
| Build / Test / Lint | ✅ `swift build && swift test && swiftlint --strict` — 29 tests, 0 violations |
| CI | ✅ `.github/workflows/check.yml` (added this session — build/test/lint on push+PR) |
| Git | ✅ `master` == `origin/master`, tree clean |
| Latest tag | **v0.3.2** (both apps pin the 0.3.x line) |

## Component tiers (see `DESIGN.md` for the full spec)

Tokens · icon buttons (`IconButtonStyle`/`GhostIconButton`) · `PrimaryButton` (accent hero) · links
(`ExternalLink`/`LearnMoreLink`) · identity (`AppIdentityCard`/`AppInfo`/`AppIconView`/`MadeWithSignoff`) ·
**update flow** (`UpdateDialog` + `UpdateWindowController` + `ReleaseNotesParser` — Sparkle-FREE; each app
adds only a thin `SPUUserDriver` adapter) · `OverflowMenu` · `SectionCard` · settings-shell primitives.

## ▶ Start here / how to ship a kit change

1. Make the change; `swift build && swift test && swiftlint --strict` (CI gates this on push now).
2. **Tag it**: `git tag vX.Y.Z && git push origin vX.Y.Z` (semver: minor for new components/APIs, patch
   for fixes). Godmode remote (400faces) — tagging is authorized, no gate.
3. **Bump the consumers**: in each app, `swift package update MacFaceKit` (or edit the `.upToNextMinor`
   floor for a new minor line), rebuild/test, commit the `Package.resolved` bump.
4. **Co-develop tip**: `swift package edit MacFaceKit --path ../MacFaceKit` in a consumer to iterate
   against a local checkout; `unedit` + `update` to re-pin the tag when done.

## Notes

- **Stays Sparkle-free.** The update machinery is deliberately Sparkle-agnostic — Sparkle is a per-app
  vendored `binaryTarget` that can't live in the public kit (two-Sparkles conflict). The `SPUUserDriver`
  adapter + `SPUUpdater` controller stay app-local, irreducibly. Don't add a Sparkle dep here.
- Tokens are fixed-dark by design (carried from RememBar), NOT system-adaptive — see `DESIGN.md §1`.
- This is the load-bearing dependency of two shipping apps; a bad tag breaks both. The new CI gate is the
  safety net — keep it green.
