import SwiftUI

/// Full-width card with a tinted leading stripe; reads as a system-style alert banner.
struct BannerToast: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: ToastMetrics.scaled(12)) {
            Image(systemName: toast.severity.symbol)
                .font(.title2)
                .foregroundStyle(toast.severity.tint)

            VStack(alignment: .leading, spacing: ToastMetrics.scaled(2)) {
                Text(toast.text)
                    .font(.headline)
                if let detail = toast.detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let action = toast.action {
                    Button(action.label) {
                        action.perform()
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.bordered)
                    .tint(toast.severity.tint)
                    .padding(.top, ToastMetrics.scaled(6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsClose {
                ToastCloseButton(action: dismiss)
            }
        }
        .padding(ToastMetrics.scaled(14))
        .padding(.leading, ToastMetrics.scaled(4))
        .background {
            // Stripe lives inside the card's shape so the rounded corners trim it.
            RoundedRectangle(cornerRadius: ToastMetrics.scaled(18))
                .fill(.background)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(toast.severity.tint)
                        .frame(width: ToastMetrics.scaled(5))
                }
                .mask(RoundedRectangle(cornerRadius: ToastMetrics.scaled(18)))
        }
        .shadow(color: .black.opacity(0.15), radius: ToastMetrics.scaled(12), y: ToastMetrics.scaled(4))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ForEach(ToastSamples.allSeverities) { toast in
            BannerToast(toast: toast, showsClose: toast.severity == .error) {}
        }
    }
    .padding()
    .background(.gray.opacity(0.15))
}
#endif
