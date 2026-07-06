import AppKit
import SwiftUI

/// The shared, Sparkle-FREE machinery behind the update dialog: it owns the update window (a borderless
/// floating panel that morphs smoothly between states), the flow model, the escape/acknowledgement
/// bookkeeping, and the download byte→fraction math. Each app pairs it with a thin `SPUUserDriver`
/// adapter that translates Sparkle callbacks into the semantic `show*` calls below — so everything that
/// is *not* a Sparkle type lives here once, and the per-app adapter is pure translation.
///
/// Threading: `@MainActor`; the semantic API is called from the app's `@MainActor` user driver.
@MainActor
public final class UpdateWindowController: NSObject, NSWindowDelegate {
    let model = UpdateFlowModel()   // internal (not private) so behavioral tests can inspect state
    private let appName: String
    private let icon: NSImage?
    private var window: NSWindow?
    private var expectedLength: UInt64 = 0
    private var receivedLength: UInt64 = 0
    /// What to run if the user closes the window via the traffic-light control (the appropriate
    /// cancel / dismiss / acknowledge). Cleared once fired so it can't run twice.
    private var escape: (() -> Void)?
    /// The pending acknowledgement continuation for the async (up-to-date / error) states.
    private var pendingAck: CheckedContinuation<Void, Never>?

    public init(appName: String, icon: NSImage?) {
        self.appName = appName
        self.icon = icon
    }

    // MARK: - Semantic API (the app's SPUUserDriver adapter calls these)

    public func showPermission(onAllow: @escaping () -> Void, onDecline: @escaping () -> Void) {
        let allow = disarm(onAllow)
        let decline = disarm(onDecline)
        show(.permission(allow: allow, decline: decline), escape: decline)
    }

    public func showChecking(onCancel: @escaping () -> Void) {
        model.fraction = nil
        model.releaseNotes = nil
        let cancel = disarm(onCancel)
        show(.checking(cancel: cancel), escape: cancel)
    }

    public func showAvailable(version: String, currentVersion: String, notes: [String],
                              onInstall: @escaping () -> Void, onRemindLater: @escaping () -> Void) {
        model.latestVersion = version
        model.releaseNotes = notes
        let install = disarm(onInstall)
        let remind = disarm(onRemindLater)
        // "Remind Me Later" (the secondary) is also the traffic-light escape.
        show(.available(version: version, current: currentVersion, remindLater: remind, install: install),
             escape: remind)
    }

    /// Late-arriving downloaded release notes (the `releaseNotesLink` path) replace the "What's new"
    /// list on an already-visible available dialog, morphing the window to fit.
    public func updateReleaseNotes(_ notes: [String]) {
        withAnimation(.easeInOut(duration: 0.22)) { model.releaseNotes = notes }
        syncWindowSize(animated: true)
    }

    public func showDownloadStarting(onCancel: @escaping () -> Void) {
        expectedLength = 0
        receivedLength = 0
        model.fraction = 0
        let cancel = disarm(onCancel)
        show(.progress(heading: "Downloading update…", cancel: cancel), escape: cancel)
    }

    public func setExpectedContentLength(_ length: UInt64) {
        expectedLength = length
    }

    public func addReceivedBytes(_ length: UInt64) {
        receivedLength += length
        model.fraction = expectedLength > 0 ? min(1, Double(receivedLength) / Double(expectedLength)) : nil
    }

    public func showPreparing() {
        model.fraction = 0
        show(.progress(heading: "Preparing update…", cancel: nil), escape: nil)
    }

    public func updateProgress(_ fraction: Double) {
        model.fraction = fraction
    }

    public func showInstalling() {
        model.fraction = nil
        show(.progress(heading: "Installing…", cancel: nil), escape: nil)
    }

    public func showReady(onRestart: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        let restart = disarm(onRestart)
        show(.ready(version: model.latestVersion, install: restart), escape: onDismiss)
    }

    /// Up-to-date is a terminal, acknowledged state: the button resumes the caller AND closes; closing
    /// via the traffic light resumes only (the window is already going away). Suspends until acked.
    public func showUpToDate(version: String) async {
        await ackScreen { ack in .upToDate(version: version, ok: ack) }
    }

    public func showError(message: String) async {
        await ackScreen { ack in .error(message: message, ok: ack) }
    }

    /// Bring an existing dialog back to the front (Sparkle's `showUpdateInFocus`).
    public func showInFocus() {
        present()
    }

    /// Programmatic close (a button chose install/dismiss, or Sparkle finished). Resumes any pending
    /// acknowledgement first so its async task can't leak if the dialog is torn down un-acked.
    public func close() {
        resumeAck()
        escape = nil
        window?.delegate = nil
        window?.close()
        window = nil
    }

    // MARK: - Internals

    /// The shared shape of the two async acknowledged states: park a continuation, wire button =
    /// resume + close and escape = resume-only, and suspend until one fires.
    private func ackScreen(_ makeScreen: (@escaping () -> Void) -> UpdateFlowModel.Screen) async {
        await withCheckedContinuation { continuation in
            pendingAck = continuation
            let ack = { [weak self] in self?.resumeAck(); self?.close() }
            show(makeScreen(ack), escape: { [weak self] in self?.resumeAck() })
        }
    }

    private func resumeAck() {
        if let continuation = pendingAck {
            pendingAck = nil
            continuation.resume()
        }
    }

    /// Wrap a button action so pressing it disarms the traffic-light escape (the button owns the
    /// outcome now — the escape must not also fire).
    private func disarm(_ action: @escaping () -> Void) -> () -> Void {
        { [weak self] in
            self?.escape = nil
            action()
        }
    }

    private func show(_ screen: UpdateFlowModel.Screen, escape: (() -> Void)?) {
        self.escape = escape
        withAnimation(.easeInOut(duration: 0.22)) { model.screen = screen }
        present()
    }

    private func present() {
        let firstShow = (window == nil)
        if firstShow {
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 220),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            win.titlebarAppearsTransparent = true          // dark titlebar blends with the content
            win.appearance = NSAppearance(named: .darkAqua) // real, hover-capable traffic lights
            win.backgroundColor = Tokens.nsUpdateWindow
            win.isMovableByWindowBackground = true
            win.isReleasedWhenClosed = false
            win.delegate = self
            win.contentView = NSHostingView(rootView: UpdateFlowRootView(model: model, appName: appName, icon: icon))
            window = win
        }
        window?.title = ""   // no "Software Update" chrome — the header line carries the state
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        if firstShow { window?.center() }
        syncWindowSize(animated: !firstShow)
    }

    /// Fit the window to the current SwiftUI content, preserving the window's center so it grows and
    /// shrinks in place (a smooth morph between states rather than a jump). Deferred a runloop tick so
    /// SwiftUI has laid out first.
    private func syncWindowSize(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window, let content = window.contentView else { return }
            let size = content.fittingSize
            guard size.width > 0, size.height > 0 else { return }
            let old = window.frame
            var newFrame = window.frameRect(forContentRect: NSRect(origin: .zero, size: size))
            newFrame.origin = NSPoint(x: old.midX - newFrame.width / 2, y: old.midY - newFrame.height / 2)
            window.setFrame(newFrame, display: true, animate: animated)
        }
    }

    /// User clicked the window's close control. Fire the escape action (cancel / dismiss / ack) once.
    public func windowWillClose(_ notification: Notification) {
        let action = escape
        escape = nil
        window = nil
        action?()
    }
}

// MARK: - Model + root view (internal — the app touches only the controller's semantic API)

/// The model backing the update window. The controller mutates `screen` (variant transitions) and
/// `fraction` (progress ticks) separately, so a flood of download-progress callbacks updates the bar
/// in place — no re-hosting the SwiftUI on every chunk.
@MainActor
final class UpdateFlowModel: ObservableObject {
    enum Screen {
        case permission(allow: () -> Void, decline: () -> Void)
        case checking(cancel: () -> Void)
        case available(version: String, current: String, remindLater: () -> Void, install: () -> Void)
        case progress(heading: String, cancel: (() -> Void)?)
        case ready(version: String, install: () -> Void)
        case upToDate(version: String, ok: () -> Void)
        case error(message: String, ok: () -> Void)
    }

    @Published var screen: Screen = .checking(cancel: {})
    @Published var fraction: Double?
    @Published var releaseNotes: [String]?
    @Published var notesExpanded = true
    /// The version being installed (from the appcast), shown on the progress + ready screens.
    var latestVersion = "the update"
}

/// Maps the model's current `Screen` to the shared `UpdateDialog`, applying the app's name + icon.
struct UpdateFlowRootView: View {
    @ObservedObject var model: UpdateFlowModel
    let appName: String
    let icon: NSImage?

    var body: some View {
        dialog.icon(icon).fixedSize()
    }

    private var dialog: UpdateDialog {
        switch model.screen {
        case let .permission(allow, decline):
            return .permission(appName: appName, onAllow: allow, onDecline: decline)
        case let .checking(cancel):
            return .checking(onCancel: cancel)
        case let .available(version, current, remindLater, install):
            return .available(appName: appName, version: version, currentVersion: current,
                              notes: model.releaseNotes ?? [], notesExpanded: $model.notesExpanded,
                              onInstall: install, onRemindLater: remindLater)
        case let .progress(heading, cancel):
            return .progress(appName: appName, heading: heading, version: model.latestVersion,
                             fraction: model.fraction, onCancel: cancel)
        case let .ready(version, install):
            return .ready(appName: appName, version: version, onRestart: install)
        case let .upToDate(version, ok):
            return .upToDate(appName: appName, version: version, onOK: ok)
        case let .error(message, ok):
            return .error(message: message, onOK: ok)
        }
    }
}
