import SwiftUI
import AppKit

/// The app's identity tile (a macOS squircle), sized by the caller's `.frame`. Prefers an explicitly
/// provided `bundledImage` (an app's own icon resource — the only icon that renders correctly under
/// `swift run`, where `applicationIconImage` is a generic folder), then the running app's icon, then a
/// rounded `field` tile with a monogram. The single way apps render their identity tile. (From RememBar.)
public struct AppIconView: View {
    private let bundledImage: NSImage?
    private let fallbackMonogram: String

    public init(bundledImage: NSImage? = nil, fallbackMonogram: String = "") {
        self.bundledImage = bundledImage
        self.fallbackMonogram = fallbackMonogram
    }

    public var body: some View {
        if let icon = bundledImage ?? NSApplication.shared.applicationIconImage {
            Image(nsImage: icon)
                .resizable()
                .interpolation(.high)
                .aspectRatio(1, contentMode: .fit)   // never stretch — the icon stays square (squircle)
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Tokens.field)
                .overlay(
                    Text(fallbackMonogram)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Tokens.muted)
                )
        }
    }
}
