import SwiftUI

/// How a toast looks and moves. Conform to define your own style, then set it on
/// ``ToastTuning/style``.
///
/// A style draws one toast at a time. ``ToastCenter`` and the toast host handle stacking,
/// queueing, timers, swipe to dismiss, haptics, VoiceOver and showing toasts above presentations
/// for every style, built-in or custom.
///
/// Expose a style as a static member so call sites read like the built-in ones:
///
/// ```swift
/// extension ToastStyle where Self == TicketToastStyle {
///     static var ticket: Self { TicketToastStyle() }
/// }
///
/// ToastTuning(style: .ticket)
/// ```
///
/// On watchOS every style defaults to the bottom edge, queued, since the screen fits one toast.
public protocol ToastStyle {
    /// The view that draws a toast.
    associatedtype Body: View

    /// The properties of the toast being drawn.
    typealias Configuration = ToastStyleConfiguration

    /// The screen edge toasts appear at unless ``ToastTuning/placement`` is set. Defaults to
    /// ``ToastPlacement/top``.
    var defaultPlacement: ToastPlacement { get }

    /// Whether toasts stack or queue unless ``ToastTuning/presentation`` is set. Defaults to
    /// ``ToastPresentation/stack``.
    var defaultPresentation: ToastPresentation { get }

    /// Draws a toast.
    /// - Parameter configuration: The toast, whether to show a close button, and the action that
    ///   dismisses it.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The transition a toast uses to appear and disappear. Defaults to moving in from the
    /// toast's edge while fading.
    /// - Parameter placement: The edge toasts appear at.
    func transition(for placement: ToastPlacement) -> AnyTransition
}

extension ToastStyle {
    /// Defaults to ``ToastPlacement/top``.
    public var defaultPlacement: ToastPlacement { .top }

    /// Defaults to ``ToastPresentation/stack``.
    public var defaultPresentation: ToastPresentation { .stack }

    /// Moves in from the toast's edge while fading.
    public func transition(for placement: ToastPlacement) -> AnyTransition {
        .move(edge: placement.edge).combined(with: .opacity)
    }

    /// How `ToastLayer` arranges several toasts. Only built-in styles choose; custom styles stack.
    var layout: ToastStyleLayout {
        (self as? any BuiltInToastStyle)?.builtInLayout ?? .stack
    }

    /// Type-erases the body so `ToastLayer` can draw a style it only knows as `any ToastStyle`.
    func erasedBody(configuration: Configuration) -> AnyView {
        AnyView(makeBody(configuration: configuration))
    }
}

/// The properties of a toast that a ``ToastStyle`` draws.
public struct ToastStyleConfiguration {
    /// The toast to draw.
    public let toast: Toast
    /// Whether to show a close button, because the toast won't time out. Use
    /// ``ToastCloseButton`` to match the built-in styles.
    public let showsCloseButton: Bool
    /// Removes the toast. Call it from a close button, or after running the toast's action.
    public let dismiss: () -> Void

    /// Creates a configuration, such as for previewing a custom style:
    ///
    /// ```swift
    /// #Preview {
    ///     TicketToastStyle().makeBody(configuration: .init(toast: Toast(.error, "Couldn't save"), showsCloseButton: true))
    /// }
    /// ```
    ///
    /// The library creates configurations itself when it draws toasts.
    /// - Parameters:
    ///   - toast: The toast to draw.
    ///   - showsCloseButton: Whether to show a close button.
    ///   - dismiss: The work to do when the toast is dismissed. Defaults to doing nothing.
    public init(toast: Toast, showsCloseButton: Bool = false, dismiss: @escaping () -> Void = {}) {
        self.toast = toast
        self.showsCloseButton = showsCloseButton
        self.dismiss = dismiss
    }
}

/// How several toasts are arranged on screen.
enum ToastStyleLayout {
    /// A vertical stack.
    case stack
    /// A vertical stack inside a glass container, so neighboring glass shapes blend.
    case glassStack
    /// Cards that pile up behind the newest and expand into a list when tapped.
    case deck
}

/// A built-in style, which may arrange several toasts in its own layout.
protocol BuiltInToastStyle: ToastStyle {
    var builtInLayout: ToastStyleLayout { get }
}
