# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `ToastCenter.info(_:detail:action:)`, `success(_:detail:action:)`, `warning(_:detail:action:)` and `error(_:detail:action:)` show a toast of that severity without building a `Toast`. Each returns the toast's identifier for dismissing it early.
- `ToastCenter.error(_:detail:action:)` also accepts an `Error`, using its localized description as the text and its recovery suggestion, if any, as the detail.
- `EnvironmentValues.toastCenter`, read with `@Environment(\.toastCenter)`. It stops with a message naming `.toastHost(_:)` when no host is installed.
- macOS 14, tvOS 17 and watchOS 10 support, with the same API as iOS.
- A demo app in `Demo/` for iOS and macOS, with the playground and tuning panel.
- Documentation: a landing page, Getting Started, Platform Differences and Contributing articles in the DocC catalog.
- Custom toast styles: conform to `ToastStyle`, implement `makeBody(configuration:)`, and set the style on `ToastTuning.style`. Custom styles get stacking, queueing, timers, swipe to dismiss, haptics, VoiceOver support and the overlay window, and can set their own default placement, presentation and transition. Documented in the "Creating a Custom Style" article.
- `ToastStyleConfiguration`, and the built-in style types `GlassCapsuleToastStyle`, `BannerToastStyle`, `SnackbarToastStyle` and `DeckToastStyle`.
- Building blocks for matching the built-in look: `ToastSeverity.systemImage` and `tint`, `ToastCloseButton`, and the `View` modifiers `toastGlass(tint:isInteractive:in:)` and `toastGlassButtonStyle(isProminent:)`.

### Removed

- `ToastTuningPanel` moved out of the library into the demo app in `Demo/`.
- Implementation details are no longer public: `ToastCenter.visible`, `pending`, `lastShown`, `pauseTimer(for:)` and `resumeTimer(for:)`; `ToastTuning.animation`, `seconds(for:)` and `applyDefaults(for:)`; `ToastSeverity.name`, `symbol`, `tint` and `feedback`; `ToastStyle.name`, `defaultPlacement` and `defaultPresentation`; `ToastPlacement.name`, `edge`, `alignment` and `anchor`; `ToastPresentation.name`; and `SpringPreset.name`.

### Changed

- **Breaking:** `ToastStyle` is now a protocol instead of an enum, so consumers can define their own styles. `.glassCapsule`, `.banner`, `.snackbar` and `.deck` still work at call sites, but `ToastStyle` is no longer `CaseIterable` or `Hashable` and can't be switched over. `ToastTuning.style` and `ToastTuning.init(style:)` take `any ToastStyle`.
- `.toastHost(_:)` no longer puts the `ToastCenter` in the environment by type, so read it with `@Environment(\.toastCenter)` instead of `@Environment(ToastCenter.self)`.
- Renamed `Toast.title` to `text` and `Toast.message` to `detail`, including the `message:` label in `Toast.init`, which is now `detail:`.
- Lowered the minimum deployment target from iOS 27.0 to iOS 17.0. Before iOS 26, the Glass Capsule and Deck styles use a tinted material instead of Liquid Glass.
- Toasts appear above sheets, full-screen covers and popovers on iOS, macOS and tvOS. They draw in a window above the host's, which passes every touch and click outside the toasts through to the app. On watchOS they still draw over the host's content.
- On tvOS, toasts never take focus, so every toast times out and `isErrorSticky` is ignored. A toast with an action shows as an alert with the action and Cancel instead, one at a time. The deck doesn't expand, and spacing is larger.
- On watchOS, toasts default to one at a time, queued, at the bottom; explicit tuning still applies. A tap dismisses a toast, there's no swipe, and the Deck style draws as the Glass Capsule.
