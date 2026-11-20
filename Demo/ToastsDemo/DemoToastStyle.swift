import GruffixToasts

/// The styles the playground offers: the library's built-ins plus the demo's own custom style.
/// `ToastStyle` is a protocol, so the demo keeps its own list for pickers and titles.
enum DemoToastStyle: CaseIterable, Hashable {
    case glassCapsule
    case banner
    case snackbar
    case deck
    case ticket

    var style: any ToastStyle {
        switch self {
        case .glassCapsule: .glassCapsule
        case .banner: .banner
        case .snackbar: .snackbar
        case .deck: .deck
        case .ticket: .ticket
        }
    }

    var displayName: String {
        switch self {
        case .glassCapsule: "Glass Capsule"
        case .banner: "Banner"
        case .snackbar: "Snackbar"
        case .deck: "Deck"
        case .ticket: "Ticket (custom)"
        }
    }

    /// The case whose style has the same type as `style`, or `nil` for a style not in the list.
    init?(matching style: any ToastStyle) {
        guard let match = Self.allCases.first(where: { type(of: $0.style) == type(of: style) }) else {
            return nil
        }
        self = match
    }
}
