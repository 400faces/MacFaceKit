import SwiftUI

/// Small reusable attention mark for icon-sized controls. It is decorative; callers expose the
/// semantic state through their control label or surrounding context.
public struct AttentionDot: View {
    private let size: CGFloat
    private let color: Color

    public init(size: CGFloat = Tokens.attentionDot, color: Color = Tokens.warning) {
        self.size = size
        self.color = color
    }

    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
