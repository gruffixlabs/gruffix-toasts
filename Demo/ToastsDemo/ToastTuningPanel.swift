import SwiftUI
import GruffixToasts

/// A form of live controls for `ToastTuning`, for trying styles, timing and motion in a debug
/// screen or sheet.
struct ToastTuningPanel: View {
    @Bindable var tuning: ToastTuning

    /// Creates a panel that edits `tuning` in place.
    /// - Parameter tuning: The tuning to edit, usually the `ToastCenter`'s.
    init(tuning: ToastTuning) {
        self.tuning = tuning
    }

    /// The panel's form.
    var body: some View {
        Form {
            Section("Look") {
                Picker("Style", selection: style) {
                    ForEach(DemoToastStyle.allCases, id: \.self) { Text($0.displayName) }
                }
                Picker("Placement", selection: $tuning.placement) {
                    ForEach(ToastPlacement.allCases, id: \.self) { Text($0.displayName) }
                }
                .pickerStyle(.segmented)
            }

            Section("Presentation") {
                Picker("Mode", selection: $tuning.presentation) {
                    ForEach(ToastPresentation.allCases, id: \.self) { Text($0.displayName) }
                }
                .pickerStyle(.segmented)
                Stepper("Max visible: \(tuning.maxVisible)", value: $tuning.maxVisible, in: 1...6)
                    .disabled(tuning.presentation == .queue)
                slider("Queue gap", value: $tuning.queueGapSeconds, in: 0...1)
                slider("Burst stagger", value: $tuning.staggerSeconds, in: 0...0.6)
            }

            Section("Durations") {
                slider("Info", value: $tuning.infoSeconds, in: 1...10)
                slider("Success", value: $tuning.successSeconds, in: 1...10)
                slider("Warning", value: $tuning.warningSeconds, in: 1...10)
                Toggle("Errors stay until dismissed", isOn: $tuning.isErrorSticky)
                if !tuning.isErrorSticky {
                    slider("Error", value: $tuning.errorSeconds, in: 1...15)
                }
                slider("Action bonus", value: $tuning.actionBonusSeconds, in: 0...5)
            }

            Section("Motion") {
                Picker("Spring", selection: $tuning.springPreset) {
                    ForEach(SpringPreset.allCases, id: \.self) { Text($0.displayName) }
                }
                .pickerStyle(.segmented)
                if tuning.springPreset == .custom {
                    slider("Response", value: $tuning.customResponse, in: 0.1...1.2)
                    slider("Damping", value: $tuning.customDamping, in: 0.3...1)
                }
                LabeledContent("Swipe threshold") {
                    Slider(value: $tuning.swipeThreshold, in: 20...150)
                    Text("\(Int(tuning.swipeThreshold)) pt")
                        .monospacedDigit()
                        .frame(width: 52, alignment: .trailing)
                }
            }
        }
    }

    /// `ToastStyle` is a protocol, not `Hashable`, so the picker selects from the demo's list.
    private var style: Binding<DemoToastStyle> {
        Binding {
            DemoToastStyle(matching: tuning.style) ?? .glassCapsule
        } set: { selection in
            tuning.style = selection.style
            // A fresh tuning carries the library's defaults for the style, so the panel can't
            // drift from them.
            let defaults = ToastTuning(style: selection.style)
            tuning.placement = defaults.placement
            tuning.presentation = defaults.presentation
        }
    }

    private func slider(_ title: String, value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        LabeledContent(title) {
            Slider(value: value, in: range)
            Text(value.wrappedValue, format: .number.precision(.fractionLength(2)))
                .monospacedDigit()
                .frame(width: 44, alignment: .trailing)
        }
    }
}

#if DEBUG
#Preview {
    ToastTuningPanel(tuning: ToastTuning())
}
#endif
