import SwiftUI
import AppKit

/// The "Learn more: 🌐 <url> ↗" outlined link row — a specific, repeatable link affordance (distinct
/// from the generic `LinkButton`): a muted prefix + globe + the semibold URL text (which underlines on
/// hover) + the external arrow, in a `row`/`line` card that brightens on hover. Opens via
/// `NSWorkspace` (SwiftUI `openURL` no-ops in an inactive `.accessory` app). Ported from RememBar.
public struct LearnMoreLink: View {
    private let displayText: String
    private let url: URL
    private let prefix: String
    @State private var hovered = false

    public init(displayText: String, url: URL, prefix: String = "Learn more:") {
        self.displayText = displayText
        self.url = url
        self.prefix = prefix
    }

    public var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: Tokens.micro + 1) {
                Text(prefix).foregroundStyle(Tokens.muted)
                Image(systemName: "globe").font(.system(size: 10, weight: .medium)).foregroundStyle(Tokens.text)
                Text(displayText).fontWeight(.semibold).foregroundStyle(Tokens.text)
                    .underline(hovered, pattern: .solid)
                Image(systemName: "arrow.up.forward").font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Tokens.text)
            }
            .font(Tokens.caption)
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
        .accessibilityLabel("\(prefix) \(url.absoluteString)")
    }
}
