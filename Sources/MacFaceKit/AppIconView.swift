import SwiftUI
import AppKit

/// The running app's icon (a macOS squircle), sized by the caller's `.frame`. Falls back to a rounded
/// `field` tile with a monogram when no icon is available (e.g. an un-bundled `swift run`). The single
/// way apps render their identity tile, so the header looks the same everywhere. (From RememBar.)
public struct AppIconView: View {
    private let fallbackMonogram: String

    public init(fallbackMonogram: String = "") {
        self.fallbackMonogram = fallbackMonogram
    }

    public var body: some View {
        if let icon = NSApplication.shared.applicationIconImage {
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
