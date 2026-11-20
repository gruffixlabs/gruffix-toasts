import SwiftUI

/// The SwiftUI content of a toast overlay window: the toast layer at its edge, with the host's
/// appearance carried over, since a separate window doesn't inherit the host's environment.
struct ToastOverlayRoot: View {
    let center: ToastCenter
    let appearance: ToastOverlayAppearance
    /// Called with the toasts' frame in the window's coordinates, so the window can pass every
    /// other touch or click through to the app below.
    let onToastFrameChange: (CGRect) -> Void

    var body: some View {
        Color.clear
            .overlay(alignment: center.tuning.placement.alignment) {
                ToastLayer(center: center)
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                        onToastFrameChange(frame)
                    }
            }
            .environment(\.hostedToastCenter, center)
            .environment(\.colorScheme, appearance.colorScheme)
            .environment(\.dynamicTypeSize, appearance.dynamicTypeSize)
            .environment(\.layoutDirection, appearance.layoutDirection)
            .environment(\.locale, appearance.locale)
    }
}

/// The parts of the host's environment that change how toasts look.
struct ToastOverlayAppearance {
    var colorScheme: ColorScheme
    var dynamicTypeSize: DynamicTypeSize
    var layoutDirection: LayoutDirection
    var locale: Locale

    init(_ environment: EnvironmentValues) {
        colorScheme = environment.colorScheme
        dynamicTypeSize = environment.dynamicTypeSize
        layoutDirection = environment.layoutDirection
        locale = environment.locale
    }
}
