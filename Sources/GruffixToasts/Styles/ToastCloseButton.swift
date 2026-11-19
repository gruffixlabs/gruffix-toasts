import SwiftUI

/// Shown on toasts that won't time out, so dismissal doesn't depend on discovering the swipe.
struct ToastCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button("Dismiss", systemImage: "xmark", action: action)
            .labelStyle(.iconOnly)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .frame(width: 28, height: 28)
            .contentShape(.rect)
    }
}

#if DEBUG
#Preview {
    ToastCloseButton {}
}
#endif
