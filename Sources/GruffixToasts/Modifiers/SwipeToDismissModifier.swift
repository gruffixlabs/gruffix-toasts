import SwiftUI

/// Drag a toast toward its edge, or sideways, to dismiss it. The timer pauses while dragging,
/// and dragging away from the edge is rubber-banded.
///
/// On watchOS a drag would fight scrolling, the Digital Crown and swipe-back navigation, so a
/// tap dismisses instead. tvOS has no drag gesture and its toasts always time out, so there's
/// nothing to add.
struct SwipeToDismissModifier: ViewModifier {
    let toastId: Toast.ID
    @Environment(\.toastCenter) private var center
    @State private var offset: CGSize = .zero
    @State private var isDragging = false

    func body(content: Content) -> some View {
        #if os(tvOS)
        content
        #elseif os(watchOS)
        content
            .onTapGesture { center.dismiss(toastId) }
        #else
        content
            .offset(offset)
            .gesture(drag)
        #endif
    }

    #if !os(tvOS) && !os(watchOS)
    private var drag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    center.pauseTimer(for: toastId)
                }
                offset = resisted(value.translation)
            }
            .onEnded { value in
                isDragging = false
                if isDismissal(value.translation) || isDismissal(value.predictedEndTranslation) {
                    center.dismiss(toastId)
                } else {
                    withAnimation(center.tuning.animation) { offset = .zero }
                    center.resumeTimer(for: toastId)
                }
            }
    }

    /// Positive when the vertical drag heads toward the toast's edge.
    private func towardEdge(_ translation: CGSize) -> CGFloat {
        center.tuning.placement == .top ? -translation.height : translation.height
    }

    private func resisted(_ translation: CGSize) -> CGSize {
        let isAwayFromEdge = towardEdge(translation) < 0
        return CGSize(width: translation.width, height: isAwayFromEdge ? translation.height * 0.2 : translation.height)
    }

    private func isDismissal(_ translation: CGSize) -> Bool {
        let threshold = center.tuning.swipeThreshold
        return towardEdge(translation) > threshold || abs(translation.width) > threshold * 2
    }
    #endif
}

extension View {
    func swipeToDismiss(_ toastId: Toast.ID) -> some View {
        modifier(SwipeToDismissModifier(toastId: toastId))
    }
}
