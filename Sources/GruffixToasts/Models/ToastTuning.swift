import SwiftUI

/// Prototype knobs for how toasts look, move and time out. Edited live by `ToastTuningPanel`.
@Observable
public final class ToastTuning {
    public var style: ToastStyle
    public var placement: ToastPlacement
    public var presentation: ToastPresentation
    public var maxVisible = 3

    public var infoSeconds = 3.0
    public var successSeconds = 3.0
    public var warningSeconds = 5.0
    public var errorSeconds = 6.0
    public var isErrorSticky = true
    /// Extra time given to toasts with an action so there's a chance to tap it.
    public var actionBonusSeconds = 2.0

    public var springPreset = SpringPreset.snappy
    public var customResponse = 0.4
    public var customDamping = 0.75
    /// Delay between toasts fired together as a burst.
    public var staggerSeconds = 0.15
    /// Pause between queued toasts so each exit reads before the next entrance.
    public var queueGapSeconds = 0.25
    public var swipeThreshold = 50.0

    public var animation: Animation {
        switch springPreset {
        case .snappy: .snappy
        case .bouncy: .bouncy(duration: 0.5, extraBounce: 0.1)
        case .smooth: .smooth(duration: 0.45)
        case .custom: .spring(response: customResponse, dampingFraction: customDamping)
        }
    }

    public init(style: ToastStyle = .glassCapsule) {
        self.style = style
        placement = style.defaultPlacement
        presentation = style.defaultPresentation
    }

    /// Seconds before `toast` auto-dismisses, or `nil` if it stays until dismissed.
    public func seconds(for toast: Toast) -> Double? {
        let base: Double
        switch toast.severity {
        case .info: base = infoSeconds
        case .success: base = successSeconds
        case .warning: base = warningSeconds
        case .error:
            if isErrorSticky { return nil }
            base = errorSeconds
        }
        return toast.action == nil ? base : base + actionBonusSeconds
    }

    public func applyDefaults(for style: ToastStyle) {
        placement = style.defaultPlacement
        presentation = style.defaultPresentation
    }
}

public enum ToastPlacement: CaseIterable, Hashable {
    case top
    case bottom

    public var name: String {
        switch self {
        case .top: "Top"
        case .bottom: "Bottom"
        }
    }

    public var edge: Edge {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }

    public var alignment: Alignment {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }

    public var anchor: UnitPoint {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }
}

public enum ToastPresentation: CaseIterable, Hashable {
    /// Several toasts on screen at once, newest closest to the edge.
    case stack
    /// One toast at a time; the rest wait their turn.
    case queue

    public var name: String {
        switch self {
        case .stack: "Stack"
        case .queue: "Queue"
        }
    }
}

public enum SpringPreset: CaseIterable, Hashable {
    case snappy
    case bouncy
    case smooth
    case custom

    public var name: String {
        switch self {
        case .snappy: "Snappy"
        case .bouncy: "Bouncy"
        case .smooth: "Smooth"
        case .custom: "Custom"
        }
    }
}
