import Foundation
import Testing
@testable import GruffixToasts

/// The per-severity shortcuts for `show(_:)`.
struct ToastCenterConvenienceTests {
    let center = ToastCenter(tuning: ToastTuning(), sleep: ManualSleeper().sleep(for:))

    private struct SampleError: LocalizedError {
        var errorDescription: String? { "Upload failed" }
        var recoverySuggestion: String? { "Check your connection." }
    }

    private struct PlainError: Error {}

    @Test(arguments: ToastSeverity.allCases)
    func showsTitleOnlyToastForEachSeverity(_ severity: ToastSeverity) throws {
        let id = show(severity, "Title", message: nil, action: nil)

        let toast = try #require(center.visible.only)
        #expect(toast.id == id)
        #expect(toast.severity == severity)
        #expect(toast.title == "Title")
        #expect(toast.message == nil)
        #expect(toast.action == nil)
    }

    @Test(arguments: ToastSeverity.allCases)
    func passesMessageAndActionForEachSeverity(_ severity: ToastSeverity) throws {
        var didPerform = false
        show(severity, "Title", message: "Message", action: ToastAction(label: "Undo") { didPerform = true })

        let toast = try #require(center.visible.only)
        #expect(toast.message == "Message")
        let action = try #require(toast.action)
        #expect(action.label == "Undo")
        action.perform()
        #expect(didPerform)
    }

    @Test func returnedIdDismissesTheToast() {
        let id = center.info("Uploading")

        center.dismiss(id)

        #expect(center.visible.isEmpty)
    }

    @Test func errorUsesLocalizedDescriptionAndRecoverySuggestion() throws {
        center.error(SampleError())

        let toast = try #require(center.visible.only)
        #expect(toast.severity == .error)
        #expect(toast.title == "Upload failed")
        #expect(toast.message == "Check your connection.")
    }

    @Test func errorMessageReplacesRecoverySuggestion() throws {
        center.error(SampleError(), message: "Try again later.", action: ToastAction(label: "Retry") {})

        let toast = try #require(center.visible.only)
        #expect(toast.message == "Try again later.")
        #expect(toast.action?.label == "Retry")
    }

    @Test func errorWithoutLocalizationHasNoMessage() throws {
        let error = PlainError()
        center.error(error)

        let toast = try #require(center.visible.only)
        #expect(toast.title == error.localizedDescription)
        #expect(toast.message == nil)
    }

    @discardableResult
    private func show(_ severity: ToastSeverity, _ title: String, message: String?, action: ToastAction?) -> Toast.ID {
        switch severity {
        case .info: center.info(title, message: message, action: action)
        case .success: center.success(title, message: message, action: action)
        case .warning: center.warning(title, message: message, action: action)
        case .error: center.error(title, message: message, action: action)
        }
    }
}

private extension Array {
    /// The sole element, or `nil` if the array doesn't have exactly one.
    var only: Element? { count == 1 ? first : nil }
}
