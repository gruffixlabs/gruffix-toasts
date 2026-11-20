#if DEBUG
import SwiftUI
import GruffixToasts

// MARK: - Variations

#Preview("Glass Capsule") {
    ToastPlayground(style: .glassCapsule)
}

#Preview("Banner") {
    ToastPlayground(style: .banner)
}

#Preview("Snackbar") {
    ToastPlayground(style: .snackbar)
}

#Preview("Deck") {
    ToastPlayground(style: .deck)
}

#Preview("Workbench", traits: .landscapeLeft) {
    ToastPlayground(style: .glassCapsule, showsTuningPanel: true)
}

// MARK: - States

/// Hosts a center pre-filled with toasts, so a state is visible without tapping.
private struct ToastStatePreview: View {
    @State private var center: ToastCenter
    private let toasts: [Toast]

    init(style: ToastStyle, toasts: [Toast], configure: (ToastTuning) -> Void = { _ in }) {
        let tuning = ToastTuning(style: style)
        configure(tuning)
        _center = State(initialValue: ToastCenter(tuning: tuning))
        self.toasts = toasts
    }

    var body: some View {
        NavigationStack {
            List(1...12, id: \.self) { item in
                Text("Item \(item)")
            }
            .navigationTitle(center.tuning.style.displayName)
        }
        .toastHost(center)
        .task { center.show(toasts) }
    }
}

#Preview("Burst / Stacked") {
    ToastStatePreview(style: .banner, toasts: ToastSamples.burst)
}

#Preview("Deck stacked") {
    ToastStatePreview(style: .deck, toasts: ToastSamples.burst)
}

#Preview("Long text — Capsule") {
    ToastStatePreview(style: .glassCapsule, toasts: [ToastSamples.longText])
}

#Preview("Long text — Banner") {
    ToastStatePreview(style: .banner, toasts: [ToastSamples.longText])
}

#Preview("Sticky error") {
    ToastStatePreview(style: .glassCapsule, toasts: [ToastSamples.saveFailed {}])
}

#Preview("Queue mode") {
    ToastStatePreview(style: .snackbar, toasts: ToastSamples.burst) { tuning in
        tuning.infoSeconds = 1.5
        tuning.successSeconds = 1.5
        tuning.warningSeconds = 1.5
    }
}

#Preview("Dark — Glass Capsule") {
    ToastStatePreview(style: .glassCapsule, toasts: ToastSamples.allSeverities)
        .preferredColorScheme(.dark)
}
#endif
