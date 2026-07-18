import Foundation
import Testing

@Suite("Overflow attention indicator")
struct OverflowAttentionTests {
    @Test("overflow attention is derived from action state")
    func overflowAttentionIsDerivedFromActionState() {
        let source = Self.source("Sources/MacFaceKit/OverflowMenu.swift")

        #expect(source.contains("actions.contains { $0.attention }"))
        #expect(source.contains("attention: actions.contains"))
    }

    @Test("icon button renders attention through shared dot")
    func iconButtonRendersAttentionThroughSharedDot() {
        let source = Self.source("Sources/MacFaceKit/IconButton.swift")

        #expect(source.contains("attention: Bool = false"))
        #expect(source.contains("AttentionDot()"))
    }

    @Test("attention dot is a reusable component")
    func attentionDotIsReusableComponent() {
        let source = Self.source("Sources/MacFaceKit/AttentionDot.swift")

        #expect(source.contains("public struct AttentionDot"))
        #expect(source.contains("accessibilityHidden(true)"))
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
