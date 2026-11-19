#if DEBUG
import SwiftUI

/// A fake app screen for trying toasts. Trigger buttons reach the center through the
/// environment, the same way real feature views would.
struct ToastPlayground: View {
    @State private var center: ToastCenter
    @State private var showTuningSheet = false
    private let showsTuningPanel: Bool

    init(style: ToastStyle = .glassCapsule, showsTuningPanel: Bool = false) {
        _center = State(initialValue: ToastCenter(tuning: ToastTuning(style: style)))
        self.showsTuningPanel = showsTuningPanel
    }

    var body: some View {
        HStack(spacing: 0) {
            screen
                .toastHost(center)
            if showsTuningPanel {
                Divider()
                ToastTuningPanel(tuning: center.tuning)
                    .frame(width: 360)
            }
        }
    }

    private var screen: some View {
        NavigationStack {
            List {
                ToastTriggerSection()
                Section("Documents") {
                    ForEach(Self.documents, id: \.self) { document in
                        Label(document, systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle(center.tuning.style.name)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss All", systemImage: "xmark.circle") { center.dismissAll() }
                }
                if !showsTuningPanel {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Tune", systemImage: "slider.horizontal.3") { showTuningSheet = true }
                    }
                }
            }
            .sheet(isPresented: $showTuningSheet) {
                ToastTuningPanel(tuning: center.tuning)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private static let documents = [
        "Quarterly Report",
        "Groceries",
        "Trip Itinerary — Lisbon",
        "Meeting Notes with the Design Team",
        "Budget",
    ]
}

/// Buttons that fire sample toasts via `@Environment(\.toastCenter)`.
private struct ToastTriggerSection: View {
    @Environment(\.toastCenter) private var toasts

    var body: some View {
        Section("Fire toasts") {
            Button("Info: download started") { toasts.show(ToastSamples.downloadStarted) }
            Button("Success: document saved") { toasts.show(ToastSamples.documentSaved) }
            Button("Warning: low storage") { toasts.show(ToastSamples.lowStorage) }
            Button("Error: save failed (Retry)") {
                toasts.show(ToastSamples.saveFailed { toasts.show(ToastSamples.documentSaved) })
            }
            Button("Success: item deleted (Undo)") {
                toasts.show(ToastSamples.itemDeleted { toasts.show(ToastSamples.itemRestored) })
            }
            Button("Long text") { toasts.show(ToastSamples.longText) }
            Button("Burst of 4") { toasts.show(ToastSamples.burst) }
        }
    }
}

#Preview {
    ToastPlayground()
}
#endif
