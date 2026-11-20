import SwiftUI

/// The close button the built-in styles show on toasts that won't time out, so dismissal doesn't
/// depend on discovering the swipe. Show it in a custom ``ToastStyle`` when
/// ``ToastStyleConfiguration/showsCloseButton`` is `true`.
public struct ToastCloseButton: View {
    let action: () -> Void

    /// Creates a close button.
    /// - Parameter action: The work to do when the button is tapped, usually
    ///   ``ToastStyleConfiguration/dismiss``.
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    /// The button.
    public var body: some View {
        Button("Dismiss", systemImage: "xmark", action: action)
            .labelStyle(.iconOnly)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .frame(width: ToastMetrics.scaled(28), height: ToastMetrics.scaled(28))
            .contentShape(.rect)
    }
}

#if DEBUG
#Preview {
    ToastCloseButton {}
}
#endif
