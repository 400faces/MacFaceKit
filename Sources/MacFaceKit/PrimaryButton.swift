import SwiftUI
import AppKit

/// The primary call-to-action — an accent-filled rounded hero button. Uses the fixed-dark brand
/// `Tokens.accent` (NOT the macOS system `.borderedProminent`, which is system-adaptive and drifts
/// from the brand), white label, an optional leading glyph and trailing accessory (e.g. a keyboard
/// shortcut). Dims when disabled, brightens on hover. Both apps use this for their one hero action so
/// it reads identically — the last control that was still a system style.
public struct PrimaryButton: View {
    private let title: String
    private let systemImage: String?
    private let trailing: String?
    private let enabled: Bool
    private let action: () -> Void
    @State private var hovered = false

    public init(_ title: String, systemImage: String? = nil, trailing: String? = nil,
                enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.trailing = trailing
        self.enabled = enabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                // The icon + label sit CENTERED (so the button reads balanced, not spread edge-to-edge)…
                HStack(spacing: Tokens.space) {
                    if let systemImage {
                        Image(systemName: systemImage).font(.system(size: 13, weight: .semibold))
                    }
                    Text(title).font(Tokens.body.weight(.semibold))
                }
                // …while the optional shortcut hint tucks against the trailing edge, dimmed.
                if let trailing {
                    HStack {
                        Spacer(minLength: 0)
                        Text(trailing).font(Tokens.caption).foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Tokens.space + Tokens.micro)
            .frame(maxWidth: .infinity)
            .frame(minHeight: Tokens.control + Tokens.space)   // ~42pt hero (≈1.5× a standard control)
            .background(
                RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
                    .fill(Tokens.accent)
                    .brightness(hovered && enabled ? 0.06 : 0)   // subtle hover lift, no extra color token
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(enabled ? 1 : 0.45)
        .disabled(!enabled)
        .onHover { hovering in
            hovered = hovering
            if hovering && enabled { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}
