import SwiftUI
import AppKit

/// The app identity header — the repeatable "top bar" every 400faces app opens with: the squircle app
/// icon, the name, the version, the "Made with ♥ 🤖" sign-off, and a trailing slot (typically the `···`
/// overflow). One component, one layout, tokenized throughout — so RememBar and TermTile open identically.
///
/// `version` is the caller's already-formatted string (e.g. "0.1.0 (95)"). `trailing` is app-specific
/// (its overflow menu / actions). Outbound links (GitHub, Learn-more) sit BELOW this as their own
/// `LinkButton` row — the identity block stays the version+attribution unit.
public struct AppHeader<Trailing: View>: View {
    private let name: String
    private let version: String
    private let bundledIcon: NSImage?
    private let showsMadeWith: Bool
    private let trailing: Trailing

    public init(name: String, version: String, bundledIcon: NSImage? = nil, showsMadeWith: Bool = true,
                @ViewBuilder trailing: () -> Trailing) {
        self.name = name
        self.version = version
        self.bundledIcon = bundledIcon
        self.showsMadeWith = showsMadeWith
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Tokens.space + 3) {
            AppIconView(bundledImage: bundledIcon, fallbackMonogram: String(name.prefix(1)))
                .frame(width: Tokens.iconHeader, height: Tokens.iconHeader)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(Tokens.title).foregroundStyle(Tokens.text)
                Text("Version \(version)").font(Tokens.caption).foregroundStyle(Tokens.muted)
                if showsMadeWith { MadeWithSignoff().padding(.top, 2) }
            }
            Spacer(minLength: Tokens.space)
            trailing
        }
    }
}

/// Convenience for a header with no trailing accessory.
extension AppHeader where Trailing == EmptyView {
    public init(name: String, version: String, bundledIcon: NSImage? = nil, showsMadeWith: Bool = true) {
        self.init(name: name, version: version, bundledIcon: bundledIcon,
                  showsMadeWith: showsMadeWith) { EmptyView() }
    }
}
