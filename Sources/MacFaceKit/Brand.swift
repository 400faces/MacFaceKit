import SwiftUI
import AppKit

/// Company brand marks (Simple Icons, https://simpleicons.org) bundled as template PDFs so a company
/// gets its REAL logo, tinted to the current color — not an approximate SF Symbol. Add marks as apps
/// need them; each is a monochrome `template` image tintable via `.foregroundStyle`.
public enum Brand {
    /// The GitHub octocat mark (Simple Icons), as a tintable template `Image`.
    public static let github = mark("github")

    /// Deliberately NOT `Bundle.module`.
    ///
    /// SwiftPM generates `Bundle.module` as a `static let` that calls `fatalError` when it cannot
    /// find the bundle, and it looks in exactly two places: `Bundle.main.bundleURL` and an ABSOLUTE
    /// BUILD PATH baked in at compile time. That build path exists on the machine that compiled the
    /// binary and nowhere else, so an app shipped to anybody else traps the first time anything
    /// touches a mark.
    ///
    /// It also made the fallback in `mark(_:)` DEAD CODE: the process trapped inside the accessor
    /// before the `guard` could run. PushText 0.2.0 shipped that way and crashed on launch for its
    /// only user, with `EXC_BREAKPOINT` in `variable initialization expression of static
    /// NSBundle.module`.
    ///
    /// `Contents/Resources` is in the list because it is the only place a resource bundle can live
    /// in a SIGNED .app - measured both ways: at the app root, `codesign --verify --strict` rejects
    /// the app with "code has no resources but signature indicates they must be present", and in
    /// `Contents/Resources` SwiftPM's own accessor never looks.
    static var resourceBundle: Bundle? {
        let name = "MacFaceKit_MacFaceKit.bundle"
        let own = Bundle(for: BundleToken.self)
        let candidates = [
            own.resourceURL,            // this framework's own resources
            own.bundleURL,
            Bundle.main.resourceURL,    // .app/Contents/Resources — the signable location
            Bundle.main.bundleURL       // .app root — where SwiftPM's accessor looks
        ].compactMap { $0 }

        for base in candidates where Bundle(url: base.appendingPathComponent(name)) != nil {
            return Bundle(url: base.appendingPathComponent(name))
        }
        // Statically linked, or resources processed straight into the host bundle: the marks may
        // simply be here. Returning this rather than nil keeps `mark(_:)` on its normal path, and
        // `mark` still falls back safely if the file is genuinely absent.
        return own
    }

    static func mark(_ name: String) -> Image {
        guard let url = resourceBundle?.url(forResource: name, withExtension: "pdf"),
              let nsImage = NSImage(contentsOf: url) else {
            return Image(systemName: "link")   // safe fallback if the asset is missing
        }
        nsImage.isTemplate = true
        return Image(nsImage: nsImage)
    }
}

/// Anchors `Bundle(for:)` to this framework rather than to whoever calls it.
private final class BundleToken {}
