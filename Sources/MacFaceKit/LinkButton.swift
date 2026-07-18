import SwiftUI
import AppKit

/// An OUTLINED action button — icon + label + a trailing `↗`, in a `row` tile with a `line` border
/// that brightens on hover. URL initializers use `NSWorkspace.open` (SwiftUI `openURL` no-ops in an
/// inactive `.accessory` app); action initializers let callers reuse the same affordance for flows that
/// need to do local work before opening an external destination.
public struct LinkButton: View {
    /// The leading glyph: an SF Symbol (sized by font) or a brand mark (a resizable template image).
    public enum Icon { case symbol(String); case image(Image) }

    private let label: String
    private let icon: Icon
    private let action: () -> Void
    @State private var hovered = false

    public init(_ label: String, url: URL, systemImage: String = "globe") {
        self.init(label, url: url, icon: .symbol(systemImage))
    }
    public init(_ label: String, url: URL, image: Image) {
        self.init(label, url: url, icon: .image(image))
    }
    public init(_ label: String, url: URL, icon: Icon) {
        self.init(label, icon: icon) {
            NSWorkspace.shared.open(url)
        }
    }

    public init(_ label: String, systemImage: String = "globe", action: @escaping () -> Void) {
        self.init(label, icon: .symbol(systemImage), action: action)
    }

    public init(_ label: String, image: Image, action: @escaping () -> Void) {
        self.init(label, icon: .image(image), action: action)
    }

    public init(_ label: String, icon: Icon, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.action = action
    }

    @ViewBuilder private var iconView: some View {
        switch icon {
        case .symbol(let name): Image(systemName: name).font(.system(size: 10, weight: .medium))
        case .image(let image): image.resizable().scaledToFit().frame(width: 12, height: 12)
        }
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Tokens.micro + 1) {
                iconView
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
