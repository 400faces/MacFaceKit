import SwiftUI
import AppKit

/// An OUTLINED link button — icon + label + a trailing `↗`, in a `row` tile with a `line` border that
/// brightens on hover; opens a URL outside the app. This is the "clickable link" affordance (RememBar's
/// `LearnMoreLink`): the outlined-row treatment is for LINKS, distinct from the plain menu-item rows in
/// a dropdown. Uses `NSWorkspace.open` (SwiftUI `openURL` no-ops in an inactive `.accessory` app).
public struct LinkButton: View {
    private let label: String
    private let url: URL
    private let systemImage: String
    @State private var hovered = false

    public init(_ label: String, url: URL, systemImage: String = "globe") {
        self.label = label
        self.url = url
        self.systemImage = systemImage
    }

    public var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: Tokens.micro + 1) {
                Image(systemName: systemImage).font(.system(size: 10, weight: .medium))
                Text(label).fontWeight(.semibold).underline(hovered, pattern: .solid)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right").font(.system(size: 9, weight: .semibold))
            }
            .font(Tokens.caption)
            .foregroundStyle(Tokens.text)
            .padding(.horizontal, Tokens.space)
            .frame(maxWidth: .infinity)
            .frame(height: Tokens.controlButton + 4)
            .background(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
                .fill(hovered ? Tokens.rowActive : Tokens.row))
            .overlay(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
                .stroke(hovered ? Tokens.lineStrong : Tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hovered = hovering
            if hovering { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}
