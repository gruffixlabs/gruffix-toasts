# ``GruffixToasts``

App-wide toast messages for SwiftUI on iOS, macOS, tvOS and watchOS.

## Overview

GruffixToasts shows short, transient messages, such as "Document saved" or "Couldn't save", above your app's content, including above sheets and other presentations. Install one ``ToastCenter`` at the root of a window and show toasts from any view beneath it.

```swift
@Environment(\.toastCenter) private var toasts

toasts.success("Document saved", detail: "Quarterly Report")
```

Toasts come in four styles, stack or queue, dismiss themselves after a duration set by their severity, and announce themselves to VoiceOver. The same API works on every platform; the library adapts the behavior to each one, as described in <doc:PlatformDifferences>.

## Topics

### Essentials

- <doc:GettingStarted>
- ``ToastCenter``
- ``SwiftUICore/View/toastHost(_:)``
- ``SwiftUICore/EnvironmentValues/toastCenter``

### Toasts

- ``Toast``
- ``ToastSeverity``
- ``ToastAction``

### Appearance and timing

- ``ToastTuning``
- ``ToastStyle``
- ``ToastPlacement``
- ``ToastPresentation``
- ``SpringPreset``

### Platforms

- <doc:PlatformDifferences>

### Contributing

- <doc:Contributing>
