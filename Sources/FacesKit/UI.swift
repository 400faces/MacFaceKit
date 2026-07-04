import SwiftUI

/// Neutral spacing / radius tokens shared across ECN macOS apps. Colors are deliberately NOT tokenized
/// here — components use system-adaptive colors (`.primary`, `.secondary`, `.accentColor`, `.red`) so
/// each app adapts to light/dark rather than inheriting one app's fixed palette. A brand palette can
/// be layered later as an explicit theme if a project wants it.
public enum UI {
    public static let space: CGFloat = 8
    public static let micro: CGFloat = 4
    public static let radius: CGFloat = 8
    /// Shared height for a full-width action/control row.
    public static let controlRow: CGFloat = 30
}
