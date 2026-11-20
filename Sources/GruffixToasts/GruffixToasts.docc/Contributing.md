# Contributing

Build, test and try GruffixToasts from a checkout of the repository.

## Overview

GruffixToasts is a Swift package with one library target, `GruffixToasts`, and one test target, `GruffixToastsTests`. A separate demo app in `Demo/` uses the package from the same checkout. The package uses Swift 6 language mode with complete strict concurrency checking, `MainActor` default isolation, and the `NonisolatedNonsendingByDefault` and `InferIsolatedConformances` upcoming features.

### Project layout

- `Sources/GruffixToasts/`: the library, organized by feature: `Models`, `Modifiers`, `Overlay`, `Styles` and `Views`.
- `Sources/GruffixToasts/Demo/`: sample toasts for previews, compiled only in debug builds.
- `Sources/GruffixToasts/GruffixToasts.docc/`: this documentation.
- `Tests/GruffixToastsTests/`: tests written with Swift Testing.
- `Demo/ToastsDemo.xcodeproj`: the demo app for iOS and macOS.

### Build and test

Use `xcodebuild`; `swift build` and `swift test` cover only the host Mac. Build each platform:

```sh
xcodebuild build -scheme GruffixToasts -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme GruffixToasts -destination 'generic/platform=macOS'
xcodebuild build -scheme GruffixToasts -destination 'generic/platform=tvOS Simulator'
xcodebuild build -scheme GruffixToasts -destination 'generic/platform=watchOS Simulator'
```

Run the tests on macOS, or on a simulator from `xcrun simctl list devices available`:

```sh
xcodebuild test -scheme GruffixToasts -destination 'platform=macOS'
xcodebuild test -scheme GruffixToasts -destination 'platform=iOS Simulator,name=<device>'
```

Some tests run only on the platform whose behavior they cover, so test counts differ between platforms.

Continuous integration runs these tests on iOS, macOS, tvOS and watchOS with Xcode 27 for every pull request that's ready for review and every push to `main`. Changes to documentation alone skip it. The workflow is `.github/workflows/ci.yml`.

Build this documentation with:

```sh
xcodebuild docbuild -scheme GruffixToasts -destination 'generic/platform=iOS Simulator'
```

Every change to `Sources/` on `main` publishes it to GitHub Pages at <https://gruffixlabs.github.io/gruffix-toasts/>. The workflow is `.github/workflows/docs.yml`.

### Try the demo app

Open `Demo/ToastsDemo.xcodeproj` and run the `ToastsDemo` scheme on iOS or macOS. The playground fires sample toasts, opens a sheet to show toasts above a presentation, and has a tuning panel that edits ``ToastTuning`` live. Its previews compare styles and states.

The app shares the library's sample toasts through a symbolic link, so it builds only in the Debug configuration. Set your own development team in Xcode to run it on a device.

### Previews

Each style has a preview that renders on every platform. Shared sample toasts live in `ToastSamples` in `Sources/GruffixToasts/Demo/`, wrapped in `#if DEBUG`.

### Changes and versions

The package follows Semantic Versioning in its 0.x phase: breaking changes bump the minor version, and additions and fixes bump the patch version. Record user-visible changes under Unreleased in `CHANGELOG.md`.
