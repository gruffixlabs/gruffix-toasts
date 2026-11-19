import SwiftUI

/// The visual variations being compared. Each has its own default placement and presentation,
/// which the tuning panel can override.
public enum ToastStyle: CaseIterable, Hashable {
    case glassCapsule
    case banner
    case snackbar
    case deck

    public var name: String {
        switch self {
        case .glassCapsule: "Glass Capsule"
        case .banner: "Banner"
        case .snackbar: "Snackbar"
        case .deck: "Deck"
        }
    }

    public var defaultPlacement: ToastPlacement {
        switch self {
        case .glassCapsule, .banner: .top
        case .snackbar, .deck: .bottom
        }
    }

    public var defaultPresentation: ToastPresentation {
        switch self {
        case .snackbar: .queue
        case .glassCapsule, .banner, .deck: .stack
        }
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
