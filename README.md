# GruffixToasts

App-wide toast messages for SwiftUI on iOS 27, with four styles (Glass Capsule, Banner, Snackbar, Deck), stack or
queue presentation, swipe to dismiss, haptics and VoiceOver announcements.

## Usage

```swift
import GruffixToasts
```

Install a `ToastCenter` once at the root, then show toasts from any descendant:

```swift
@State private var toasts = ToastCenter(tuning: ToastTuning(style: .glassCapsule))

var body: some View {
    RootView()
        .toastHost(toasts)
}
```

```swift
@Environment(ToastCenter.self) private var toasts

toasts.show(Toast(.success, "Document saved", message: "Quarterly Report"))
```

`ToastTuning` controls style, placement, durations and motion. `ToastTuningPanel` edits it live.

## Demo

`Sources/GruffixToasts/Demo` holds debug-only sample toasts and a playground. Open `Package.swift` in Xcode and use the
`#Preview`s in `ToastPlayground+Previews.swift` to compare styles and states.
