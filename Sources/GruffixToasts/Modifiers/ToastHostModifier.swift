import SwiftUI

/// Installs a `ToastCenter` at the root of a view hierarchy: puts it in the environment and
/// shows its toasts in a window above the host's own, so presentations don't cover them.
/// watchOS has no windows to add, so there the toasts overlay the host's content.
struct ToastHostModifier: ViewModifier {
    let center: ToastCenter

    func body(content: Content) -> some View {
        content
            #if os(watchOS)
            .overlay(alignment: center.tuning.placement.alignment) {
                ToastLayer(center: center)
            }
            #else
            .background {
                ToastOverlayInstaller(center: center)
            }
            #endif
            #if os(tvOS)
            .modifier(ToastAlertModifier(center: center))
            #endif
            .environment(\.hostedToastCenter, center)
    }
}

extension View {
    /// Hosts app-wide toasts. Apply once, at the root; descendants show toasts through
    /// `@Environment(\.toastCenter)`.
    ///
    /// Toasts appear above sheets, full-screen covers and popovers. Apply it in each window or
    /// scene, usually with a center per window; a shared center shows every toast in every window.
    /// On watchOS toasts draw over the host's content, so a sheet covers them.
    public func toastHost(_ center: ToastCenter) -> some View {
        modifier(ToastHostModifier(center: center))
    }
}

extension EnvironmentValues {
    /// The toast center installed by the nearest `.toastHost(_:)`.
    ///
    /// Read it with `@Environment(\.toastCenter) private var toasts`. Reading it in a view with no
    /// `.toastHost(_:)` above it, including in a preview, stops the app with a fatal error.
    public var toastCenter: ToastCenter {
        guard let hostedToastCenter else {
            fatalError("No ToastCenter in the environment. Apply .toastHost(_:) to an ancestor view.")
        }
        return hostedToastCenter
    }

    /// Optional storage behind `toastCenter`, so a missing host can fail with a clear message.
    @Entry var hostedToastCenter: ToastCenter?
}
