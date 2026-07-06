import AppKit
import Foundation
@testable import MacFaceKit
import Testing

/// The behavioral net RememBar's monolithic driver never had: the update flow's transitions, byte→
/// fraction math, escape-fires-once guard, and the acknowledgement continuation are now in a Sparkle-
/// free controller, so they're directly assertable without Sparkle. These pin the dynamics that a
/// static render can't (the reason the extraction is safe to do on a shipping flow).
@MainActor
struct UpdateWindowControllerTests {
    private func controller() -> UpdateWindowController {
        UpdateWindowController(appName: "TestApp", icon: nil)
    }

    // MARK: Screen transitions + resets

    @Test func showCheckingClearsNotesAndFraction() {
        let c = controller()
        c.model.releaseNotes = ["stale"]
        c.model.fraction = 0.5
        c.showChecking(onCancel: {})
        #expect(c.model.releaseNotes == nil)
        #expect(c.model.fraction == nil)
        guard case .checking = c.model.screen else { Issue.record("expected .checking"); return }
    }

    @Test func showAvailableRetainsVersionAndNotes() {
        let c = controller()
        c.showAvailable(version: "2.0.0", currentVersion: "1.0.0", notes: ["A", "B"],
                        onInstall: {}, onRemindLater: {})
        #expect(c.model.latestVersion == "2.0.0")
        #expect(c.model.releaseNotes == ["A", "B"])
        guard case .available = c.model.screen else { Issue.record("expected .available"); return }
    }

    @Test func updateReleaseNotesReplacesTheList() {
        let c = controller()
        c.showAvailable(version: "2.0.0", currentVersion: "1.0.0", notes: ["old"],
                        onInstall: {}, onRemindLater: {})
        c.updateReleaseNotes(["new one", "new two"])
        #expect(c.model.releaseNotes == ["new one", "new two"])
    }

    @Test func progressScreensUseRetainedLatestVersion() {
        let c = controller()
        c.showAvailable(version: "3.1.0", currentVersion: "3.0.0", notes: [], onInstall: {}, onRemindLater: {})
        c.showDownloadStarting(onCancel: {})
        #expect(c.model.latestVersion == "3.1.0")   // reused on the progress screen
        #expect(c.model.fraction == 0)
        guard case let .progress(heading, _) = c.model.screen else { Issue.record("expected .progress"); return }
        #expect(heading == "Downloading update…")
    }

    // MARK: Download byte → fraction math (lives in the controller, not duplicated per app)

    @Test func receivedBytesComputeFraction() {
        let c = controller()
        c.showDownloadStarting(onCancel: {})
        c.setExpectedContentLength(1000)
        c.addReceivedBytes(250)
        #expect(c.model.fraction == 0.25)
        c.addReceivedBytes(750)
        #expect(c.model.fraction == 1.0)
        c.addReceivedBytes(500)             // over-delivery clamps at 1.0
        #expect(c.model.fraction == 1.0)
    }

    @Test func indeterminateWhenNoExpectedLength() {
        let c = controller()
        c.showDownloadStarting(onCancel: {})
        c.addReceivedBytes(500)             // expected length still 0 → indeterminate
        #expect(c.model.fraction == nil)
    }

    @Test func preparingResetsFractionInstallingClearsIt() {
        let c = controller()
        c.showPreparing()
        #expect(c.model.fraction == 0)
        c.updateProgress(0.4)
        #expect(c.model.fraction == 0.4)
        c.showInstalling()
        #expect(c.model.fraction == nil)
    }

    // MARK: Escape-fires-once (traffic-light close)

    @Test func windowWillCloseFiresEscapeExactlyOnce() {
        let c = controller()
        var escapeCount = 0
        c.showChecking(onCancel: { escapeCount += 1 })   // escape = cancel
        let note = Notification(name: NSWindow.willCloseNotification)
        c.windowWillClose(note)
        c.windowWillClose(note)                          // second must be a no-op
        #expect(escapeCount == 1)
    }

    @Test func buttonDisarmsTheEscape() {
        let c = controller()
        var cancelCount = 0
        c.showChecking(onCancel: { cancelCount += 1 })
        // Simulate the button firing by invoking the cancel closure the model holds, then closing:
        if case let .checking(cancel) = c.model.screen { cancel() }   // button press → disarms escape
        c.windowWillClose(Notification(name: NSWindow.willCloseNotification))
        #expect(cancelCount == 1)   // button ran once; escape was disarmed, so no double-fire
    }

    // MARK: Async acknowledgement continuation (up-to-date / error) — close() must resume it

    @Test func closeResumesPendingUpToDateAck() async {
        let c = controller()
        let task = Task { @MainActor in await c.showUpToDate(version: "1.0.0") }
        await Task.yield()                 // let the task park on the continuation
        c.close()                          // must resume it (the leak-guard)
        await task.value                   // returns iff the continuation resumed
        if case .upToDate = c.model.screen {} else { Issue.record("expected .upToDate screen") }
    }

    @Test func errorAckButtonResumes() async {
        let c = controller()
        let task = Task { @MainActor in await c.showError(message: "boom") }
        await Task.yield()
        if case let .error(_, ok) = c.model.screen { ok() }   // OK button = resume + close
        await task.value
        if case .error = c.model.screen {} else { Issue.record("expected .error screen") }
    }
}
