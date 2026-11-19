import SwiftUI

/// Full-width card with a tinted leading stripe; reads as a system-style alert banner.
struct BannerToast: View {
    let toast: Toast
    let showsClose: Bool
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: toast.severity.symbol)
                .font(.title2)
                .foregroundStyle(toast.severity.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.headline)
                if let message = toast.message {
                    Text(message)
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
                    .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsClose {
                ToastCloseButton(action: dismiss)
            }
        }
        .padding(14)
        .padding(.leading, 4)
        .background {
            // Stripe lives inside the card's shape so the rounded corners trim it.
            RoundedRectangle(cornerRadius: 18)
                .fill(.background)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(toast.severity.tint)
                        .frame(width: 5)
                }
                .mask(RoundedRectangle(cornerRadius: 18))
        }
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
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
