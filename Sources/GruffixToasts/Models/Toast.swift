import SwiftUI

/// A transient, app-wide message shown by `ToastCenter`.
public struct Toast: Identifiable {
    public let id = UUID()
    public let severity: ToastSeverity
    public let title: String
    public let message: String?
    public let action: ToastAction?

    public init(_ severity: ToastSeverity, _ title: String, message: String? = nil, action: ToastAction? = nil) {
        self.severity = severity
        self.title = title
        self.message = message
        self.action = action
    }
}

/// A single button offered on a toast, such as Retry or Undo. The toast dismisses after it runs.
public struct ToastAction {
    public let label: String
    public let perform: () -> Void

    public init(label: String, perform: @escaping () -> Void) {
        self.label = label
        self.perform = perform
    }
}

public enum ToastSeverity: CaseIterable, Hashable {
    case info
    case success
    case warning
    case error

    public var name: String {
        switch self {
        case .info: "Info"
        case .success: "Success"
        case .warning: "Warning"
        case .error: "Error"
        }
    }

    public var symbol: String {
        switch self {
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        }
    }

    public var tint: Color {
        switch self {
        case .info: .blue
        case .success: .green
        case .warning: .orange
        case .error: .red
        }
    }

    public var feedback: SensoryFeedback {
        switch self {
        case .info: .impact(weight: .light)
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
    }
}
