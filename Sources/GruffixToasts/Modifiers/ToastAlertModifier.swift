import SwiftUI

/// Presents the center's alert queue, one alert at a time: the toast's text as the title, its
/// detail as the message, and its action beside Cancel. Only tvOS queues alerts.
struct ToastAlertModifier: ViewModifier {
    let center: ToastCenter
    @State private var isPresented = false

    private var current: Toast? { center.alerts.first }

    func body(content: Content) -> some View {
        content
            .alert(current?.text ?? "", isPresented: $isPresented, presenting: current) { toast in
                if let action = toast.action {
                    Button(action.label) { action.perform() }
                }
                Button("Cancel", role: .cancel) {}
            } message: { toast in
                if let detail = toast.detail {
                    Text(detail)
                }
            }
            // Driven by the head's identity, so the next alert presents fresh after one closes.
            .onChange(of: current?.id, initial: true) { _, id in
                isPresented = id != nil
            }
            // Every button closes the alert, so closing is the one place the alert leaves the queue.
            .onChange(of: isPresented) { _, isShowing in
                if !isShowing, let current {
                    center.dismiss(current.id)
                }
            }
    }
}
