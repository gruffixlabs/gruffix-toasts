/// Stands in for `Task.sleep` so tests control time. Calls to `sleep(for:)` suspend until
/// `advance(by:)` moves the virtual clock to their deadline, or until their task is cancelled.
final class ManualSleeper {
    private struct Sleeper {
        let id: Int
        let deadline: Duration
        let continuation: CheckedContinuation<Void, any Error>
    }

    private(set) var now: Duration = .zero
    private var sleepers: [Sleeper] = []
    private var nextId = 0

    /// Number of sleeps waiting for the clock to advance.
    var pendingCount: Int { sleepers.count }

    func sleep(for duration: Duration) async throws {
        try Task.checkCancellation()
        let id = nextId
        nextId += 1
        let deadline = now + duration
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                sleepers.append(Sleeper(id: id, deadline: deadline, continuation: continuation))
            }
        } onCancel: {
            // The handler can run on any thread, so hop to the main actor that owns `sleepers`.
            Task { @MainActor in self.cancelSleeper(id) }
        }
    }

    /// Moves the clock forward by `duration`. Sleepers due within the interval resume one at a
    /// time in deadline order, and the work each one triggers runs before the next resumes, so
    /// chained waits such as a timeout followed by a queue gap fire as they would in real time.
    func advance(by duration: Duration) async {
        let target = now + duration
        await settle()
        while let next = nextDueSleeper(by: target) {
            sleepers.removeAll { $0.id == next.id }
            now = next.deadline
            next.continuation.resume()
            await settle()
        }
        now = target
    }

    /// Lets tasks that were started, resumed or cancelled run until they suspend again.
    /// The code under test and its tasks all run on the main actor, whose queue is first in,
    /// first out, so a fixed number of yields drains the short chains of work it creates.
    func settle() async {
        for _ in 0..<20 {
            await Task.yield()
        }
    }

    private func nextDueSleeper(by target: Duration) -> Sleeper? {
        // `min(by:)` keeps the earliest-registered sleeper among equal deadlines.
        sleepers.filter { $0.deadline <= target }.min { $0.deadline < $1.deadline }
    }

    private func cancelSleeper(_ id: Int) {
        guard let index = sleepers.firstIndex(where: { $0.id == id }) else { return }
        sleepers.remove(at: index).continuation.resume(throwing: CancellationError())
    }
}
