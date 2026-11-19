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
            .environment(center)
    }
}

extension View {
    /// Hosts app-wide toasts. Apply once, at the root; descendants show toasts through
    /// `@Environment(ToastCenter.self)`.
    public func toastHost(_ center: ToastCenter) -> some View {
        modifier(ToastHostModifier(center: center))
    }
}
