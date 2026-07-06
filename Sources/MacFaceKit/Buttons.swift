import SwiftUI
import AppKit

/// The button style for square icon controls: a `row` tile that brightens (`rowActive` + `lineStrong`
/// border, brighter glyph) when active, hovered, or pressed. Hover is passed in by the owning view
/// (a `ButtonStyle` can't hold `@State`) so every icon control reacts identically. (From RememBar.)
public struct IconButtonStyle: ButtonStyle {
    public var active: Bool
    public var hovered: Bool
    public var radius: CGFloat

    public init(active: Bool = false, hovered: Bool = false, radius: CGFloat = Tokens.radius) {
        self.active = active
        self.hovered = hovered
        self.radius = radius
    }

    public func makeBody(configuration: Configuration) -> some View {
        let lifted = active || hovered || configuration.isPressed
        return configuration.label
            .foregroundStyle(lifted ? Tokens.text : Tokens.muted)
            .background(lifted ? Tokens.rowActive : Tokens.row)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke((active || hovered) ? Tokens.lineStrong : Tokens.line, lineWidth: 1)
            }
    }
}

/// A short tinted pill — a compact call-to-action (e.g. the warning/accent action in a notice).
/// (From RememBar.)
public struct ActionPillButton: View {
    private let title: String
    private let tint: Color
    private let action: () -> Void

    public init(title: String, tint: Color = Tokens.warning, action: @escaping () -> Void) {
        self.title = title
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(Tokens.caption.weight(.semibold))
                .foregroundStyle(Tokens.text)
                .padding(.horizontal, Tokens.space)
                .frame(height: Tokens.controlButton)
                .background(RoundedRectangle(cornerRadius: Tokens.micro, style: .continuous).fill(tint.opacity(0.28)))
        }
        .buttonStyle(.plain)
    }
}
