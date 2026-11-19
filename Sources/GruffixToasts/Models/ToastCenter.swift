import SwiftUI

/// App-wide owner of toast state. Put it in the environment with `.toastHost(_:)` and read it
/// from any view with `@Environment(ToastCenter.self)`.
@Observable
public final class ToastCenter {
    public private(set) var visible: [Toast] = []
    public private(set) var pending: [Toast] = []
    /// The most recently presented toast; drives haptics without re-firing when older toasts leave.
    public private(set) var lastShown: Toast?
    public let tuning: ToastTuning

    @ObservationIgnored private var timers: [Toast.ID: Task<Void, Never>] = [:]

    public init(tuning: ToastTuning = ToastTuning()) {
        self.tuning = tuning
    }

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
        Task { [weak self] in
            for (index, toast) in toasts.enumerated() {
                if index > 0, let stagger = self?.tuning.staggerSeconds {
                    do {
                        try await Task.sleep(for: .seconds(stagger))
                    } catch {
                        return
                    }
                }
                self?.show(toast)
            }
        }
    }

    public func dismiss(_ id: Toast.ID) {
        timers[id]?.cancel()
        timers[id] = nil
        pending.removeAll { $0.id == id }
        visible.removeAll { $0.id == id }
        if visible.isEmpty && !pending.isEmpty {
            presentNextQueued()
        }
    }

    public func dismissAll() {
        timers.values.forEach { $0.cancel() }
        timers.removeAll()
        pending.removeAll()
        visible.removeAll()
    }

    /// Stops the auto-dismiss timer, for example while the toast is being dragged.
    public func pauseTimer(for id: Toast.ID) {
        timers[id]?.cancel()
        timers[id] = nil
    }

    /// Restarts the full timer rather than the remainder; good enough for prototyping feel.
    public func resumeTimer(for id: Toast.ID) {
        guard let toast = visible.first(where: { $0.id == id }) else { return }
        scheduleTimer(for: toast)
    }

    private func present(_ toast: Toast) {
        visible.append(toast)
        lastShown = toast
        scheduleTimer(for: toast)
        AccessibilityNotification.Announcement(toast.title).post()
    }

    private func presentNextQueued() {
        Task { [weak self] in
            guard let gap = self?.tuning.queueGapSeconds else { return }
            do {
                try await Task.sleep(for: .seconds(gap))
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
        timers[toast.id] = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(seconds))
            } catch {
                // Cancelled because the toast was dismissed or paused.
                return
            }
            self?.dismiss(toast.id)
        }
    }
}
