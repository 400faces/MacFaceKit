import SwiftUI
import AppKit

/// The icon-family control: a square icon button that IS `IconButtonStyle` — `controlButton` size,
/// `row`→`rowActive` fill, `line`→`lineStrong` border, brightening glyph, pointing-hand cursor. It
/// owns its own hover `@State` so callers never re-wire it (the bug where the `···` was styled by
/// hand). `active` holds the lifted look while a menu/popover it drives is open.
public struct IconButton: View {
    private let systemImage: String
    private let size: CGFloat
    private let active: Bool
    private let action: () -> Void
    @State private var hovered = false

    public init(systemImage: String, size: CGFloat = 13, active: Bool = false,
                action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.size = size
        self.active = active
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size, weight: .semibold))
                .frame(width: Tokens.controlButton, height: Tokens.controlButton)
                .contentShape(Rectangle())
        }
        .buttonStyle(IconButtonStyle(active: active, hovered: hovered))
        .onHover { hovering in
            hovered = hovering
            if hovering { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}
