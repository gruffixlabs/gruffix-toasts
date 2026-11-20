import SwiftUI

/// How toasts look. Each style has a default placement and presentation, which
/// `ToastTuning` can override. On watchOS every style defaults to the bottom edge, queued, since
/// the screen fits one toast.
public enum ToastStyle: CaseIterable, Hashable {
    /// A compact capsule with Liquid Glass on iOS 26 and later, or a tinted material before.
    /// Defaults to the top edge, stacked.
    case glassCapsule
    /// A full-width card with a tinted leading stripe. Defaults to the top edge, stacked.
    case banner
    /// A compact dark bar. Defaults to the bottom edge, queued.
    case snackbar
    /// Cards that pile up behind the newest and expand into a list when tapped. Defaults to the
    /// bottom edge, stacked.
    ///
    /// On tvOS the deck doesn't expand. On watchOS, which has no room for a pile, it's drawn as
    /// ``glassCapsule``.
    case deck

    /// The style actually drawn on this platform.
    var rendered: ToastStyle {
        #if os(watchOS)
        self == .deck ? .glassCapsule : self
        #else
        self
        #endif
    }

    var defaultPlacement: ToastPlacement {
        #if os(watchOS)
        return .bottom
        #else
        switch self {
        case .glassCapsule, .banner: .top
        case .snackbar, .deck: .bottom
        }
        #endif
    }

    var defaultPresentation: ToastPresentation {
        #if os(watchOS)
        return .queue
        #else
        switch self {
        case .snackbar: .queue
        case .glassCapsule, .banner, .deck: .stack
        }
        #endif
    }

    func transition(from placement: ToastPlacement) -> AnyTransition {
        switch self {
        case .glassCapsule:
            .move(edge: placement.edge)
                .combined(with: .scale(scale: 0.6, anchor: placement.anchor))
                .combined(with: .opacity)
        case .banner, .deck:
            .move(edge: placement.edge).combined(with: .opacity)
        case .snackbar:
            .scale(scale: 0.9, anchor: placement.anchor).combined(with: .opacity)
        }
    }

    @ViewBuilder
    func view(for toast: Toast, showsClose: Bool, dismiss: @escaping () -> Void) -> some View {
        switch self {
        case .glassCapsule: GlassCapsuleToast(toast: toast, showsClose: showsClose, dismiss: dismiss)
        case .banner: BannerToast(toast: toast, showsClose: showsClose, dismiss: dismiss)
        case .snackbar: SnackbarToast(toast: toast, showsClose: showsClose, dismiss: dismiss)
        case .deck: DeckToastCard(toast: toast, showsClose: showsClose, dismiss: dismiss)
        }
    }
}
