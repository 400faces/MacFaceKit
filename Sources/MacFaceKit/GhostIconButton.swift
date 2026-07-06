import SwiftUI
import AppKit

/// The ONE "ghost" icon button — borderless/transparent at rest, hover feedback via the SYSTEM hover
/// token. The glyph brightens `restColor`→`hoverColor`, and when `fill` is on a rounded `Tokens.rowActive`
/// fill appears (the same hover color the boxed `IconButtonStyle` uses, minus the always-on border). This
/// is the design system's inline/secondary icon control — search-field ✕/↵, chip-remove, inline delete.
/// Prominent standalone controls use the BOXED `IconButtonStyle`/`IconButton` instead.
///
/// `fill` defaults OFF. Only a roomy, field-scoped control on a NON-`rowActive` backdrop should opt in — a
/// fill over a tiny chip or a `rowActive` surface reads muddy, so those stay color-only. (See DESIGN.md.)
public struct GhostIconButton<Label: View>: View {
    private let hitSize: CGFloat
    private let restColor: Color
    private let hoverColor: Color
    private let fill: Bool
    private let action: () -> Void
    private let label: Label
    @State private var hovered = false

    public init(hitSize: CGFloat = 20, restColor: Color = Tokens.quiet, hoverColor: Color = Tokens.text,
                fill: Bool = false, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.hitSize = hitSize
        self.restColor = restColor
        self.hoverColor = hoverColor
        self.fill = fill
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: action) {
            label
                .foregroundStyle(hovered ? hoverColor : restColor)
                .frame(width: hitSize, height: hitSize)
                .background(
                    RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
                        .fill(fill && hovered ? Tokens.rowActive : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hovered = hovering
            if hovering { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}

/// SF-Symbol convenience — the common case (a single glyph). Pre-styles the symbol at `size`, semibold.
extension GhostIconButton where Label == GhostGlyph {
    public init(systemName: String, size: CGFloat = 11, hitSize: CGFloat = 20,
                restColor: Color = Tokens.quiet, hoverColor: Color = Tokens.text, fill: Bool = false,
                action: @escaping () -> Void) {
        self.init(hitSize: hitSize, restColor: restColor, hoverColor: hoverColor,
                  fill: fill, action: action) {
            GhostGlyph(systemName: systemName, size: size)
        }
    }
}

/// The pre-styled SF Symbol glyph used by `GhostIconButton(systemName:)`.
public struct GhostGlyph: View {
    let systemName: String
    let size: CGFloat
    public var body: some View {
        Image(systemName: systemName).font(.system(size: size, weight: .semibold))
    }
}
