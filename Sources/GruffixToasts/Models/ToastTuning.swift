import SwiftUI

/// How toasts look, move and time out. Observable, so changes made while toasts are showing
/// take effect live.
@Observable
public final class ToastTuning {
    /// The visual style of every toast.
    public var style: ToastStyle
    /// The screen edge toasts appear at. Defaults to the style's preferred edge.
    public var placement: ToastPlacement
    /// Whether toasts stack or queue. Defaults to the style's preferred presentation.
    public var presentation: ToastPresentation
    /// The most toasts on screen at once in stack presentation. Showing another dismisses the oldest.
    public var maxVisible = 3

    /// Seconds an info toast stays on screen.
    public var infoSeconds = 3.0
    /// Seconds a success toast stays on screen.
    public var successSeconds = 3.0
    /// Seconds a warning toast stays on screen.
    public var warningSeconds = 5.0
    /// Seconds an error toast stays on screen when `isErrorSticky` is `false`.
    public var errorSeconds = 6.0
    /// Whether error toasts stay on screen, with a close button, until dismissed.
    public var isErrorSticky = true
    /// Extra seconds given to toasts with an action so there's a chance to tap it.
    public var actionBonusSeconds = 2.0

    /// The spring used to animate toasts in and out.
    public var springPreset = SpringPreset.snappy
    /// The spring response, in seconds, when `springPreset` is ``SpringPreset/custom``.
    public var customResponse = 0.4
    /// The spring damping fraction when `springPreset` is ``SpringPreset/custom``.
    public var customDamping = 0.75
    /// Seconds between toasts passed together to `ToastCenter.show(_:)` as an array.
    public var staggerSeconds = 0.15
    /// Seconds between queued toasts so each exit reads before the next entrance.
    public var queueGapSeconds = 0.25
    /// Points a toast must be dragged toward its edge to dismiss it; sideways drags need twice this.
    public var swipeThreshold = 50.0

    var animation: Animation {
        switch springPreset {
        case .snappy: .snappy
        case .bouncy: .bouncy(duration: 0.5, extraBounce: 0.1)
        case .smooth: .smooth(duration: 0.45)
        case .custom: .spring(response: customResponse, dampingFraction: customDamping)
        }
    }

    /// Creates tuning for a style, using that style's default placement and presentation.
    /// - Parameter style: The visual style of every toast.
    public init(style: ToastStyle = .glassCapsule) {
        self.style = style
        placement = style.defaultPlacement
        presentation = style.defaultPresentation
    }

    /// Seconds before `toast` auto-dismisses, or `nil` if it stays until dismissed.
    func seconds(for toast: Toast) -> Double? {
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
}

/// The screen edge toasts appear at.
public enum ToastPlacement: CaseIterable, Hashable {
    /// Toasts appear at the top of the screen.
    case top
    /// Toasts appear at the bottom of the screen.
    case bottom

    var edge: Edge {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }

    var alignment: Alignment {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }

    var anchor: UnitPoint {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }
}

/// How toasts share the screen.
public enum ToastPresentation: CaseIterable, Hashable {
    /// Several toasts on screen at once, newest closest to the edge.
    case stack
    /// One toast at a time; the rest wait their turn.
    case queue
}

/// The spring used to animate toasts.
public enum SpringPreset: CaseIterable, Hashable {
    /// A quick spring with no bounce.
    case snappy
    /// A spring with a little bounce.
    case bouncy
    /// A gentle spring with no bounce.
    case smooth
    /// A spring built from `ToastTuning.customResponse` and `ToastTuning.customDamping`.
    case custom
}
