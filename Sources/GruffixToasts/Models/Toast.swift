import SwiftUI

/// A transient, app-wide message shown by `ToastCenter`.
public struct Toast: Identifiable {
    /// A unique identifier, assigned when the toast is created. Pass it to
    /// `ToastCenter.dismiss(_:)` to remove the toast early.
    public let id = UUID()
    /// How important the toast is. Sets its icon, tint, haptic and how long it stays on screen.
    public let severity: ToastSeverity
    /// The toast's main text. VoiceOver announces it when the toast appears.
    public let text: String
    /// Optional supporting text shown below `text`.
    public let detail: String?
    /// Optional button shown on the toast.
    public let action: ToastAction?

    /// Creates a toast.
    /// - Parameters:
    ///   - severity: How important the toast is.
    ///   - text: The toast's main text.
    ///   - detail: Optional supporting text shown below `text`.
    ///   - action: Optional button shown on the toast. Toasts with an action stay on screen longer.
    public init(_ severity: ToastSeverity, _ text: String, detail: String? = nil, action: ToastAction? = nil) {
        self.severity = severity
        self.text = text
        self.detail = detail
        self.action = action
    }
}

/// A single button offered on a toast, such as Retry or Undo. The toast dismisses after it runs.
///
/// On tvOS, where a toast can't take focus, a toast with an action shows as an alert instead,
/// with this button beside Cancel.
public struct ToastAction {
    /// The button's title.
    public let label: String
    /// The work to do when the button is tapped, or activated as a VoiceOver custom action.
    public let perform: () -> Void

    /// Creates an action.
    /// - Parameters:
    ///   - label: The button's title.
    ///   - perform: The work to do when the button is tapped. The toast dismisses afterward.
    public init(label: String, perform: @escaping () -> Void) {
        self.label = label
        self.perform = perform
    }
}

/// How important a toast is. Severity sets the toast's icon, tint, haptic and how long it stays
/// on screen. Haptics play on iOS and watchOS; macOS and tvOS have none to play.
public enum ToastSeverity: CaseIterable, Hashable {
    /// Neutral information.
    case info
    /// Something finished successfully.
    case success
    /// Something needs attention but didn't fail.
    case warning
    /// Something failed. By default, errors stay on screen until dismissed.
    case error

    var symbol: String {
        switch self {
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        }
    }

    var tint: Color {
        switch self {
        case .info: .blue
        case .success: .green
        case .warning: .orange
        case .error: .red
        }
    }

    var feedback: SensoryFeedback {
        switch self {
        case .info: .impact(weight: .light)
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
    }
}
