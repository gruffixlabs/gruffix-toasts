#if os(macOS)
import AppKit
import SwiftUI

/// Shows the host's toasts in a child window above its window, so they stay visible over sheets
/// and popovers. The view itself is invisible; it finds the window and tracks the pointer.
struct ToastOverlayInstaller: NSViewRepresentable {
    let center: ToastCenter

    func makeCoordinator() -> ToastOverlay {
        ToastOverlay()
    }

    func makeNSView(context: Context) -> ToastWindowProbe {
        ToastWindowProbe(overlay: context.coordinator)
    }

    func updateNSView(_ probe: ToastWindowProbe, context: Context) {
        context.coordinator.update(center: center, appearance: ToastOverlayAppearance(context.environment))
    }

    static func dismantleNSView(_ probe: ToastWindowProbe, coordinator: ToastOverlay) {
        coordinator.remove()
    }
}

/// Reports the window the host lives in, and where the pointer is over it.
final class ToastWindowProbe: NSView {
    private let overlay: ToastOverlay

    init(overlay: ToastOverlay) {
        self.overlay = overlay
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // Never the target of a click; the probe sits behind the host's content.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        overlay.attach(to: window)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        // Tracking areas report the pointer even where other views cover the probe, so the
        // overlay learns when the pointer reaches a toast.
        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self
        ))
    }

    override func mouseMoved(with event: NSEvent) {
        overlay.pointerMoved(toWindowLocation: event.locationInWindow)
    }

    override func mouseExited(with event: NSEvent) {
        overlay.pointerMoved(toWindowLocation: nil)
    }
}

/// Owns one host's overlay window.
final class ToastOverlay {
    private var panel: NSPanel?
    private weak var parent: NSWindow?
    private var center: ToastCenter?
    private var appearance: ToastOverlayAppearance?
    /// The toasts' frame in the panel's content view, which is flipped like SwiftUI's.
    private var toastFrame: CGRect = .zero
    private var resizeTask: Task<Void, Never>?

    func attach(to window: NSWindow?) {
        guard window !== parent else { return }
        remove()
        guard let window else { return }
        let panel = NSPanel(
            contentRect: window.contentLayoutRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isReleasedWhenClosed = false
        panel.becomesKeyOnlyIfNeeded = true
        // Clicks pass through until the pointer is over a toast.
        panel.ignoresMouseEvents = true
        panel.contentView = NSHostingView(rootView: rootView())
        window.addChildWindow(panel, ordered: .above)
        self.panel = panel
        parent = window
        layoutPanel()
        observeResizes(of: window)
    }

    func update(center: ToastCenter, appearance: ToastOverlayAppearance) {
        self.center = center
        self.appearance = appearance
        (panel?.contentView as? NSHostingView<AnyView>)?.rootView = rootView()
    }

    func remove() {
        resizeTask?.cancel()
        resizeTask = nil
        if let panel {
            parent?.removeChildWindow(panel)
            panel.orderOut(nil)
        }
        panel = nil
        parent = nil
    }

    func pointerMoved(toWindowLocation location: NSPoint?) {
        guard let panel, let parent, let contentView = panel.contentView else { return }
        guard let location, let center, !center.visible.isEmpty else {
            panel.ignoresMouseEvents = true
            return
        }
        let screenPoint = parent.convertPoint(toScreen: location)
        let point = contentView.convert(panel.convertPoint(fromScreen: screenPoint), from: nil)
        panel.ignoresMouseEvents = !toastFrame.contains(point)
    }

    /// Covers the parent's content area, below its title bar and toolbar.
    private func layoutPanel() {
        guard let panel, let parent else { return }
        panel.setFrame(parent.convertToScreen(parent.contentLayoutRect), display: true)
    }

    private func observeResizes(of window: NSWindow) {
        resizeTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: NSWindow.didResizeNotification, object: window) {
                self?.layoutPanel()
            }
        }
    }

    private func rootView() -> AnyView {
        guard let center, let appearance else { return AnyView(EmptyView()) }
        return AnyView(
            ToastOverlayRoot(center: center, appearance: appearance) { [weak self] frame in
                self?.toastFrame = frame
            }
        )
    }
}
#endif
