import GruffixToasts

// Names for the playground's pickers and titles. The library has no user-facing names for its
// options, so the demo supplies them. Style names live in `DemoToastStyle`.

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
