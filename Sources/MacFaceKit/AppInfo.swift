import Foundation

/// The shared version reader — the one place that extracts an app's marketing `version` + `build` from
/// its bundle, with crash-safe fallbacks so an unbundled process (`swift run`/tests) never crashes or
/// shows a blank version. This is the GENERIC logic every 400faces app duplicated; app-specific data
/// (name, repo/license URLs) stays app-local and is passed to `AppIdentityCard` at the call site.
public struct AppInfo: Sendable {
    /// Marketing version (`CFBundleShortVersionString`), or `"dev"` when unbundled.
    public let version: String
    /// Build number (`CFBundleVersion`), or `"0"` when unbundled.
    public let build: String

    /// The identity-card version line: `"1.2.3 (42)"`. One home for the format, so both apps match.
    public var displayVersion: String { "\(version) (\(build))" }

    public init(version: String, build: String) {
        self.version = version
        self.build = build
    }

    /// Pure derivation from an Info-plist dictionary — the testable seam (no disk, no real `Bundle`).
    /// A key that is absent OR present-but-empty falls back.
    public static func from(infoDictionary: [String: Any]?) -> AppInfo {
        func value(_ key: String, fallback: String) -> String {
            guard let string = infoDictionary?[key] as? String, !string.isEmpty else { return fallback }
            return string
        }
        return AppInfo(version: value("CFBundleShortVersionString", fallback: "dev"),
                       build: value("CFBundleVersion", fallback: "0"))
    }

    /// The production accessor — reads the running bundle (default `.main`).
    public static func fromBundle(_ bundle: Bundle = .main) -> AppInfo {
        from(infoDictionary: bundle.infoDictionary)
    }
}
