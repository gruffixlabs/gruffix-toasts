#if os(iOS) || os(tvOS)
import SwiftUI
import UIKit

/// Shows the host's toasts in a window above its scene, so they stay visible over sheets,
/// full-screen covers and popovers. The view itself is invisible; it only finds the scene.
struct ToastOverlayInstaller: UIViewRepresentable {
    let center: ToastCenter

    func makeCoordinator() -> ToastOverlay {
        ToastOverlay()
    }

    func makeUIView(context: Context) -> ToastSceneProbe {
        ToastSceneProbe(overlay: context.coordinator)
    }

    func updateUIView(_ probe: ToastSceneProbe, context: Context) {
        context.coordinator.update(center: center, appearance: ToastOverlayAppearance(context.environment))
        context.coordinator.tintColor = probe.tintColor
    }

    static func dismantleUIView(_ probe: ToastSceneProbe, coordinator: ToastOverlay) {
        coordinator.remove()
    }
}

/// Reports the scene and tint the host lives in.
final class ToastSceneProbe: UIView {
    private let overlay: ToastOverlay

    init(overlay: ToastOverlay) {
        self.overlay = overlay
        super.init(frame: .zero)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        overlay.attach(to: window?.windowScene)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        overlay.tintColor = tintColor
    }
}

/// Owns one host's overlay window.
final class ToastOverlay {
    private var window: ToastOverlayWindow?
    private var center: ToastCenter?
    private var appearance: ToastOverlayAppearance?

    var tintColor: UIColor? {
        didSet { window?.tintColor = tintColor }
    }

    func attach(to scene: UIWindowScene?) {
        guard scene !== window?.windowScene else { return }
        remove()
        guard let scene else { return }
        let window = ToastOverlayWindow(windowScene: scene)
        // Above the app's own window, where sheets and covers are presented, and below the
        // keyboard and system windows.
        window.windowLevel = .normal + 1
        window.backgroundColor = .clear
        window.tintColor = tintColor
        window.toastCenter = center
        let controller = UIHostingController(rootView: rootView())
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.isHidden = false
        self.window = window
    }

    func update(center: ToastCenter, appearance: ToastOverlayAppearance) {
        self.center = center
        self.appearance = appearance
        window?.toastCenter = center
        (window?.rootViewController as? UIHostingController<AnyView>)?.rootView = rootView()
    }

    func remove() {
        window?.isHidden = true
        window = nil
    }

    private func rootView() -> AnyView {
        guard let center, let appearance else { return AnyView(EmptyView()) }
        return AnyView(
            ToastOverlayRoot(center: center, appearance: appearance) { [weak self] frames in
                self?.window?.toastFrames = frames
            }
        )
    }
}

/// A window that takes touches only on its toasts and never becomes key, so focus, the
/// keyboard and every other touch stay with the app.
final class ToastOverlayWindow: UIWindow {
    weak var toastCenter: ToastCenter?
    var toastFrames: [CGRect] = []

    override var canBecomeKey: Bool { false }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let toastCenter, !toastCenter.visible.isEmpty else { return false }
        return toastFrames.contains { $0.contains(point) }
    }
}
#endif
