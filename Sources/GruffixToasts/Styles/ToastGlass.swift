import SwiftUI

/// Liquid Glass behind a toast on iOS 26 and later. Earlier systems have no glass, so they get
/// a material with the same tint in the same shape, keeping the layout identical.
struct ToastGlassBackground<S: Shape>: ViewModifier {
    let tint: Color?
    let isInteractive: Bool
    let shape: S

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
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

    @available(iOS 26, *)
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

/// The glass button styles on iOS 26 and later, and their bordered counterparts before that.
struct ToastGlassButtonModifier: ViewModifier {
    let isProminent: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
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
    func toastGlass(tint: Color?, isInteractive: Bool, in shape: some Shape) -> some View {
        modifier(ToastGlassBackground(tint: tint, isInteractive: isInteractive, shape: shape))
    }

    func toastGlassButtonStyle(isProminent: Bool) -> some View {
        modifier(ToastGlassButtonModifier(isProminent: isProminent))
    }
}
