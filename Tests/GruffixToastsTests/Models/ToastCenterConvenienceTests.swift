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
        let id = show(severity, "Text", detail: nil, action: nil)

        let toast = try #require(center.visible.only)
        #expect(toast.id == id)
        #expect(toast.severity == severity)
        #expect(toast.text == "Text")
        #expect(toast.detail == nil)
        #expect(toast.action == nil)
    }

    @Test(arguments: ToastSeverity.allCases)
    func passesDetailAndActionForEachSeverity(_ severity: ToastSeverity) throws {
        var didPerform = false
        show(severity, "Text", detail: "Detail", action: ToastAction(label: "Undo") { didPerform = true })

        let toast = try #require(center.visible.only)
        #expect(toast.detail == "Detail")
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
        #expect(toast.text == "Upload failed")
        #expect(toast.detail == "Check your connection.")
    }

    @Test func errorDetailReplacesRecoverySuggestion() throws {
        center.error(SampleError(), detail: "Try again later.", action: ToastAction(label: "Retry") {})

        let toast = try #require(center.visible.only)
        #expect(toast.detail == "Try again later.")
        #expect(toast.action?.label == "Retry")
    }

    @Test func errorWithoutLocalizationHasNoDetail() throws {
        let error = PlainError()
        center.error(error)

        let toast = try #require(center.visible.only)
        #expect(toast.text == error.localizedDescription)
        #expect(toast.detail == nil)
    }

    @discardableResult
    private func show(_ severity: ToastSeverity, _ text: String, detail: String?, action: ToastAction?) -> Toast.ID {
        switch severity {
        case .info: center.info(text, detail: detail, action: action)
        case .success: center.success(text, detail: detail, action: action)
        case .warning: center.warning(text, detail: detail, action: action)
        case .error: center.error(text, detail: detail, action: action)
        }
    }
}

private extension Array {
    /// The sole element, or `nil` if the array doesn't have exactly one.
    var only: Element? { count == 1 ? first : nil }
}
