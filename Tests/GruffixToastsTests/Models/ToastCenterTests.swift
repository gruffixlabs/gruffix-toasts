import Testing
@testable import GruffixToasts

/// Presentation and dismissal in stack and queue modes.
struct ToastCenterTests {
    let sleeper = ManualSleeper()
    let tuning = ToastTuning()
    let center: ToastCenter

    init() {
        // Explicit, so watchOS's one-visible default doesn't change what these tests measure.
        tuning.maxVisible = 3
        center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
    }

    // MARK: Stack

    @Test func stackShowsToastsTogetherInOrder() {
        tuning.presentation = .stack
        let first = Toast(.info, "First")
        let second = Toast(.success, "Second")

        center.show(first)
        center.show(second)

        #expect(center.visible.map(\.id) == [first.id, second.id])
        #expect(center.pending.isEmpty)
        #expect(center.lastShown?.id == second.id)
    }

    @Test func stackDropsOldestBeyondMaxVisible() {
        tuning.presentation = .stack
        tuning.maxVisible = 2
        let toasts = (1...3).map { Toast(.info, "Toast \($0)") }

        toasts.forEach(center.show)

        #expect(center.visible.map(\.id) == toasts.suffix(2).map(\.id))
        #expect(center.lastShown?.id == toasts[2].id)
    }

    @Test func stackCancelsTimerOfDroppedToast() async {
        tuning.presentation = .stack
        tuning.maxVisible = 1

        center.show(Toast(.info, "Dropped"))
        center.show(Toast(.info, "Kept"))
        await sleeper.settle()

        #expect(sleeper.pendingCount == 1)
    }

    // MARK: Queue

    @Test func queueShowsOneToastAndHoldsTheRest() {
        tuning.presentation = .queue
        let toasts = (1...3).map { Toast(.info, "Toast \($0)") }

        toasts.forEach(center.show)

        #expect(center.visible.map(\.id) == [toasts[0].id])
        #expect(center.pending.map(\.id) == [toasts[1].id, toasts[2].id])
        #expect(center.lastShown?.id == toasts[0].id)
    }

    @Test func queuePresentsNextAfterGapWhenDismissed() async {
        tuning.presentation = .queue
        let first = Toast(.info, "First")
        let second = Toast(.info, "Second")
        center.show(first)
        center.show(second)

        center.dismiss(first.id)
        await sleeper.advance(by: .seconds(tuning.queueGapSeconds) - .milliseconds(1))

        #expect(center.visible.isEmpty)
        #expect(center.pending.map(\.id) == [second.id])

        await sleeper.advance(by: .milliseconds(1))

        #expect(center.visible.map(\.id) == [second.id])
        #expect(center.pending.isEmpty)
        #expect(center.lastShown?.id == second.id)
    }

    @Test func queueWaitsWhileGapIsInProgress() async {
        tuning.presentation = .queue
        let first = Toast(.info, "First")
        let second = Toast(.info, "Second")
        let third = Toast(.info, "Third")
        center.show(first)
        center.show(second)
        center.dismiss(first.id)

        center.show(third)
        await sleeper.advance(by: .seconds(tuning.queueGapSeconds))

        #expect(center.visible.map(\.id) == [second.id])
        #expect(center.pending.map(\.id) == [third.id])
    }

    @Test func queueDropsGapWhenEverythingIsDismissed() async {
        tuning.presentation = .queue
        let first = Toast(.info, "First")
        center.show(first)
        center.show(Toast(.info, "Second"))

        center.dismiss(first.id)
        center.dismissAll()
        await sleeper.advance(by: .seconds(60))

        #expect(center.visible.isEmpty)
        #expect(center.pending.isEmpty)
    }

    // MARK: Dismissal

    @Test(arguments: ToastPresentation.allCases)
    func dismissRemovesVisibleToast(presentation: ToastPresentation) {
        tuning.presentation = presentation
        let toast = Toast(.info, "Toast")
        center.show(toast)

        center.dismiss(toast.id)

        #expect(center.visible.isEmpty)
    }

    @Test func dismissRemovesPendingToast() {
        tuning.presentation = .queue
        let first = Toast(.info, "First")
        let second = Toast(.info, "Second")
        center.show(first)
        center.show(second)

        center.dismiss(second.id)

        #expect(center.visible.map(\.id) == [first.id])
        #expect(center.pending.isEmpty)
    }

    @Test func dismissIgnoresUnknownId() {
        let toast = Toast(.info, "Toast")
        center.show(toast)

        center.dismiss(Toast(.info, "Never shown").id)

        #expect(center.visible.map(\.id) == [toast.id])
    }

    @Test func dismissCancelsTimer() async {
        let toast = Toast(.info, "Toast")
        center.show(toast)
        await sleeper.settle()
        #expect(sleeper.pendingCount == 1)

        center.dismiss(toast.id)
        await sleeper.settle()

        #expect(sleeper.pendingCount == 0)
    }

    @Test(arguments: ToastPresentation.allCases)
    func dismissAllClearsEverythingAndCancelsTimers(presentation: ToastPresentation) async {
        tuning.presentation = presentation
        (1...3).forEach { center.show(Toast(.info, "Toast \($0)")) }
        await sleeper.settle()

        center.dismissAll()
        await sleeper.settle()

        #expect(center.visible.isEmpty)
        #expect(center.pending.isEmpty)
        #expect(sleeper.pendingCount == 0)
    }
}
