import SwiftUI
import AppKit

/// A dropdown MENU item: icon + title on a plain row — NO border (that's `ActionRow`/`LinkButton`,
/// for prominent actions/links). Resting is transparent; hover fills `rowActive`. The destructive
/// variant reads red then RED-FILL / WHITE on hover — RememBar's "Remove" row. Sits on a dark
/// (`Tokens.panel`) popover so the whole dropdown matches the app instead of a system menu.
public struct MenuRow: View {
    private let title: String
    private let systemImage: String
    private let destructive: Bool
    private let enabled: Bool
    private let attention: Bool
    private let attentionAccessibilityHint: String?
    private let action: () -> Void
    @State private var hovered = false

    public init(title: String, systemImage: String, destructive: Bool = false,
                enabled: Bool = true, attention: Bool = false,
                attentionAccessibilityHint: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.destructive = destructive
        self.enabled = enabled
        self.attention = attention
        self.attentionAccessibilityHint = attentionAccessibilityHint
        self.action = action
    }

    private var foreground: Color {
        if !enabled { return Tokens.quiet }
        if destructive { return hovered ? .white : Tokens.destructive }
        return Tokens.text
    }
    private var fill: Color {
        guard enabled else { return .clear }
        if destructive { return hovered ? Tokens.destructive : .clear }
        return hovered ? Tokens.rowActive : .clear
    }
    private var accessibilityHint: String {
        guard attention, let attentionAccessibilityHint else { return "" }
        return attentionAccessibilityHint
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Tokens.micro + 2) {
                Image(systemName: systemImage).font(.system(size: 12, weight: .semibold)).frame(width: 18)
                Text(title).fontWeight(.semibold)
                Spacer(minLength: 0)
                Group {
                    if attention {
                        AttentionDot(size: Tokens.attentionDot)
                    } else {
                        Color.clear
                            .frame(width: Tokens.attentionDot, height: Tokens.attentionDot)
                    }
                }
                .accessibilityHidden(true)
            }
            .font(Tokens.body)
            .foregroundStyle(foreground)
            .padding(.horizontal, Tokens.micro + 2)
            .frame(maxWidth: .infinity, minHeight: Tokens.controlButton)
            .background(RoundedRectangle(cornerRadius: Tokens.radius - 1, style: .continuous).fill(fill))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityHint(accessibilityHint)
        .onHover { hovering in
            hovered = hovering && enabled
            if hovering && enabled { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}
