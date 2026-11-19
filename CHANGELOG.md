# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `ToastCenter.info(_:detail:action:)`, `success(_:detail:action:)`, `warning(_:detail:action:)` and `error(_:detail:action:)` show a toast of that severity without building a `Toast`. Each returns the toast's identifier for dismissing it early.
- `ToastCenter.error(_:detail:action:)` also accepts an `Error`, using its localized description as the text and its recovery suggestion, if any, as the detail.
- `EnvironmentValues.toastCenter`, read with `@Environment(\.toastCenter)`. It stops with a message naming `.toastHost(_:)` when no host is installed.

### Removed

- Implementation details are no longer public: `ToastCenter.visible`, `pending`, `lastShown`, `pauseTimer(for:)` and `resumeTimer(for:)`; `ToastTuning.animation`, `seconds(for:)` and `applyDefaults(for:)`; `ToastSeverity.name`, `symbol`, `tint` and `feedback`; `ToastStyle.name`, `defaultPlacement` and `defaultPresentation`; `ToastPlacement.name`, `edge`, `alignment` and `anchor`; `ToastPresentation.name`; and `SpringPreset.name`.

### Changed

- `.toastHost(_:)` no longer puts the `ToastCenter` in the environment by type, so read it with `@Environment(\.toastCenter)` instead of `@Environment(ToastCenter.self)`.
- Renamed `Toast.title` to `text` and `Toast.message` to `detail`, including the `message:` label in `Toast.init`, which is now `detail:`.
- Lowered the minimum deployment target from iOS 27.0 to iOS 17.0. Before iOS 26, the Glass Capsule and Deck styles use a tinted material instead of Liquid Glass.
