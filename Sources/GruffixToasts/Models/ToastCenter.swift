import SwiftUI

/// App-wide owner of toast state. Put it in the environment with `.toastHost(_:)` and read it
/// from any view with `@Environment(\.toastCenter)`.
@Observable
public final class ToastCenter {
    private(set) var visible: [Toast] = []
    private(set) var pending: [Toast] = []
    /// The most recently presented toast; drives haptics without re-firing when older toasts leave.
    private(set) var lastShown: Toast?
    /// Toasts with an action, waiting to be shown one at a time as alerts. Only tvOS fills it: a
    /// toast there never takes focus, so its button couldn't be reached.
    private(set) var alerts: [Toast] = []
    /// How toasts look, move and time out.
    public let tuning: ToastTuning
    /// Suspends for a duration. Injected so tests can drive timers without waiting in real time.
    private let sleep: (Duration) async throws -> Void

    @ObservationIgnored private var timers: [Toast.ID: Task<Void, Never>] = [:]

    /// Creates a toast center.
    /// - Parameter tuning: How toasts look, move and time out.
    public convenience init(tuning: ToastTuning = ToastTuning()) {
        self.init(tuning: tuning, sleep: { try await Task.sleep(for: $0) })
    }

    init(tuning: ToastTuning, sleep: @escaping (Duration) async throws -> Void) {
        self.tuning = tuning
        self.sleep = sleep
    }

    /// Shows a toast. In stack presentation it appears at once, dismissing the oldest toast
    /// when more than `ToastTuning.maxVisible` are on screen. In queue presentation it waits
    /// until the toasts ahead of it have been dismissed.
    ///
    /// On tvOS a toast with an action is shown as an alert instead, with the action and a
    /// Cancel button. Alerts wait for each other, not for toasts, and stay until a button is chosen.
    public func show(_ toast: Toast) {
        #if os(tvOS)
        if toast.action != nil {
            alerts.append(toast)
            AccessibilityNotification.Announcement(toast.text).post()
            return
        }
        #endif
        switch tuning.presentation {
        case .stack:
            present(toast)
            while visible.count > tuning.maxVisible, let oldest = visible.first {
                dismiss(oldest.id)
            }
        case .queue:
            if visible.isEmpty && pending.isEmpty {
                present(toast)
            } else {
                pending.append(toast)
            }
        }
    }

    /// Shows several toasts in order, separated by the tuning stagger.
    public func show(_ toasts: [Toast]) {
        Task { [weak self, sleep] in
            for (index, toast) in toasts.enumerated() {
                if index > 0, let stagger = self?.tuning.staggerSeconds {
                    do {
                        try await sleep(.seconds(stagger))
                    } catch {
                        return
                    }
                }
                self?.show(toast)
            }
        }
    }

    /// Shows an ``ToastSeverity/info`` toast.
    /// - Parameters:
    ///   - text: The toast's main text.
    ///   - detail: Optional supporting text shown below `text`.
    ///   - action: Optional button shown on the toast.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func info(_ text: String, detail: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.info, text, detail: detail, action: action)
    }

    /// Shows a ``ToastSeverity/success`` toast.
    /// - Parameters:
    ///   - text: The toast's main text.
    ///   - detail: Optional supporting text shown below `text`.
    ///   - action: Optional button shown on the toast.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func success(_ text: String, detail: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.success, text, detail: detail, action: action)
    }

    /// Shows a ``ToastSeverity/warning`` toast.
    /// - Parameters:
    ///   - text: The toast's main text.
    ///   - detail: Optional supporting text shown below `text`.
    ///   - action: Optional button shown on the toast.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func warning(_ text: String, detail: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.warning, text, detail: detail, action: action)
    }

    /// Shows an ``ToastSeverity/error`` toast.
    /// - Parameters:
    ///   - text: The toast's main text.
    ///   - detail: Optional supporting text shown below `text`.
    ///   - action: Optional button shown on the toast, such as Retry.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func error(_ text: String, detail: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.error, text, detail: detail, action: action)
    }

    /// Shows an ``ToastSeverity/error`` toast describing `error`.
    ///
    /// The text is the error's `localizedDescription`. Without a `detail`, the toast shows the
    /// error's localized recovery suggestion, if it has one, such as `LocalizedError.recoverySuggestion`.
    /// - Parameters:
    ///   - error: The error to describe.
    ///   - detail: Supporting text shown below `text`, replacing the recovery suggestion.
    ///   - action: Optional button shown on the toast, such as Retry.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func error(_ error: any Error, detail: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        let nsError = error as NSError
        return show(
            .error,
            nsError.localizedDescription,
            detail: detail ?? nsError.localizedRecoverySuggestion,
            action: action
        )
    }

    /// Removes a toast, whether it's on screen or still waiting in the queue. Does nothing if
    /// the toast has already gone.
    public func dismiss(_ id: Toast.ID) {
        timers[id]?.cancel()
        timers[id] = nil
        pending.removeAll { $0.id == id }
        visible.removeAll { $0.id == id }
        alerts.removeAll { $0.id == id }
        if visible.isEmpty && !pending.isEmpty {
            presentNextQueued()
        }
    }

    /// Removes every toast, on screen and queued.
    public func dismissAll() {
        timers.values.forEach { $0.cancel() }
        timers.removeAll()
        pending.removeAll()
        visible.removeAll()
        alerts.removeAll()
    }

    /// Stops the auto-dismiss timer, for example while the toast is being dragged.
    func pauseTimer(for id: Toast.ID) {
        timers[id]?.cancel()
        timers[id] = nil
    }

    /// Restarts the full timer rather than the remainder; good enough for prototyping feel.
    func resumeTimer(for id: Toast.ID) {
        guard let toast = visible.first(where: { $0.id == id }) else { return }
        scheduleTimer(for: toast)
    }

    private func show(_ severity: ToastSeverity, _ text: String, detail: String?, action: ToastAction?) -> Toast.ID {
        let toast = Toast(severity, text, detail: detail, action: action)
        show(toast)
        return toast.id
    }

    private func present(_ toast: Toast) {
        visible.append(toast)
        lastShown = toast
        scheduleTimer(for: toast)
        AccessibilityNotification.Announcement(toast.text).post()
    }

    private func presentNextQueued() {
        Task { [weak self, sleep] in
            guard let gap = self?.tuning.queueGapSeconds else { return }
            do {
                try await sleep(.seconds(gap))
            } catch {
                return
            }
            guard let self, visible.isEmpty, !pending.isEmpty else { return }
            present(pending.removeFirst())
        }
    }

    private func scheduleTimer(for toast: Toast) {
        guard let seconds = tuning.seconds(for: toast) else { return }
        timers[toast.id]?.cancel()
        timers[toast.id] = Task { [weak self, sleep] in
            do {
                try await sleep(.seconds(seconds))
            } catch {
                // Cancelled because the toast was dismissed or paused.
                return
            }
            self?.dismiss(toast.id)
        }
    }
}
