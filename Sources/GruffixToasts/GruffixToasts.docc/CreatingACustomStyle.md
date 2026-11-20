# Creating a Custom Style

Draw toasts your own way while keeping stacking, queueing, timers and dismissal.

## Overview

A ``ToastStyle`` decides how one toast looks, how it moves in and out, and where toasts go by default. Everything else is shared by every style, built-in or custom: ``ToastCenter`` stacks or queues toasts and times them out, and the toast host adds swipe to dismiss, haptics, VoiceOver support and shows toasts above sheets and other presentations.

### Define a style

Conform a type to ``ToastStyle`` and implement ``ToastStyle/makeBody(configuration:)``. The ``ToastStyleConfiguration`` gives you the ``Toast`` to draw, whether to show a close button, and an action that dismisses the toast:

```swift
struct TicketToastStyle: ToastStyle {
    func makeBody(configuration: Configuration) -> some View {
        let toast = configuration.toast
        HStack(spacing: 12) {
            Image(systemName: toast.severity.systemImage)
                .foregroundStyle(toast.severity.tint)
            Text(toast.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let action = toast.action {
                Button(action.label) {
                    action.perform()
                    configuration.dismiss()
                }
                .toastGlassButtonStyle(isProminent: true)
            }
            if configuration.showsCloseButton {
                ToastCloseButton(action: configuration.dismiss)
            }
        }
        .padding(14)
        .toastGlass(tint: toast.severity.tint.opacity(0.08), isInteractive: false, in: .rect(cornerRadius: 12))
    }
}
```

Show a close button whenever ``ToastStyleConfiguration/showsCloseButton`` is `true`. Those toasts won't time out, so the button is how most people dismiss them. After running a toast's action, call ``ToastStyleConfiguration/dismiss``, as the built-in styles do.

### Use it like a built-in style

Add a static member so your style reads the same as ``ToastStyle/glassCapsule`` at call sites:

```swift
extension ToastStyle where Self == TicketToastStyle {
    static var ticket: Self { TicketToastStyle() }
}

@State private var toasts = ToastCenter(tuning: ToastTuning(style: .ticket))
```

You can also set ``ToastTuning/style`` while toasts are showing.

### Choose defaults and a transition

A style supplies the placement and presentation that ``ToastTuning`` starts with. Explicit values set on the tuning still win. Without overrides, a style shows toasts at the top, stacked, and moves them in from that edge while fading:

```swift
struct TicketToastStyle: ToastStyle {
    var defaultPlacement: ToastPlacement { .bottom }
    var defaultPresentation: ToastPresentation { .queue }

    func transition(for placement: ToastPlacement) -> AnyTransition {
        .move(edge: .trailing).combined(with: .opacity)
    }

    // makeBody(configuration:) as above.
}
```

### Match the built-in look

These are the pieces the built-in styles are made from:

- ``ToastSeverity/systemImage`` and ``ToastSeverity/tint``: each severity's icon and color.
- ``ToastCloseButton``: the close button.
- ``SwiftUICore/View/toastGlass(tint:isInteractive:in:)``: the Liquid Glass background on OS 26 and later, with a tinted material before that.
- ``SwiftUICore/View/toastGlassButtonStyle(isProminent:)``: glass buttons on OS 26 and later, with bordered buttons before that.

Haptics for each severity play for every style, so a style doesn't need to play them.

### Preview a style

Create a ``ToastStyleConfiguration`` to see your style in Xcode Previews without a toast center:

```swift
#Preview {
    VStack(spacing: 12) {
        TicketToastStyle().makeBody(configuration: .init(toast: Toast(.success, "Document saved")))
        TicketToastStyle().makeBody(configuration: .init(toast: Toast(.error, "Couldn't save"), showsCloseButton: true))
    }
    .padding()
}
```

### Layout of several toasts

A style draws one toast at a time. Custom styles stack their toasts vertically, newest closest to the edge. The pile-and-expand layout of ``ToastStyle/deck`` is reserved to that built-in style.

### Accessibility

The host combines each toast's children into a single VoiceOver element. It also adds the toast's action and Dismiss as custom actions. Keep the toast's text in `Text` views so it's read, and give icon-only buttons a label.

### Platforms

The library applies these rules to every style:

- **watchOS:** toasts start at the bottom edge, queued, one at a time, whatever the style's defaults. A tap dismisses a toast. A watch screen is narrow, so check your layout there and consider putting buttons below the text.
- **tvOS:** toasts always time out, so ``ToastStyleConfiguration/showsCloseButton`` is always `false`. A toast with an action shows as an alert instead of through your style. A toast never takes focus, so a style shouldn't rely on buttons there. tvOS is read from across the room; the built-in styles double their spacing, and a custom style should scale its own.

See <doc:PlatformDifferences> for the full list.
