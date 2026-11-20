import SwiftUI

/// Compact Liquid Glass capsule, meant to sit just below the Dynamic Island. Before iOS 26 it's
/// a tinted material capsule instead.
///
/// A watch screen is too narrow for text and buttons side by side, so on watchOS the text gets the
/// full width and the buttons sit below it, in a rounded rectangle rather than a capsule.
struct GlassCapsuleToast: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    private var hasButtons: Bool { showsClose || toast.action != nil }

    var body: some View {
        #if os(watchOS)
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                icon
                message
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if hasButtons {
                HStack(spacing: 6) {
                    actionButton
                        .frame(maxWidth: .infinity)
                    closeButton
                }
            }
        }
        .padding(10)
        .toastGlass(tint: toast.severity.tint.opacity(0.12), isInteractive: true, in: .rect(cornerRadius: 22))
        #else
        HStack(spacing: ToastMetrics.scaled(10)) {
            icon
            message
                .lineLimit(2)
            actionButton
            closeButton
        }
        .padding(.vertical, ToastMetrics.scaled(10))
        .padding(.leading, ToastMetrics.scaled(16))
        .padding(.trailing, ToastMetrics.scaled(hasButtons ? 8 : 18))
        .toastGlass(tint: toast.severity.tint.opacity(0.12), isInteractive: true, in: .capsule)
        #endif
    }

    private var icon: some View {
        Image(systemName: toast.severity.symbol)
            .font(.title3)
            .foregroundStyle(toast.severity.tint)
    }

    private var message: some View {
        VStack(alignment: .leading, spacing: ToastMetrics.scaled(1)) {
            Text(toast.text)
                .font(.subheadline.weight(.semibold))
            if let detail = toast.detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if let action = toast.action {
            Button(action.label) {
                action.perform()
                dismiss()
            }
            .font(.subheadline.weight(.semibold))
            .toastGlassButtonStyle(isProminent: true)
            .tint(toast.severity.tint)
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        if showsClose {
            ToastCloseButton(action: dismiss)
        }
    }
}

#if DEBUG
#Preview {
    // Scrolls so each toast keeps its natural height on a watch.
    ScrollView {
        VStack(spacing: 12) {
            ForEach(ToastSamples.allSeverities) { toast in
                GlassCapsuleToast(toast: toast, showsClose: toast.severity == .error) {}
            }
        }
        .padding()
    }
}
#endif
