import SwiftUI
import AppKit

/// A full-width action row: icon + title with a hover highlight. Resting = a subtle `row` fill + `line`
/// border; hover brightens to `rowActive` + `lineStrong`. The destructive variant reads red, then RED
/// FILL / WHITE TEXT on hover — the macOS delete-item feel — so a dangerous action looks dangerous.
/// (Verbatim from RememBar's `AboutActionRow`, on the shared `Tokens`.)
public struct ActionRow: View {
    private let title: String
    private let systemImage: String
    private let destructive: Bool
    private let enabled: Bool
    private let action: () -> Void
    @State private var hovered = false

    public init(title: String, systemImage: String, destructive: Bool = false,
                enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.destructive = destructive
        self.enabled = enabled
        self.action = action
    }

    private var foreground: Color {
        if !enabled { return Tokens.quiet }
        if destructive { return hovered ? .white : Tokens.destructive }
        return Tokens.text
    }
    private var fill: Color {
        if destructive { return hovered ? Tokens.destructive : Tokens.row }
        return hovered ? Tokens.rowActive : Tokens.row
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Tokens.micro + 2) {
                Image(systemName: systemImage).font(.system(size: 11, weight: .medium)).frame(width: 15)
                Text(title).fontWeight(.medium)
                Spacer(minLength: 0)
            }
            .font(Tokens.caption)
            .foregroundStyle(foreground)
            .padding(.horizontal, Tokens.space)
            .frame(maxWidth: .infinity)
            .frame(height: Tokens.controlButton + 4)
            .background(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
                .stroke(hovered && !destructive ? Tokens.lineStrong : Tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .onHover { hovering in
            hovered = hovering && enabled
            if hovering && enabled { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}
