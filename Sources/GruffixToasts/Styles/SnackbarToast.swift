import SwiftUI

/// Dark, Material-style snackbar with an inline text action. Always dark so it reads the same
/// over light and dark content.
struct SnackbarToast: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: ToastMetrics.scaled(12)) {
            Image(systemName: toast.severity.symbol)
                .foregroundStyle(toast.severity.tint)

            VStack(alignment: .leading, spacing: ToastMetrics.scaled(2)) {
                Text(toast.text)
                    .font(.subheadline.weight(.medium))
                if let detail = toast.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let action = toast.action {
                Button(action.label.uppercased()) {
                    action.perform()
                    dismiss()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(toast.severity.tint)
            }

            if showsClose {
                ToastCloseButton(action: dismiss)
            }
        }
        .padding(.vertical, ToastMetrics.scaled(12))
        .padding(.horizontal, ToastMetrics.scaled(16))
        .background(Color(white: 0.16), in: .rect(cornerRadius: ToastMetrics.scaled(12)))
        .shadow(color: .black.opacity(0.25), radius: ToastMetrics.scaled(8), y: ToastMetrics.scaled(3))
        .environment(\.colorScheme, .dark)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ForEach(ToastSamples.allSeverities) { toast in
            SnackbarToast(toast: toast, showsClose: toast.severity == .error) {}
        }
    }
    .padding()
}
#endif
