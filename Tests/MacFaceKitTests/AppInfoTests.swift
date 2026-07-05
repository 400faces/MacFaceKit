import Testing
@testable import MacFaceKit

/// #29-B1 — the generic version reader. Pure `from(infoDictionary:)` seam (no disk, no real Bundle):
/// version/build extraction + crash-safe fallbacks + the display string. NO app-specific data (name,
/// URLs) lives here — that stays app-local.
@Suite("AppInfo — version reader")
struct AppInfoTests {
    @Test("reads version + build from an info dictionary")
    func readsFromDictionary() {
        let info = AppInfo.from(infoDictionary: [
            "CFBundleShortVersionString": "1.2.3",
            "CFBundleVersion": "42"
        ])
        #expect(info.version == "1.2.3")
        #expect(info.build == "42")
        #expect(info.displayVersion == "1.2.3 (42)")
    }

    @Test("absent OR empty keys fall back (never blank, never crash unbundled)")
    func fallback() {
        #expect(AppInfo.from(infoDictionary: nil).version == "dev")
        #expect(AppInfo.from(infoDictionary: nil).build == "0")
        #expect(AppInfo.from(infoDictionary: [:]).version == "dev")
        #expect(AppInfo.from(infoDictionary: ["CFBundleShortVersionString": ""]).version == "dev")
        #expect(AppInfo.from(infoDictionary: ["CFBundleVersion": ""]).build == "0")
        #expect(AppInfo.from(infoDictionary: nil).displayVersion == "dev (0)")
    }
}
