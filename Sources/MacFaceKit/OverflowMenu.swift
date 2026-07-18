import SwiftUI

/// One item in an `OverflowMenu` dropdown. Pure data + a closure — the destructive/enabled wiring is
/// unit-testable even though the row View isn't.
public struct MenuAction {
    public let title: String
    public let systemImage: String
    public let destructive: Bool
    public let enabled: Bool
    public let attention: Bool
    public let attentionAccessibilityHint: String?
    public let action: () -> Void

    public init(title: String, systemImage: String, destructive: Bool = false,
                enabled: Bool = true, attention: Bool = false,
                attentionAccessibilityHint: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.destructive = destructive
        self.enabled = enabled
        self.attention = attention
        self.attentionAccessibilityHint = attentionAccessibilityHint
        self.action = action
    }
}

/// The `···` overflow: an `IconButton` (lifts while open) opening a custom dark dropdown of `MenuRow`s
/// on `Tokens.field` — RememBar's dropdown, as one component. Selecting a row closes the popover FIRST,
/// then runs its action (so an action that opens a modal doesn't fight the popover dismissal). Both
/// apps get the identical `···` by passing `[MenuAction]`.
public struct OverflowMenu: View {
    private let actions: [MenuAction]
    private let width: CGFloat
    @State private var open = false

    public init(_ actions: [MenuAction], width: CGFloat = 210) {
        self.actions = actions
        self.width = width
    }

    private var attentionAccessibilityHint: String? {
        actions.first { $0.attention && $0.attentionAccessibilityHint != nil }?.attentionAccessibilityHint
    }

    public var body: some View {
        IconButton(systemImage: "ellipsis", active: open, attention: actions.contains { $0.attention },
                   accessibilityHint: attentionAccessibilityHint) {
            open.toggle()
        }
            .popover(isPresented: $open, arrowEdge: .bottom) {
                VStack(spacing: 1) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { _, item in
                        MenuRow(title: item.title, systemImage: item.systemImage,
                                destructive: item.destructive, enabled: item.enabled,
                                attention: item.attention,
                                attentionAccessibilityHint: item.attentionAccessibilityHint) {
                            open = false
                            item.action()
                        }
                    }
                }
                .padding(Tokens.micro + 2)
                .frame(width: width)
                .background(Tokens.field)
            }
    }
}
