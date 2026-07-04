import SwiftUI
import AppKit

/// A full-width action row: icon + title with a hover highlight. The destructive variant reads red,
/// then RED FILL / WHITE TEXT on hover — the macOS delete-item feel — so a dangerous action looks
/// dangerous. Disabled reads muted, no hover. (Generalized from RememBar's `AboutActionRow`;
/// system-adaptive colors instead of a fixed palette.)
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
        if !enabled { return .secondary }
        if destructive { return hovered ? .white : .red }
        return .primary
    }
    private var fill: Color {
        guard enabled else { return .clear }
        if destructive { return hovered ? .red : .clear }
        return hovered ? Color.primary.opacity(0.09) : .clear
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: UI.space) {
                Image(systemName: systemImage).font(.system(size: 11, weight: .medium)).frame(width: 16)
                Text(title).fontWeight(.medium)
                Spacer(minLength: 0)
            }
            .font(.callout)
            .foregroundStyle(foreground)
            .padding(.horizontal, UI.space)
            .frame(maxWidth: .infinity, minHeight: UI.controlRow)
            .background(RoundedRectangle(cornerRadius: UI.radius - 1, style: .continuous).fill(fill))
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
