import SwiftUI
import AppKit

/// Company brand marks (Simple Icons, https://simpleicons.org) bundled as template PDFs so a company
/// gets its REAL logo, tinted to the current color — not an approximate SF Symbol. Add marks as apps
/// need them; each is a monochrome `template` image tintable via `.foregroundStyle`.
public enum Brand {
    /// The GitHub octocat mark (Simple Icons), as a tintable template `Image`.
    public static let github = mark("github")

    private static func mark(_ name: String) -> Image {
        guard let url = Bundle.module.url(forResource: name, withExtension: "pdf"),
              let nsImage = NSImage(contentsOf: url) else {
            return Image(systemName: "link")   // safe fallback if the asset is missing
        }
        nsImage.isTemplate = true
        return Image(nsImage: nsImage)
    }
}
