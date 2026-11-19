#if DEBUG
import Foundation

/// Believable app messages for previews and the playground. Edit freely.
///
/// These are computed so each use gets a fresh `id`; showing the same sample twice must not
/// produce two toasts with one identity.
enum ToastSamples {
    static var downloadStarted: Toast { Toast(.info, "Download started", message: "3 files, 24 MB") }
    static var documentSaved: Toast { Toast(.success, "Document saved", message: "Quarterly Report") }
    static var favoriteAdded: Toast { Toast(.success, "Added to Favorites") }
    static var lowStorage: Toast { Toast(.warning, "Storage almost full", message: "Less than 1 GB available.") }
    static var itemRestored: Toast { Toast(.info, "Item restored") }
    static var syncError: Toast { Toast(.error, "Sync paused", message: "Changes are saved on this device.") }

    static var longText: Toast {
        Toast(
            .warning,
            "“Quarterly Report – Final Revised Copy (2) – Shared with Finance” has a very long name",
            message: "Names longer than 48 characters are shortened in lists and menus. You can rename the file from its details screen."
        )
    }

    static var burst: [Toast] { [favoriteAdded, downloadStarted, lowStorage, syncError] }

    /// One of each severity, for static previews of the styles.
    static var allSeverities: [Toast] { [downloadStarted, documentSaved, lowStorage, saveFailed {}] }

    static func saveFailed(retry: @escaping () -> Void) -> Toast {
        Toast(
            .error,
            "Couldn't save “Quarterly Report”",
            message: "Your changes are still here.",
            action: ToastAction(label: "Retry", perform: retry)
        )
    }

    static func itemDeleted(undo: @escaping () -> Void) -> Toast {
        Toast(
            .success,
            "Item deleted",
            message: "“Groceries” moved to Trash",
            action: ToastAction(label: "Undo", perform: undo)
        )
    }
}
#endif
