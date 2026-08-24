import AppKit
import SwiftUI

/// Where an app is in its update cycle, and therefore whether to show an attention mark.
///
/// Hoisted from TermTile so every app in this family says "an update is waiting" the same way
/// (400faces/MacFaceKit#2). `IconButton(attention:)` and `OverflowMenu` already rendered the dot;
/// this is the state that decides when.
///
/// `checking` and `failed` deliberately do NOT mark attention. A dot that appears while merely
/// checking teaches the user to ignore dots, and a failed check is not news the user can act on -
/// it is also not the same as being up to date, which is why the two are distinct cases rather than
/// one `unavailable`.
public enum UpdateAvailability: Equatable, Sendable {
    case unknown
    case checking
    case available(version: String?)
    case unavailable
    case failed

    public var hasAvailableUpdate: Bool {
        if case .available = self { return true }
        return false
    }
}

/// Composites an attention dot INTO a menu-bar image.
///
/// Not a SwiftUI overlay, and that is the whole point. `MenuBarExtra` flattens and tints its label,
/// so a badge layered on top is re-tinted to the glyph colour and disappears. TermTile found that
/// and worked around it with one composited `NSImage` rendered `.original`; this is that workaround,
/// made reusable.
public enum MenuBarBadge {

    /// - Returns: the symbol with a warning dot in its top-right corner when `attention` is true, a
    ///   plain template image when it is false, and nil when the symbol name does not resolve -
    ///   never a trap, because a menu-bar app with no icon has no way to reach its own menu.
    /// - Parameter glyphColor: what to fill the symbol with once it is no longer a template.
    ///   REQUIRED in substance, not a nicety: a badged image is not a template, so the menu bar
    ///   stops tinting it and an SF Symbol falls back to BLACK - invisible on a dark menu bar. That
    ///   version passed every assertion here (not a template, dot painted) and was unusable; only
    ///   rendering it and looking showed it. Callers pass the colour for the current appearance,
    ///   which is why TermTile reads `@Environment(\.colorScheme)` at the call site.
    public static func badged(systemImage: String, attention: Bool,
                              glyphColor: NSColor = .labelColor,
                              dotSize: CGFloat = Tokens.attentionDot) -> NSImage? {
        guard let symbol = NSImage(systemSymbolName: systemImage, accessibilityDescription: nil)
        else { return nil }

        guard attention else {
            // Left as a template so the menu bar keeps tinting it for light and dark, exactly as an
            // un-badged app icon always has.
            symbol.isTemplate = true
            return symbol
        }

        // Room for the dot at the trailing edge, so it sits beside the glyph rather than over it.
        let inset = dotSize * 0.75
        let canvas = NSSize(width: symbol.size.width + inset, height: symbol.size.height)
        let image = NSImage(size: canvas)
        image.lockFocus()
        let glyphRect = NSRect(origin: .zero, size: symbol.size)
        symbol.draw(in: glyphRect, from: NSRect(origin: .zero, size: symbol.size),
                    operation: .sourceOver, fraction: 1)
        // Fill the glyph explicitly. Without this it keeps the symbol's default black and vanishes
        // into a dark menu bar - the defect a render caught and no assertion had.
        glyphColor.setFill()
        glyphRect.fill(using: .sourceAtop)
        NSColor(Tokens.warning).setFill()
        NSBezierPath(ovalIn: NSRect(x: canvas.width - dotSize, y: canvas.height - dotSize,
                                    width: dotSize, height: dotSize)).fill()
        image.unlockFocus()
        // NOT a template: a template image is re-tinted flat by the menu bar and the dot would
        // vanish into the glyph colour.
        image.isTemplate = false
        return image
    }
}
