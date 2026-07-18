import SwiftUI

/// A labeled settings group: a small uppercase header over a rounded `row` card with a `line` border
/// (macOS System-Settings grouping). The card is the proximity cue that makes each group read as one
/// unit. Tokenized throughout; both apps compose their settings from these.
public struct SectionCard<Content: View>: View {
    private let title: String
    private let content: Content

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Tokens.micro + 2) {
            Text(title).font(Tokens.label)
                .foregroundStyle(Tokens.muted).textCase(.uppercase).kerning(0.5)
            VStack(alignment: .leading, spacing: Tokens.inset) {
                content
            }
            .padding(Tokens.inset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous).fill(Tokens.row))
            .overlay(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
                .stroke(Tokens.line, lineWidth: 1))
        }
        .foregroundStyle(Tokens.text)
    }
}

/// A permission / warning notice — a `warning`-tinted card (icon + title + body + a button-like
/// deep-link). Reads as an alert, not another form row. Reused for any "grant this to continue" prompt.
public struct NoticeCard: View {
    private let title: String
    private let message: String
    private let linkLabel: String
    private let url: URL

    public init(title: String, message: String, linkLabel: String, url: URL) {
        self.title = title
        self.message = message
        self.linkLabel = linkLabel
        self.url = url
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Tokens.micro) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .font(Tokens.caption.weight(.semibold)).foregroundStyle(Tokens.warning)
            Text(message).font(Tokens.caption).foregroundStyle(Tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            LinkButton(linkLabel, url: url, systemImage: "gearshape")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Tokens.inset)
        .background(RoundedRectangle(cornerRadius: Tokens.radius, style: .continuous)
            .fill(Tokens.warning.opacity(0.12)))
    }
}
