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

        #expect(source.contains(".overlay(alignment: .bottomTrailing)"),
                "attention should sit on the button's lower-right corner instead of reading as another ellipsis dot")
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
