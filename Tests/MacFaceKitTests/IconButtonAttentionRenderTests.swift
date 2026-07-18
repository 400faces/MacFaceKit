import AppKit
import SwiftUI
import Testing
@testable import MacFaceKit

@MainActor
@Suite("IconButton attention render")
struct IconButtonAttentionRenderTests {
    @Test("attention dot renders in the lower-right quadrant without resizing the button")
    func attentionDotRendersInLowerRightQuadrantWithoutResizingTheButton() throws {
        let plain = try renderedButtonBitmap(attention: false)
        let attended = try renderedButtonBitmap(attention: true)

        #expect(plain.pixelsWide == attended.pixelsWide)
        #expect(plain.pixelsHigh == attended.pixelsHigh)

        let bounds = try #require(orangeFamilyBounds(in: attended))
        #expect(bounds.count > 20)
        #expect(bounds.minX > attended.pixelsWide / 2)
        #expect(bounds.minY > attended.pixelsHigh / 2)
    }

    @Test("menu row attention dot renders at the trailing edge without resizing the row")
    func menuRowAttentionDotRendersAtTheTrailingEdgeWithoutResizingTheRow() throws {
        let plain = try renderedRowBitmap(attention: false)
        let attended = try renderedRowBitmap(attention: true)

        #expect(plain.pixelsWide == attended.pixelsWide)
        #expect(plain.pixelsHigh == attended.pixelsHigh)

        let bounds = try #require(orangeFamilyBounds(in: attended))
        #expect(bounds.count > 20)
        #expect(bounds.minX > Int(Double(attended.pixelsWide) * 0.85))
    }

    private func renderedButtonBitmap(attention: Bool) throws -> NSBitmapImageRep {
        try renderedBitmap(for: IconButton(systemImage: "ellipsis", attention: attention) {})
    }

    private func renderedRowBitmap(attention: Bool) throws -> NSBitmapImageRep {
        try renderedBitmap(
            for: MenuRow(
                title: "Check for Updates",
                systemImage: "arrow.triangle.2.circlepath",
                attention: attention,
                attentionAccessibilityHint: "Update available"
            ) {}
            .frame(width: 210)
        )
    }

    private func renderedBitmap<Content: View>(for content: Content) throws -> NSBitmapImageRep {
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        let image = try #require(renderer.nsImage)
        let tiff = try #require(image.tiffRepresentation)
        return try #require(NSBitmapImageRep(data: tiff))
    }

    private func orangeFamilyBounds(in bitmap: NSBitmapImageRep) -> PixelBounds? {
        var bounds: PixelBounds?

        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.sRGB) else { continue }
                let red = color.redComponent
                let green = color.greenComponent
                let blue = color.blueComponent

                guard red > 0.75, green > 0.35, green < 0.82, blue < 0.45,
                      red > green, green > blue else { continue }

                if var existing = bounds {
                    existing.include(x: x, y: y)
                    bounds = existing
                } else {
                    bounds = PixelBounds(x: x, y: y)
                }
            }
        }

        return bounds
    }
}

private struct PixelBounds {
    private(set) var minX: Int
    private(set) var minY: Int
    private(set) var maxX: Int
    private(set) var maxY: Int
    private(set) var count: Int

    init(x: Int, y: Int) {
        minX = x
        minY = y
        maxX = x
        maxY = y
        count = 1
    }

    mutating func include(x: Int, y: Int) {
        minX = min(minX, x)
        minY = min(minY, y)
        maxX = max(maxX, x)
        maxY = max(maxY, y)
        count += 1
    }
}
