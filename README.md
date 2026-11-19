# GruffixToasts

App-wide toast messages for SwiftUI on iOS 17, macOS 14, tvOS 17 and watchOS 10 and later, with four styles (Glass Capsule, Banner, Snackbar, Deck), stack or
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
@Environment(\.toastCenter) private var toasts

toasts.success("Document saved", detail: "Quarterly Report")
toasts.error(error, action: ToastAction(label: "Retry") { save() })
```

`info`, `success`, `warning` and `error` each have a shortcut; `show(_:)` takes a `Toast` you build yourself.

`ToastTuning` controls style, placement, durations and motion.

## Demo

`Demo/` holds a playground app for iOS and macOS that uses the package from this checkout. Open
`Demo/GruffixToastsDemo.xcodeproj` and run it, or use the `#Preview`s in `ToastPlayground+Previews.swift` to compare
styles and states. The tuning panel there edits `ToastTuning` live.
