import SwiftUI
import Testing
@testable import GruffixToasts

/// A consumer-defined style goes through the same tuning, center and layer as the built-ins.
struct CustomToastStyleTests {
    let sleeper = ManualSleeper()
    let recorder = RenderRecorder()

    // MARK: Defaults

    @Test func tuningUsesTheStyleDefaults() {
        let tuning = ToastTuning(style: RecordingToastStyle(recorder: recorder))

        #expect(tuning.placement == .bottom)
        #expect(tuning.presentation == .queue)
    }

    @Test func styleWithoutOverridesGetsTheProtocolDefaults() {
        let style = PlainToastStyle()

        #expect(style.defaultPlacement == .top)
        #expect(style.defaultPresentation == .stack)
        #expect(style.layout == .stack)
    }

    @Test func tuningAppliesThePlatformDefaults() {
        let tuning = ToastTuning(style: PlainToastStyle())

        #if os(watchOS)
        #expect(tuning.placement == .bottom)
        #expect(tuning.presentation == .queue)
        #else
        #expect(tuning.placement == .top)
        #expect(tuning.presentation == .stack)
        #endif
    }

    // MARK: Center

    @Test func queueDefaultShowsOneToastAtATime() {
        let tuning = ToastTuning(style: RecordingToastStyle(recorder: recorder))
        tuning.maxVisible = 3
        let center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
        let first = Toast(.info, "First")
        let second = Toast(.info, "Second")

        center.show(first)
        center.show(second)

        #expect(center.visible.map(\.id) == [first.id])
        #expect(center.pending.map(\.id) == [second.id])
    }

    // MARK: Layer

    @Test func layerRendersTheCustomView() {
        let tuning = ToastTuning(style: RecordingToastStyle(recorder: recorder))
        let center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
        let toast = Toast(.info, "Saved")
        center.show(toast)

        render(center)

        // SwiftUI may evaluate a body more than once, so compare what was drawn, not how often.
        #expect(Set(recorder.toastIds) == [toast.id])
        #expect(Set(recorder.closeButtonFlags) == [false])
    }

    #if !os(tvOS)
    // tvOS ignores `isErrorSticky`, so no toast there shows a close button.
    @Test func layerAsksForACloseButtonOnStickyToasts() {
        let tuning = ToastTuning(style: RecordingToastStyle(recorder: recorder))
        tuning.isErrorSticky = true
        let center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
        center.show(Toast(.error, "Failed"))

        render(center)

        #expect(Set(recorder.closeButtonFlags) == [true])
    }
    #endif

    @Test func dismissFromTheConfigurationRemovesTheToast() {
        let tuning = ToastTuning(style: RecordingToastStyle(recorder: recorder))
        let center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
        center.show(Toast(.info, "Saved"))
        render(center)

        recorder.dismissActions.first?()

        #expect(center.visible.isEmpty)
    }

    /// Evaluates the layer's body offscreen, which asks the style for each visible toast's view.
    private func render(_ center: ToastCenter) {
        let layer = ToastLayer(center: center)
            .environment(\.hostedToastCenter, center)
            .frame(width: 400, height: 400)
        _ = ImageRenderer(content: layer).cgImage
    }
}

/// Collects what `RecordingToastStyle` was asked to draw.
final class RenderRecorder {
    private(set) var toastIds: [Toast.ID] = []
    private(set) var closeButtonFlags: [Bool] = []
    private(set) var dismissActions: [() -> Void] = []

    func record(_ configuration: ToastStyleConfiguration) {
        toastIds.append(configuration.toast.id)
        closeButtonFlags.append(configuration.showsCloseButton)
        dismissActions.append(configuration.dismiss)
    }
}

/// A custom style with its own defaults that records each toast it draws.
private struct RecordingToastStyle: ToastStyle {
    let recorder: RenderRecorder

    var defaultPlacement: ToastPlacement { .bottom }
    var defaultPresentation: ToastPresentation { .queue }

    func makeBody(configuration: Configuration) -> some View {
        recorder.record(configuration)
        return Text(configuration.toast.text)
    }
}

/// A custom style that relies on every protocol default.
private struct PlainToastStyle: ToastStyle {
    func makeBody(configuration: Configuration) -> some View {
        Text(configuration.toast.text)
    }
}
