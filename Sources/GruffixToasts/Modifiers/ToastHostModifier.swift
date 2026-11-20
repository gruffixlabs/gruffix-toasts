import SwiftUI

/// Installs a `ToastCenter` at the root of a view hierarchy: puts it in the environment and
/// overlays the toast layer above the content.
struct ToastHostModifier: ViewModifier {
    let center: ToastCenter

    func body(content: Content) -> some View {
        content
            .overlay(alignment: center.tuning.placement.alignment) {
                ToastLayer(center: center)
            }
            #if os(tvOS)
            .modifier(ToastAlertModifier(center: center))
            #endif
            .environment(\.hostedToastCenter, center)
    }
}

extension View {
    /// Hosts app-wide toasts. Apply once, at the root; descendants show toasts through
    /// `@Environment(\.toastCenter)`.
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
