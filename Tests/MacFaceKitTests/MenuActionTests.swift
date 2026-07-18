import Testing
@testable import MacFaceKit

/// #28 — the pure `MenuAction` model behind `OverflowMenu`. The View isn't unit-testable (SwiftUI in
/// SPM), but the item wiring is: defaults, and that invoking runs the closure exactly once.
@Suite("MenuAction")
struct MenuActionTests {
    @Test("defaults: not destructive, enabled")
    func defaults() {
        let a = MenuAction(title: "Check for Updates", systemImage: "arrow.triangle.2.circlepath") {}
        #expect(a.title == "Check for Updates")
        #expect(a.systemImage == "arrow.triangle.2.circlepath")
        #expect(a.destructive == false)
        #expect(a.enabled == true)
        #expect(a.attention == false)
    }

    @Test("destructive + disabled + attention flags carry through")
    func flags() {
        let a = MenuAction(title: "Uninstall…", systemImage: "trash", destructive: true,
                           enabled: false, attention: true) {}
        #expect(a.destructive == true)
        #expect(a.enabled == false)
        #expect(a.attention == true)
    }

    @Test("invoke runs the action once")
    func invoke() {
        final class Counter: @unchecked Sendable { var n = 0 }
        let c = Counter()
        let a = MenuAction(title: "Quit", systemImage: "power") { c.n += 1 }
        a.action()
        #expect(c.n == 1)
    }
}
