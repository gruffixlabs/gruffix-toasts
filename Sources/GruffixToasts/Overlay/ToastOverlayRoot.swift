import SwiftUI

/// The SwiftUI content of a toast overlay window: the toast layer at its edge, with the host's
/// appearance carried over, since a separate window doesn't inherit the host's environment.
struct ToastOverlayRoot: View {
    let center: ToastCenter
    let appearance: ToastOverlayAppearance
    /// Called with each toast's frame in the window's coordinates, so the window can pass every
    /// other touch or click through to the app below.
    let onToastFramesChange: ([CGRect]) -> Void

    var body: some View {
        Color.clear
            .overlay(alignment: center.tuning.placement.alignment) {
                ToastLayer(center: center)
            }
            .onPreferenceChange(ToastFramesKey.self) { frames in
                onToastFramesChange(frames)
            }
            .environment(\.hostedToastCenter, center)
            .environment(\.colorScheme, appearance.colorScheme)
            .environment(\.dynamicTypeSize, appearance.dynamicTypeSize)
            .environment(\.layoutDirection, appearance.layoutDirection)
            .environment(\.locale, appearance.locale)
    }
}

/// The frames of the toasts on screen, in global coordinates. Each toast reports its own, so gaps
/// between and beside toasts stay click-through.
struct ToastFramesKey: PreferenceKey {
    static let defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
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
