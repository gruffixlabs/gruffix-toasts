import SwiftUI
import GruffixToasts

/// A fake app screen for trying toasts. Trigger buttons reach the center through the
/// environment, the same way real feature views would.
struct ToastPlayground: View {
    @State private var center: ToastCenter
    @State private var showTuningSheet = false
    @State private var showDocumentSheet = false
    private let showsTuningPanel: Bool

    init(style: any ToastStyle = .glassCapsule, showsTuningPanel: Bool = false) {
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
                Section("Presentations") {
                    Button("Open a sheet") { showDocumentSheet = true }
                }
                Section("Documents") {
                    ForEach(Self.documents, id: \.self) { document in
                        Label(document, systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle(DemoToastStyle(matching: center.tuning.style)?.displayName ?? "Toasts")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss All", systemImage: "xmark.circle") { center.dismissAll() }
                }
                if !showsTuningPanel {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Tune", systemImage: "slider.horizontal.3") { showTuningSheet = true }
                    }
                }
            }
            .sheet(isPresented: $showDocumentSheet) {
                // Toasts fired from here should appear above the sheet.
                NavigationStack {
                    List { ToastTriggerSection() }
                        .navigationTitle("Sheet")
                }
                .presentationDetents([.medium, .large])
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

#if DEBUG
#Preview {
    ToastPlayground()
}
#endif
