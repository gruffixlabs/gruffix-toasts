import SwiftUI

/// Compact Liquid Glass capsule, meant to sit just below the Dynamic Island.
struct GlassCapsuleToast: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.severity.symbol)
                .font(.title3)
                .foregroundStyle(toast.severity.tint)

            VStack(alignment: .leading, spacing: 1) {
                Text(toast.title)
                    .font(.subheadline.weight(.semibold))
                if let message = toast.message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(2)

            if let action = toast.action {
                Button(action.label) {
                    action.perform()
                    dismiss()
                }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.glassProminent)
                .tint(toast.severity.tint)
            }

            if showsClose {
                ToastCloseButton(action: dismiss)
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, 16)
        .padding(.trailing, showsClose || toast.action != nil ? 8 : 18)
        .glassEffect(.regular.tint(toast.severity.tint.opacity(0.12)).interactive(), in: .capsule)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ForEach(ToastSamples.allSeverities) { toast in
            GlassCapsuleToast(toast: toast, showsClose: toast.severity == .error) {}
        }
    }
    .padding()
}
#endif
