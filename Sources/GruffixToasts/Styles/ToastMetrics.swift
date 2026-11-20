import SwiftUI

/// Spacing and sizes for toast layouts. tvOS is read from across the room and its text styles are
/// about twice as large, so its spacing scales to match; other platforms use the values as written.
enum ToastMetrics {
    #if os(tvOS)
    private static let scale: CGFloat = 2
    #else
    private static let scale: CGFloat = 1
    #endif

    static func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }
}
