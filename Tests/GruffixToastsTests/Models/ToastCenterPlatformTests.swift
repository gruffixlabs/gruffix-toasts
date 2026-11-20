import Testing
@testable import GruffixToasts

/// Behavior that differs by platform: tvOS toasts are passive and actions become alerts;
/// watchOS defaults to one bottom toast at a time.
struct ToastCenterPlatformTests {
    let sleeper = ManualSleeper()
    let tuning = ToastTuning()
    let center: ToastCenter

    init() {
        center = ToastCenter(tuning: tuning, sleep: sleeper.sleep(for:))
    }

    #if os(tvOS)
    @Test func stickyErrorStillTimesOut() async {
        tuning.isErrorSticky = true
        let toast = Toast(.error, "Error")

        center.show(toast)
        await sleeper.advance(by: .seconds(tuning.errorSeconds))

        #expect(center.visible.isEmpty)
    }

    @Test func actionableToastsWaitAsAlertsInOrder() {
        let first = Toast(.error, "First", action: ToastAction(label: "Retry") {})
        let second = Toast(.success, "Second", action: ToastAction(label: "Undo") {})

        center.show(first)
        center.show(second)

        #expect(center.alerts.map(\.id) == [first.id, second.id])
        #expect(center.visible.isEmpty)
        #expect(sleeper.pendingCount == 0)
    }

    @Test func plainToastsShowWhileAlertsWait() {
        let alert = Toast(.error, "Alert", action: ToastAction(label: "Retry") {})
        let plain = Toast(.info, "Plain")

        center.show(alert)
        center.show(plain)

        #expect(center.alerts.map(\.id) == [alert.id])
        #expect(center.visible.map(\.id) == [plain.id])
    }

    @Test func dismissRemovesAlertAndAdvancesQueue() {
        let first = Toast(.error, "First", action: ToastAction(label: "Retry") {})
        let second = Toast(.error, "Second", action: ToastAction(label: "Retry") {})
        center.show(first)
        center.show(second)

        center.dismiss(first.id)

        #expect(center.alerts.map(\.id) == [second.id])
    }

    @Test func dismissAllClearsAlerts() {
        center.show(Toast(.error, "Alert", action: ToastAction(label: "Retry") {}))

        center.dismissAll()

        #expect(center.alerts.isEmpty)
    }
    #endif

    #if os(watchOS)
    @Test func everyStyleDefaultsToOneBottomToastQueued() {
        let styles: [any ToastStyle] = [.glassCapsule, .banner, .snackbar, .deck]

        for style in styles {
            let tuning = ToastTuning(style: style)

            #expect(tuning.placement == .bottom)
            #expect(tuning.presentation == .queue)
            #expect(tuning.maxVisible == 1)
        }
    }

    @Test func explicitSettingsWin() {
        tuning.presentation = .stack
        tuning.maxVisible = 3
        let toasts = (1...3).map { Toast(.info, "Toast \($0)") }

        toasts.forEach(center.show)

        #expect(center.visible.map(\.id) == toasts.map(\.id))
    }

    @Test func deckIsLaidOutAsCapsules() {
        #expect(DeckToastStyle().layout == GlassCapsuleToastStyle().layout)
    }
    #else
    @Test func stylesKeepTheirDefaults() {
        #expect(ToastTuning(style: .glassCapsule).placement == .top)
        #expect(ToastTuning(style: .snackbar).presentation == .queue)
        #expect(ToastTuning(style: .deck).placement == .bottom)
        #expect(ToastTuning().maxVisible == 3)
        #expect(DeckToastStyle().layout == .deck)
    }
    #endif
}
