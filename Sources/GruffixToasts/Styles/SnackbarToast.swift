import SwiftUI

/// Dark, Material-style snackbar with an inline text action. Always dark so it reads the same
/// over light and dark content.
struct SnackbarToast: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.severity.symbol)
                .foregroundStyle(toast.severity.tint)

            VStack(alignment: .leading, spacing: 2) {
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
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(white: 0.16), in: .rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
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
