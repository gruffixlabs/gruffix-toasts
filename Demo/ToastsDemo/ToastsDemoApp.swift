// The library's sample toasts are compiled into this app too, through the ToastSamples.swift
// symlink. That file can't import its own module, so the app re-exports GruffixToasts here.
@_exported import GruffixToasts
import SwiftUI

@main
struct ToastsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ToastPlayground()
        }
    }
}
