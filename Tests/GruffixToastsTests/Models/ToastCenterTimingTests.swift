import Testing
@testable import GruffixToasts

/// Auto-dismiss timing, pausing, bursts, and how `ToastTuning` changes `ToastCenter` behavior.
struct ToastCenterTimingTests {
    let sleeper = ManualSleeper()
    let tuning = ToastTuning()
    let center: ToastCenter

    init() {
        tuning.presentation = .stack
        center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
    }

    // MARK: Duration

    @Test(arguments: [
        (ToastSeverity.info, 3.0),
        (.success, 3.0),
        (.warning, 5.0),
        (.error, 6.0),
    ])
    func autoDismissesAfterDefaultSeverityDuration(severity: ToastSeverity, seconds: Double) async {
        tuning.isErrorSticky = false

        let toast = Toast(severity, "Toast")
        center.show(toast)

        await expectAutoDismissal(of: toast, after: .seconds(seconds))
    }

    @Test func actionAddsBonusTime() async {
        let toast = Toast(.info, "Toast", action: ToastAction(label: "Undo") {})

        center.show(toast)

        await expectAutoDismissal(of: toast, after: .seconds(tuning.infoSeconds + tuning.actionBonusSeconds))
    }

    @Test func stickyErrorStaysUntilDismissed() async {
        tuning.isErrorSticky = true
        let toast = Toast(.error, "Error")

        center.show(toast)
        await sleeper.advance(by: .seconds(3600))

        #expect(center.visible.map(\.id) == [toast.id])
        #expect(sleeper.pendingCount == 0)
    }

    @Test func autoDismissInQueuePresentsNextAfterGap() async {
        tuning.presentation = .queue
        let first = Toast(.info, "First")
        let second = Toast(.info, "Second")
        center.show(first)
        center.show(second)

        await sleeper.advance(by: .seconds(tuning.infoSeconds))
        #expect(center.visible.isEmpty)

        await sleeper.advance(by: .seconds(tuning.queueGapSeconds))
        #expect(center.visible.map(\.id) == [second.id])
    }

    // MARK: Pause and resume

    @Test func pauseStopsAutoDismiss() async {
        let toast = Toast(.info, "Toast")
        center.show(toast)
        await sleeper.advance(by: .seconds(1))

        center.pauseTimer(for: toast.id)
        await sleeper.advance(by: .seconds(60))

        #expect(center.visible.map(\.id) == [toast.id])
    }

    @Test func resumeRestartsFullDuration() async {
        let toast = Toast(.info, "Toast")
        center.show(toast)
        await sleeper.advance(by: .seconds(2))
        center.pauseTimer(for: toast.id)

        center.resumeTimer(for: toast.id)

        await expectAutoDismissal(of: toast, after: .seconds(tuning.infoSeconds))
    }

    @Test func resumeIgnoresToastThatIsNotVisible() async {
        tuning.presentation = .queue
        center.show(Toast(.info, "Visible"))
        let waiting = Toast(.info, "Waiting")
        center.show(waiting)
        await sleeper.settle()

        center.resumeTimer(for: waiting.id)
        await sleeper.settle()

        #expect(sleeper.pendingCount == 1)
    }

    // MARK: Bursts

    @Test func burstShowsToastsSeparatedByStagger() async {
        let toasts = (1...3).map { Toast(.info, "Toast \($0)") }
        let stagger = Duration.seconds(tuning.staggerSeconds)

        center.show(toasts)
        await sleeper.settle()
        #expect(center.visible.map(\.id) == [toasts[0].id])

        await sleeper.advance(by: stagger - .milliseconds(1))
        #expect(center.visible.count == 1)

        await sleeper.advance(by: .milliseconds(1))
        #expect(center.visible.map(\.id) == toasts.prefix(2).map(\.id))

        await sleeper.advance(by: stagger)
        #expect(center.visible.map(\.id) == toasts.map(\.id))
    }

    // MARK: Tuning effects

    @Test func customSeverityDurationsApply() async {
        tuning.infoSeconds = 1.5
        let toast = Toast(.info, "Toast")
        center.show(toast)

        await expectAutoDismissal(of: toast, after: .seconds(1.5))
    }

    @Test func customActionBonusApplies() async {
        tuning.successSeconds = 1
        tuning.actionBonusSeconds = 4
        let toast = Toast(.success, "Toast", action: ToastAction(label: "Open") {})

        center.show(toast)

        await expectAutoDismissal(of: toast, after: .seconds(5))
    }

    @Test func customQueueGapApplies() async {
        tuning.presentation = .queue
        tuning.queueGapSeconds = 1
        let first = Toast(.info, "First")
        let second = Toast(.info, "Second")
        center.show(first)
        center.show(second)

        center.dismiss(first.id)
        await sleeper.advance(by: .milliseconds(999))
        #expect(center.visible.isEmpty)

        await sleeper.advance(by: .milliseconds(1))
        #expect(center.visible.map(\.id) == [second.id])
    }

    @Test func customStaggerApplies() async {
        tuning.staggerSeconds = 2
        let toasts = (1...2).map { Toast(.info, "Toast \($0)") }

        center.show(toasts)
        await sleeper.advance(by: .milliseconds(1999))
        #expect(center.visible.count == 1)

        await sleeper.advance(by: .milliseconds(1))
        #expect(center.visible.map(\.id) == toasts.map(\.id))
    }

    @Test func presentationChangeAppliesToNextShow() {
        tuning.presentation = .queue
        let first = Toast(.info, "First")
        center.show(first)

        tuning.presentation = .stack
        let second = Toast(.info, "Second")
        center.show(second)

        #expect(center.visible.map(\.id) == [first.id, second.id])
        #expect(center.pending.isEmpty)
    }

    @Test func loweringMaxVisibleTrimsOnNextShow() {
        tuning.maxVisible = 3
        let toasts = (1...3).map { Toast(.info, "Toast \($0)") }
        toasts.forEach(center.show)

        tuning.maxVisible = 1
        let latest = Toast(.info, "Latest")
        center.show(latest)

        #expect(center.visible.map(\.id) == [latest.id])
    }

    // MARK: Helpers

    /// Advances to 1 ms before `duration` from now, checks `toast` is visible, then advances
    /// the last millisecond and checks it's gone.
    private func expectAutoDismissal(
        of toast: Toast,
        after duration: Duration,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        await sleeper.advance(by: duration - .milliseconds(1))
        #expect(center.visible.map(\.id) == [toast.id], sourceLocation: sourceLocation)

        await sleeper.advance(by: .milliseconds(1))
        #expect(center.visible.isEmpty, sourceLocation: sourceLocation)
    }
}
