import Foundation
import Testing

@Suite("Overflow attention indicator")
struct OverflowAttentionTests {
    @Test("overflow attention is derived from action state")
    func overflowAttentionIsDerivedFromActionState() {
        let source = Self.source("Sources/MacFaceKit/OverflowMenu.swift")

        #expect(source.contains("actions.contains { $0.attention }"))
        #expect(source.contains("attention: actions.contains"))
        #expect(source.contains("accessibilityHint: attentionAccessibilityHint"))
        #expect(source.contains("$0.attention && $0.attentionAccessibilityHint != nil"))
        #expect(source.contains("?.attentionAccessibilityHint"))
    }

    @Test("overflow passes row attention and semantics through")
    func overflowPassesRowAttentionAndSemanticsThrough() {
        let source = Self.source("Sources/MacFaceKit/OverflowMenu.swift")

        #expect(source.contains("attention: item.attention"))
        #expect(source.contains("attentionAccessibilityHint: item.attentionAccessibilityHint"))
    }

    @Test("icon button renders attention through shared dot")
    func iconButtonRendersAttentionThroughSharedDot() {
        let source = Self.source("Sources/MacFaceKit/IconButton.swift")

        #expect(source.contains("attention: Bool = false"))
        #expect(source.contains("AttentionDot(size: Tokens.attentionDot)"))
    }

    @Test("attention dot size is tokenized once")
    func attentionDotSizeIsTokenizedOnce() {
        let tokens = Self.source("Sources/MacFaceKit/Tokens.swift")
        let dot = Self.source("Sources/MacFaceKit/AttentionDot.swift")

        #expect(tokens.contains("public static let attentionDot"),
                "attention dot size should be a shared design token, not a per-control magic number")
        #expect(dot.contains("size: CGFloat = Tokens.attentionDot"),
                "AttentionDot's default size should use the shared token")
    }

    @Test("icon button anchors attention at the button corner")
    func iconButtonAnchorsAttentionAtTheButtonCorner() {
        let source = Self.source("Sources/MacFaceKit/IconButton.swift")

        #expect(source.contains(".overlay(alignment: .topTrailing)"),
                "attention should sit on the button's upper-right badge corner")
        #expect(!source.contains(".overlay(alignment: .bottomTrailing)"))
        #expect(!source.contains("ZStack(alignment: .topTrailing)"))
    }

    @Test("icon button accepts caller-owned accessibility hint")
    func iconButtonAcceptsCallerOwnedAccessibilityHint() {
        let source = Self.source("Sources/MacFaceKit/IconButton.swift")

        #expect(source.contains("accessibilityHint: String? = nil"))
        #expect(source.contains(".accessibilityHint(resolvedAccessibilityHint)"))
    }

    @Test("attention dot is a reusable component")
    func attentionDotIsReusableComponent() {
        let source = Self.source("Sources/MacFaceKit/AttentionDot.swift")

        #expect(source.contains("public struct AttentionDot"))
        #expect(source.contains("accessibilityHidden(true)"))
    }

    @Test("menu row renders decorative attention with caller-owned semantics")
    func menuRowRendersDecorativeAttentionWithCallerOwnedSemantics() {
        let source = Self.source("Sources/MacFaceKit/MenuRow.swift")

        #expect(source.contains("attention: Bool = false"))
        #expect(source.contains("attentionAccessibilityHint: String? = nil"))
        #expect(source.contains("AttentionDot(size: Tokens.attentionDot)"))
        #expect(source.contains(".accessibilityHint(accessibilityHint)"))
        #expect(!source.contains("Update available"),
                "MacFaceKit must expose generic semantics without hardcoding app-specific update copy")
    }

    @Test("notice card uses the shared button-like settings link")
    func noticeCardUsesSharedButtonLikeSettingsLink() {
        let source = Self.source("Sources/MacFaceKit/SectionCard.swift")

        #expect(source.contains("linkLabel: String, url: URL"),
                "notice cards should preserve the direct settings-link API")
        #expect(source.contains("actionLabel: linkLabel"),
                "the URL initializer should delegate into the shared action path")
        #expect(source.contains("LinkButton(actionLabel"),
                "notice actions should use the shared full-width link button affordance")
        #expect(!source.contains("ExternalLink(linkLabel, url)"),
                "warning notices should not hide required actions behind a low-emphasis text link")
    }

    @Test("notice card supports caller-owned actions without duplicating button styling")
    func noticeCardSupportsCallerOwnedActionsWithoutDuplicatingButtonStyling() {
        let notice = Self.source("Sources/MacFaceKit/SectionCard.swift")
        let linkButton = Self.source("Sources/MacFaceKit/LinkButton.swift")

        #expect(notice.contains("actionLabel: String"),
                "notice cards need a generic action path for reset-and-open flows")
        #expect(notice.contains("LinkButton(actionLabel"),
                "notice action rows should still use the shared button-like affordance")
        #expect(linkButton.contains("action: @escaping () -> Void"),
                "LinkButton should own the reusable styling while callers own behavior")
        #expect(!notice.contains("Button {"),
                "NoticeCard must not duplicate LinkButton's button styling")
    }

    private static func source(_ path: String) -> String {
        let root = repoRoot()
        return (try? String(contentsOf: root.appending(path: path), encoding: .utf8)) ?? ""
    }

    private static func repoRoot() -> URL {
        var dir = URL(filePath: #filePath).deletingLastPathComponent()
        while dir.path != "/" {
            if FileManager.default.fileExists(atPath: dir.appending(path: "Package.swift").path) {
                return dir
            }
            dir = dir.deletingLastPathComponent()
        }
        fatalError("could not locate Package.swift above \(#filePath)")
    }
}
