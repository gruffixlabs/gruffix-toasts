# Platform Differences

How toasts adapt to iOS, macOS, tvOS and watchOS.

## Overview

GruffixToasts has the same API on every platform. You write one set of calls, and the library adapts how toasts present, dismiss and respond to each platform's input and screen size.

### iOS and iPadOS

Toasts draw in a window above the scene's own, so sheets, full-screen covers and popovers don't hide them. That window takes touches only on the toasts themselves; everything else reaches your app, and the window never becomes key. Toasts dismiss after their duration, or when swiped toward their edge or sideways. Severity plays a haptic.

On iPad, apply ``SwiftUICore/View/toastHost(_:)`` in each scene, usually with a ``ToastCenter`` per scene.

### macOS

Toasts draw in a borderless child window above the host's window, below its title bar and toolbar, so sheets and popovers don't hide them. Clicks pass through everywhere except on the toasts. Apply ``SwiftUICore/View/toastHost(_:)`` in each window, usually with a center per window; a shared center shows every toast in every window. A toast can be dragged away like on iOS. There are no haptics.

### tvOS

A toast never takes focus from what someone is watching or browsing, so tvOS toasts are passive:

- Every toast times out. ``ToastTuning/isErrorSticky`` is ignored, and there's no close button.
- A toast with a ``ToastAction`` shows as an alert instead, titled with the toast's text, with its detail as the message and the action beside Cancel. Alerts show one at a time and stay until someone chooses a button; toasts without an action keep showing meanwhile.
- There's no swipe to dismiss, and the ``ToastStyle/deck`` style doesn't expand.
- Spacing is larger, to suit a screen read from across the room. There are no haptics.

### watchOS

A watch screen fits about one toast, so toasts default to one at a time, queued, at the bottom, away from the time. Settings you make on ``ToastTuning`` still apply. A tap dismisses a toast; there's no drag, which would compete with scrolling, the Digital Crown and swipe-back navigation. The ``ToastStyle/glassCapsule`` style stacks its text above its buttons, and the ``ToastStyle/deck`` style draws as the glass capsule. Severity plays a haptic.

watchOS can't add a window above the app, so toasts draw over the host's content, and a sheet covers them.

## Known limitations

- **tvOS alerts during a sheet.** The alert for a toast with an action is presented from the host's content, so it may not appear while a sheet is up.
- **Tint on macOS.** SwiftUI's `tint(_:)` can't be read from the environment, so toasts on macOS use the app's accent color rather than a tint applied above the host. On iOS and tvOS, toasts pick up the tint.

## See Also

- <doc:GettingStarted>
- ``ToastTuning``
