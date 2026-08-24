import Testing
import AppKit
@testable import MacFaceKit

/// The shared update-indicator vocabulary (400faces/MacFaceKit#2).
///
/// Hoisted out of TermTile so every app shows "an update is waiting" the same way. TermTile already
/// drove `IconButton(attention:)` and `OverflowMenu` from this; PushText had the same Sparkle setup
/// and no indicator at all.
@Suite("Update availability")
struct UpdateAvailabilityTests {

    /// Only one state means "there is something to install". Checking and failed must NOT light the
    /// dot: a dot that appears while merely checking teaches the user to ignore it.
    @Test("Only .available marks attention")
    func onlyAvailableMarksAttention() {
        #expect(UpdateAvailability.available(version: "1.2.0").hasAvailableUpdate)
        #expect(UpdateAvailability.available(version: nil).hasAvailableUpdate)
        #expect(UpdateAvailability.unknown.hasAvailableUpdate == false)
        #expect(UpdateAvailability.checking.hasAvailableUpdate == false)
        #expect(UpdateAvailability.unavailable.hasAvailableUpdate == false)
        #expect(UpdateAvailability.failed.hasAvailableUpdate == false)
    }

    /// A failed check is not the same as "up to date". Collapsing them would tell the user they are
    /// current when the app has no idea.
    @Test("Failed and unavailable are distinct states")
    func failedIsNotUpToDate() {
        #expect(UpdateAvailability.failed != UpdateAvailability.unavailable)
    }

    @Test("The version rides along so a menu can name it")
    func versionIsCarried() {
        #expect(UpdateAvailability.available(version: "0.3.0") == .available(version: "0.3.0"))
        #expect(UpdateAvailability.available(version: "0.3.0") != .available(version: "0.4.0"))
    }
}

/// Badging a menu-bar image (400faces/MacFaceKit#2).
@Suite("Menu bar badge")
struct MenuBarBadgeTests {

    /// The dot is composited INTO the image rather than layered as a SwiftUI overlay, because
    /// `MenuBarExtra` flattens and tints overlay layers - TermTile hit that and left the note.
    /// So the badged image must be `isTemplate == false`: a template image would be re-tinted flat
    /// by the menu bar and the dot would vanish into the glyph colour.
    @Test("A badged image is not a template, or the menu bar would flatten the dot away")
    func badgedImageIsNotTemplate() throws {
        let badged = try #require(MenuBarBadge.badged(systemImage: "waveform", attention: true))
        #expect(badged.isTemplate == false)
    }

    /// Without attention there is nothing to composite, so the caller gets a plain template image
    /// that the menu bar can tint for light and dark exactly as it always has.
    @Test("Without attention the image stays a tintable template")
    func unbadgedStaysTemplate() throws {
        let plain = try #require(MenuBarBadge.badged(systemImage: "waveform", attention: false))
        #expect(plain.isTemplate)
    }

    /// A DOT must actually be drawn, in the warning colour, where the badge claims to put it.
    ///
    /// The first version of this test compared the plain and badged TIFFs and asserted they
    /// differed. It passed on an implementation that drew NOTHING - the badged canvas is wider by
    /// the inset, so the bytes differ whatever is painted on them. Caught by planting exactly that:
    /// deleting the fill left the suite green. Sampling the corner is the assertion that cannot be
    /// satisfied by resizing.
    @Test("A dot in the warning colour is actually painted in the corner")
    func badgePaintsADot() throws {
        let badged = try #require(MenuBarBadge.badged(systemImage: "waveform", attention: true))
        let tiff = try #require(badged.tiffRepresentation)
        let rep = try #require(NSBitmapImageRep(data: tiff))
        let warning = try #require(NSColor(Tokens.warning).usingColorSpace(.deviceRGB))

        // The dot sits at the trailing TOP. NSBitmapImageRep is top-left origin, so that is y ~ 0.
        var found = false
        for x in max(0, rep.pixelsWide - 6)..<rep.pixelsWide {
            for y in 0..<min(6, rep.pixelsHigh) {
                guard let pixel = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB),
                      pixel.alphaComponent > 0.5 else { continue }
                if abs(pixel.redComponent - warning.redComponent) < 0.08,
                   abs(pixel.greenComponent - warning.greenComponent) < 0.08,
                   abs(pixel.blueComponent - warning.blueComponent) < 0.08 {
                    found = true
                }
            }
        }
        #expect(found, "no warning-coloured pixel in the badge corner - was the dot drawn at all?")
    }

    /// An unknown symbol name must not crash the menu bar - the app would launch with no icon and
    /// no way to reach its own menu.
    @Test("An unknown symbol returns nil rather than trapping")
    func unknownSymbolIsSafe() {
        #expect(MenuBarBadge.badged(systemImage: "definitely.not.a.symbol", attention: true) == nil)
    }
}
