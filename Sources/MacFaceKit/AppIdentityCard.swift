import SwiftUI
import AppKit

/// One outbound link in an `AppIdentityCard` (GitHub, License, a website…). A thin value over
/// `LinkButton`'s inputs with factories for the common ones, so an app just lists `[.github(url),
/// .license(url)]`.
public struct IdentityLink: Identifiable {
    public var id: String { label }
    public let label: String
    public let url: URL
    public let icon: LinkButton.Icon

    public init(label: String, url: URL, icon: LinkButton.Icon) {
        self.label = label
        self.url = url
        self.icon = icon
    }

    /// GitHub — the bundled brand mark.
    public static func github(_ url: URL) -> IdentityLink {
        IdentityLink(label: "GitHub", url: url, icon: .image(Brand.github))
    }
    /// License — a document glyph.
    public static func license(_ url: URL) -> IdentityLink {
        IdentityLink(label: "License", url: url, icon: .symbol("doc.text"))
    }
    /// Any other outbound link (globe by default).
    public static func link(_ label: String, _ url: URL, systemImage: String = "globe") -> IdentityLink {
        IdentityLink(label: label, url: url, icon: .symbol(systemImage))
    }
}

/// THE app identity card — the one component both apps open with, so their chrome is literally the same
/// object. Top to bottom: the squircle app icon · name · version · "Made with ♥ 🤖" · a `···` overflow
/// (top-right) · a row of outbound links (GitHub, License…) · a horizontal separator · then the app's
/// OWN content. Everything above the separator is the shared identity; the `content` slot below is
/// app-specific. Only the dynamic inputs (icon/name/version/actions/links/content) differ between apps.
///
/// Surface chrome (width, background, placement) is intentionally the caller's — the same card lives in
/// TermTile's 280pt popover and RememBar's settings-window About tab. The separator only appears when
/// there IS content below it.
public struct AppIdentityCard<Content: View>: View {
    private let name: String
    private let version: String
    private let bundledIcon: NSImage?
    private let showsMadeWith: Bool
    private let actions: [MenuAction]
    private let links: [IdentityLink]
    private let content: Content

    public init(name: String, version: String, bundledIcon: NSImage? = nil, showsMadeWith: Bool = true,
                actions: [MenuAction] = [], links: [IdentityLink] = [],
                @ViewBuilder content: () -> Content = { EmptyView() }) {
        self.name = name
        self.version = version
        self.bundledIcon = bundledIcon
        self.showsMadeWith = showsMadeWith
        self.actions = actions
        self.links = links
        self.content = content()
    }

    /// Convenience — the common shape both apps use: pass the standard GitHub + License links as URLs and
    /// they're built here (killing the duplicated `[.github, .license]` array at each call site). `version`
    /// is typically `appInfo.displayVersion`.
    public init(name: String, version: String, repoURL: URL, licenseURL: URL, bundledIcon: NSImage? = nil,
                showsMadeWith: Bool = true, actions: [MenuAction] = [],
                @ViewBuilder content: () -> Content = { EmptyView() }) {
        self.init(name: name, version: version, bundledIcon: bundledIcon, showsMadeWith: showsMadeWith,
                  actions: actions, links: [.github(repoURL), .license(licenseURL)], content: content)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Tokens.gap) {
            AppHeader(name: name, version: version, bundledIcon: bundledIcon, showsMadeWith: showsMadeWith) {
                if !actions.isEmpty { OverflowMenu(actions) }
            }
            if !links.isEmpty {
                HStack(spacing: Tokens.micro + 2) {
                    ForEach(links) { link in
                        LinkButton(link.label, url: link.url, icon: link.icon)
                    }
                }
            }
            if Content.self != EmptyView.self {
                Divider()   // the horizontal separator before the app's own content
                content
            }
        }
        .padding(Tokens.pad)
    }
}
