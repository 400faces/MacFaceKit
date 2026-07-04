import SwiftUI
import AppKit

/// An external link: label + a `↗` glyph (it opens outside the app — browser, System Settings). The
/// label underlines and shows the pointing-hand cursor on hover. Uses `Tokens.text` (RememBar's
/// understated link color, not a system blue) so links read the same across apps.
public struct ExternalLink: View {
    private let label: String
    private let url: URL
    @State private var hovering = false

    public init(_ label: String, _ url: URL) {
        self.label = label
        self.url = url
    }

    public var body: some View {
        Link(destination: url) {
            HStack(spacing: 2) {
                Text(label).fontWeight(.semibold).underline(hovering)
                Image(systemName: "arrow.up.right").imageScale(.small)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(hovering ? Tokens.text : Tokens.muted)
        .onHover { inside in
            hovering = inside
            if inside { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
        }
    }
}
