# Getting Started

Add GruffixToasts to your app, host a toast center and show your first toast.

## Overview

A ``ToastCenter`` owns the toasts on screen. You install it once, at the root of a window, with ``SwiftUICore/View/toastHost(_:)``. Views beneath it read the center from the environment and show toasts through it.

### Add the package

In Xcode, choose File > Add Package Dependencies, enter `https://github.com/gruffixlabs/gruffix-toasts`, and add the `GruffixToasts` library to your app target.

In a `Package.swift`, add the dependency and the product:

```swift
dependencies: [
    .package(url: "https://github.com/gruffixlabs/gruffix-toasts", from: "0.1.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [.product(name: "GruffixToasts", package: "gruffix-toasts")]
    ),
]
```

GruffixToasts supports iOS 17, macOS 14, tvOS 17 and watchOS 10 and later.

### Host a toast center

Create the center as state at the root of each window and apply ``SwiftUICore/View/toastHost(_:)`` to the root view:

```swift
import GruffixToasts
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var toasts = ToastCenter()

    var body: some View {
        ContentView()
            .toastHost(toasts)
    }
}
```

Toasts draw above the window's content, including sheets, full-screen covers and popovers. Each window gets its own host; with a shared center, every toast would appear in every window.

### Show toasts

Read the center with ``SwiftUICore/EnvironmentValues/toastCenter`` and call the shortcut for the severity you want:

```swift
struct EditorView: View {
    @Environment(\.toastCenter) private var toasts
    let document: Document

    var body: some View {
        Button("Save", action: save)
    }

    private func save() {
        do {
            try document.save()
            toasts.success("Document saved", detail: document.name)
        } catch {
            toasts.error(error, action: ToastAction(label: "Retry", perform: save))
        }
    }
}
```

``ToastCenter/info(_:detail:action:)``, ``ToastCenter/success(_:detail:action:)``, ``ToastCenter/warning(_:detail:action:)`` and ``ToastCenter/error(_:detail:action:)-(String,_,_)`` each show a toast and return its identifier. ``ToastCenter/error(_:detail:action:)-(Error,_,_)`` takes an `Error` and uses its localized description and recovery suggestion. Pass the identifier to ``ToastCenter/dismiss(_:)`` to remove the toast early. To build a toast yourself, create a ``Toast`` and pass it to ``ToastCenter/show(_:)-(Toast)``.

A ``ToastAction`` adds one button, such as Retry or Undo. The toast dismisses after the action runs, and toasts with an action stay on screen a little longer.

Reading ``SwiftUICore/EnvironmentValues/toastCenter`` in a view with no host above it, including in a preview, stops with a message naming ``SwiftUICore/View/toastHost(_:)``. Add a host to the preview's root view.

### Customize with ToastTuning

``ToastTuning`` controls how toasts look, move and time out. Pass one when you create the center:

```swift
@State private var toasts = ToastCenter(tuning: ToastTuning(style: .banner))
```

Each ``ToastStyle`` has a default ``ToastPlacement`` and ``ToastPresentation``, which you can override. Tuning is observable, so changes made while toasts are showing take effect at once:

```swift
let tuning = ToastTuning(style: .snackbar)
tuning.placement = .top
tuning.successSeconds = 2
tuning.isErrorSticky = false
tuning.springPreset = .bouncy
```

Errors stay on screen with a close button until dismissed, unless you turn off ``ToastTuning/isErrorSticky``. In stack presentation, ``ToastTuning/maxVisible`` caps how many toasts are on screen at once.

To draw toasts your own way, see <doc:CreatingACustomStyle>.

## See Also

- <doc:CreatingACustomStyle>
- <doc:PlatformDifferences>
