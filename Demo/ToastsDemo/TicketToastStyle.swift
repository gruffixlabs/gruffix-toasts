import SwiftUI
import GruffixToasts

/// A custom style built only from the library's public building blocks: a tinted glass ticket
/// with a severity stripe, queued at the top, sliding in from the trailing edge.
struct TicketToastStyle: ToastStyle {
    var defaultPresentation: ToastPresentation { .queue }

    func makeBody(configuration: Configuration) -> some View {
        TicketToast(configuration: configuration)
    }

    func transition(for placement: ToastPlacement) -> AnyTransition {
        .move(edge: .trailing).combined(with: .opacity)
    }
}

extension ToastStyle where Self == TicketToastStyle {
    static var ticket: Self { TicketToastStyle() }
}

private struct TicketToast: View {
    let configuration: ToastStyleConfiguration

    private var toast: Toast { configuration.toast }

    var body: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(toast.severity.tint)
                .frame(width: 4)
            Image(systemName: toast.severity.systemImage)
                .font(.title2)
                .foregroundStyle(toast.severity.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.text)
                    .font(.subheadline.weight(.semibold))
                if let detail = toast.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let action = toast.action {
                Button(action.label) {
                    action.perform()
                    configuration.dismiss()
                }
                .font(.subheadline.weight(.semibold))
                .toastGlassButtonStyle(isProminent: true)
                .tint(toast.severity.tint)
            }

            if configuration.showsCloseButton {
                ToastCloseButton(action: configuration.dismiss)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(14)
        .toastGlass(tint: toast.severity.tint.opacity(0.08), isInteractive: false, in: .rect(cornerRadius: 12))
    }
}

#if DEBUG
#Preview {
    // Scrolls so each toast keeps its natural height.
    ScrollView {
        VStack(spacing: 12) {
            ForEach(ToastSamples.allSeverities) { toast in
                TicketToastStyle().makeBody(configuration: .init(toast: toast, showsCloseButton: toast.severity == .error))
            }
        }
        .padding()
    }
}
#endif
