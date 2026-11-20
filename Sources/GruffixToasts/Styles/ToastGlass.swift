import SwiftUI

/// Liquid Glass behind a toast on OS 26 and later. Earlier systems have no glass, so they get
/// a material with the same tint in the same shape, keeping the layout identical.
struct ToastGlassBackground<S: Shape>: ViewModifier {
    let tint: Color?
    let isInteractive: Bool
    let shape: S

    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            content.glassEffect(glass, in: shape)
        } else {
            content.background {
                ZStack {
                    shape.fill(.regularMaterial)
                    if let tint {
                        shape.fill(tint)
                    }
                }
            }
        }
    }

    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, *)
    private var glass: Glass {
        var glass = Glass.regular
        if let tint {
            glass = glass.tint(tint)
        }
        if isInteractive {
            glass = glass.interactive()
        }
        return glass
    }
}

/// The glass button styles on OS 26 and later, and their bordered counterparts before that.
struct ToastGlassButtonModifier: ViewModifier {
    let isProminent: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            if isProminent {
                content.buttonStyle(.glassProminent)
            } else {
                content.buttonStyle(.glass)
            }
        } else {
            if isProminent {
                content.buttonStyle(.borderedProminent)
            } else {
                content.buttonStyle(.bordered)
            }
        }
    }
}

extension View {
    /// Puts the built-in styles' glass background behind a view: Liquid Glass on OS 26 and later,
    /// and a tinted `.regularMaterial` in the same shape before that.
    /// - Parameters:
    ///   - tint: A color to tint the glass with, or `nil` for untinted glass.
    ///   - isInteractive: Whether the glass reacts to touches on OS 26 and later.
    ///   - shape: The shape of the background.
    public func toastGlass(tint: Color?, isInteractive: Bool, in shape: some Shape) -> some View {
        modifier(ToastGlassBackground(tint: tint, isInteractive: isInteractive, shape: shape))
    }

    /// Gives a button the built-in styles' look: the glass button styles on OS 26 and later, and
    /// their bordered counterparts before that.
    /// - Parameter isProminent: Whether to use the prominent variant, as for a toast's action.
    public func toastGlassButtonStyle(isProminent: Bool) -> some View {
        modifier(ToastGlassButtonModifier(isProminent: isProminent))
    }
}
