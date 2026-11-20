import SwiftUI

/// Notification-style card. `ToastLayer` stacks these behind each other and fans them out on tap.
struct DeckToastCard: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: ToastMetrics.scaled(12)) {
            Image(systemName: toast.severity.symbol)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: ToastMetrics.scaled(38), height: ToastMetrics.scaled(38))
                .background(toast.severity.tint.gradient, in: .rect(cornerRadius: ToastMetrics.scaled(10)))

            VStack(alignment: .leading, spacing: ToastMetrics.scaled(2)) {
                HStack(alignment: .firstTextBaseline) {
                    Text(toast.text)
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 8)
                    Text("now")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let detail = toast.detail {
                    Text(detail)
                        .font(.subheadline)
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
                .toastGlassButtonStyle(isProminent: false)
            }

            if showsClose {
                ToastCloseButton(action: dismiss)
            }
        }
        .padding(ToastMetrics.scaled(12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .toastGlass(tint: nil, isInteractive: false, in: .rect(cornerRadius: ToastMetrics.scaled(22)))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ForEach(ToastSamples.allSeverities) { toast in
            DeckToastCard(toast: toast, showsClose: toast.severity == .error) {}
        }
    }
    .padding()
}
#endif
