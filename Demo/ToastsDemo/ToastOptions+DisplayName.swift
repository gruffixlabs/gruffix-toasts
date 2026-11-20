import GruffixToasts

// Names for the playground's pickers and titles. The library has no user-facing names for its
// options, so the demo supplies them.

extension ToastStyle {
    var displayName: String {
        switch self {
        case .glassCapsule: "Glass Capsule"
        case .banner: "Banner"
        case .snackbar: "Snackbar"
        case .deck: "Deck"
        }
    }
}

extension ToastPlacement {
    var displayName: String {
        switch self {
        case .top: "Top"
        case .bottom: "Bottom"
        }
    }
}

extension ToastPresentation {
    var displayName: String {
        switch self {
        case .stack: "Stack"
        case .queue: "Queue"
        }
    }
}

extension SpringPreset {
    var displayName: String {
        switch self {
        case .snappy: "Snappy"
        case .bouncy: "Bouncy"
        case .smooth: "Smooth"
        case .custom: "Custom"
        }
    }
}
