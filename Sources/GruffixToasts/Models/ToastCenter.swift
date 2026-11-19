import SwiftUI

/// App-wide owner of toast state. Put it in the environment with `.toastHost(_:)` and read it
/// from any view with `@Environment(ToastCenter.self)`.
@Observable
public final class ToastCenter {
    private(set) var visible: [Toast] = []
    private(set) var pending: [Toast] = []
    /// The most recently presented toast; drives haptics without re-firing when older toasts leave.
    private(set) var lastShown: Toast?
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
    public func show(_ toast: Toast) {
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
    ///   - title: The main line of text.
    ///   - message: Optional secondary text shown below the title.
    ///   - action: Optional button shown on the toast.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func info(_ title: String, message: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.info, title, message: message, action: action)
    }

    /// Shows a ``ToastSeverity/success`` toast.
    /// - Parameters:
    ///   - title: The main line of text.
    ///   - message: Optional secondary text shown below the title.
    ///   - action: Optional button shown on the toast.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func success(_ title: String, message: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.success, title, message: message, action: action)
    }

    /// Shows a ``ToastSeverity/warning`` toast.
    /// - Parameters:
    ///   - title: The main line of text.
    ///   - message: Optional secondary text shown below the title.
    ///   - action: Optional button shown on the toast.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func warning(_ title: String, message: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.warning, title, message: message, action: action)
    }

    /// Shows an ``ToastSeverity/error`` toast.
    /// - Parameters:
    ///   - title: The main line of text.
    ///   - message: Optional secondary text shown below the title.
    ///   - action: Optional button shown on the toast, such as Retry.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func error(_ title: String, message: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        show(.error, title, message: message, action: action)
    }

    /// Shows an ``ToastSeverity/error`` toast describing `error`.
    ///
    /// The title is the error's `localizedDescription`. Without a `message`, the toast shows the
    /// error's localized recovery suggestion, if it has one, such as `LocalizedError.recoverySuggestion`.
    /// - Parameters:
    ///   - error: The error to describe.
    ///   - message: Secondary text shown below the title, replacing the recovery suggestion.
    ///   - action: Optional button shown on the toast, such as Retry.
    /// - Returns: The new toast's identifier, for dismissing it early.
    @discardableResult
    public func error(_ error: any Error, message: String? = nil, action: ToastAction? = nil) -> Toast.ID {
        let nsError = error as NSError
        return show(
            .error,
            nsError.localizedDescription,
            message: message ?? nsError.localizedRecoverySuggestion,
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

    private func show(_ severity: ToastSeverity, _ title: String, message: String?, action: ToastAction?) -> Toast.ID {
        let toast = Toast(severity, title, message: message, action: action)
        show(toast)
        return toast.id
    }

    private func present(_ toast: Toast) {
        visible.append(toast)
        lastShown = toast
        scheduleTimer(for: toast)
        AccessibilityNotification.Announcement(toast.title).post()
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
