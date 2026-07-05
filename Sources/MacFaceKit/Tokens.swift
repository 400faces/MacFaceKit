import SwiftUI
import AppKit

/// The single design-token set for 400faces macOS apps — one source for spacing, radius, size, color,
/// and typography, so every app (RememBar, TermTile, …) renders with the same brand and the apps feel
/// like UI-twins. A FIXED-dark palette (extracted verbatim from RememBar's `Tokens`) rather than
/// system-adaptive, so the look is identical across apps instead of each adapting differently.
///
/// Lean by design: extend only when a real need appears (a new spacing step, a new type level) — never
/// speculatively. Everything in the kit is built on these; nothing hardcodes a raw value.
public enum Tokens {
    // MARK: Spacing
    public static let micro: CGFloat = 4
    public static let space: CGFloat = 8

    // MARK: Radius
    public static let radius: CGFloat = 8

    // MARK: Size — shared control heights
    public static let control: CGFloat = 34        // search-bar / settings-box height
    public static let controlButton: CGFloat = 26  // icon + action control height

    // MARK: Color — the fixed-dark brand palette
    public static let panel = Color(red: 0.083, green: 0.087, blue: 0.094)
    public static let field = Color(red: 0.059, green: 0.063, blue: 0.071)
    public static let row = Color(red: 0.114, green: 0.118, blue: 0.126)
    public static let rowActive = Color(red: 0.137, green: 0.141, blue: 0.153)
    public static let line = Color(red: 0.204, green: 0.212, blue: 0.228)
    public static let lineStrong = Color(red: 0.357, green: 0.369, blue: 0.392)
    public static let text = Color(red: 0.949, green: 0.953, blue: 0.957)
    public static let muted = Color(red: 0.596, green: 0.616, blue: 0.643)
    public static let quiet = Color(red: 0.451, green: 0.475, blue: 0.506)
    public static let warning = Color(red: 0.941, green: 0.635, blue: 0.271)
    /// Primary-action blue (macOS dark-mode system accent) — the confirming button, matching Sparkle.
    public static let accent = Color(red: 0.039, green: 0.518, blue: 1.0)

    // MARK: Typography — the type hierarchy
    public static let title = Font.system(size: 18, weight: .semibold)
    public static let body = Font.system(size: 13)
    public static let caption = Font.system(size: 12)
    public static let label = Font.system(size: 10, weight: .semibold)

    // MARK: AppKit mirrors — for NSView-based controls (e.g. the hotkey recorder) so they tokenize
    // against the SAME palette instead of falling back to system control colors.
    public static let nsPanel = NSColor(srgbRed: 0.083, green: 0.087, blue: 0.094, alpha: 1)
    public static let nsField = NSColor(srgbRed: 0.059, green: 0.063, blue: 0.071, alpha: 1)
    public static let nsRow = NSColor(srgbRed: 0.114, green: 0.118, blue: 0.126, alpha: 1)
    public static let nsLine = NSColor(srgbRed: 0.204, green: 0.212, blue: 0.228, alpha: 1)
    public static let nsText = NSColor(srgbRed: 0.949, green: 0.953, blue: 0.957, alpha: 1)
    public static let nsMuted = NSColor(srgbRed: 0.596, green: 0.616, blue: 0.643, alpha: 1)
    public static let nsAccent = NSColor(srgbRed: 0.039, green: 0.518, blue: 1.0, alpha: 1)
}
