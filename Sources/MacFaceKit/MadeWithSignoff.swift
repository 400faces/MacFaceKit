import SwiftUI

/// The quiet "Made with ♥ & 🤖" sign-off. Both glyphs are icons, not emoji; the robot is hand-drawn
/// (no robot SF Symbol) and vendor-neutral — "built with AI". (Ported from RememBar's MadeWithSignoff.)
public struct MadeWithSignoff: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 3) {
            Text("Made with")
            Image(systemName: "heart.fill").font(.system(size: 8)).foregroundStyle(.pink)
            Text("&")
            RobotGlyph(color: Tokens.muted).frame(width: 12, height: 12)
        }
        .font(Tokens.caption)
        .foregroundStyle(Tokens.quiet)
    }
}

/// A minimal robot head (antenna + rounded head + two eyes), drawn to read cleanly at ~12pt.
/// (Ported from RememBar's RobotGlyph.)
public struct RobotGlyph: View {
    private let color: Color

    public init(color: Color) { self.color = color }

    public var body: some View {
        Canvas { context, size in
            let side = size.width
            func pt(_ px: CGFloat, _ py: CGFloat) -> CGPoint { CGPoint(x: px * side, y: py * side) }
            let line = side * 0.09

            var stem = Path()
            stem.move(to: pt(0.5, 0.14))
            stem.addLine(to: pt(0.5, 0.30))
            context.stroke(stem, with: .color(color), lineWidth: line)
            let ball = side * 0.085
            context.fill(
                Path(ellipseIn: CGRect(x: 0.5 * side - ball, y: 0.06 * side, width: ball * 2, height: ball * 2)),
                with: .color(color))

            let head = Path(
                roundedRect: CGRect(x: 0.16 * side, y: 0.30 * side, width: 0.68 * side, height: 0.60 * side),
                cornerRadius: 0.18 * side)
            context.stroke(head, with: .color(color), lineWidth: line)

            let eye = side * 0.08
            for cx in [0.37, 0.63] {
                context.fill(
                    Path(ellipseIn: CGRect(x: cx * side - eye, y: 0.58 * side - eye, width: eye * 2, height: eye * 2)),
                    with: .color(color))
            }
        }
    }
}
