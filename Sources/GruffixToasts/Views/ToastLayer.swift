import SwiftUI

/// Lays out the visible toasts for the current style and placement. Owned by `ToastHostModifier`.
struct ToastLayer: View {
    let center: ToastCenter
    @State private var isDeckExpanded = false

    private var tuning: ToastTuning { center.tuning }
    private var style: ToastStyle { tuning.style.rendered }

    /// Newest toast sits closest to the screen edge.
    private var ordered: [Toast] {
        tuning.placement == .top ? center.visible.reversed() : center.visible
    }

    var body: some View {
        content
            .padding(.horizontal, ToastMetrics.scaled(12))
            .padding(Edge.Set(tuning.placement.edge), ToastMetrics.scaled(6))
            .animation(tuning.animation, value: center.visible.map(\.id))
            .animation(tuning.animation, value: isDeckExpanded)
            .sensoryFeedback(trigger: center.lastShown?.id) { _, _ in
                center.lastShown?.severity.feedback
            }
            .onChange(of: center.visible.count) { _, count in
                if count <= 1 { isDeckExpanded = false }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch style {
        case .glassCapsule:
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
                GlassEffectContainer(spacing: ToastMetrics.scaled(12)) { stack }
            } else {
                stack
            }
        case .banner, .snackbar:
            stack
        case .deck:
            deck
        }
    }

    private var stack: some View {
        VStack(spacing: ToastMetrics.scaled(8)) {
            ForEach(ordered) { toast in
                row(for: toast)
            }
        }
    }

    /// Collapsed, cards pile up behind the newest; expanded, they lay out as a list.
    private var deck: some View {
        let layout = isDeckExpanded
            ? AnyLayout(VStackLayout(spacing: ToastMetrics.scaled(8)))
            : AnyLayout(ZStackLayout(alignment: tuning.placement.alignment))
        return layout {
            ForEach(ordered) { toast in
                let depth = depth(of: toast)
                row(for: toast)
                    .scaleEffect(isDeckExpanded ? 1 : 1 - CGFloat(depth) * 0.05, anchor: tuning.placement.anchor)
                    .offset(y: isDeckExpanded ? 0 : deckPeek(depth))
                    .opacity(isDeckExpanded || depth < 3 ? 1 : 0)
                    .allowsHitTesting(isDeckExpanded || depth == 0)
                    .zIndex(Double(center.visible.count - depth))
            }
        }
        #if !os(tvOS)
        // tvOS has no focus to give a tap, so its deck stays collapsed.
        .contentShape(.rect)
        .onTapGesture {
            if center.visible.count > 1 { isDeckExpanded.toggle() }
        }
        #endif
    }

    private func row(for toast: Toast) -> some View {
        style.view(for: toast, showsClose: tuning.seconds(for: toast) == nil) {
            center.dismiss(toast.id)
        }
        .accessibilityElement(children: .combine)
        .accessibilityActions {
            if let action = toast.action {
                Button(action.label) {
                    action.perform()
                    center.dismiss(toast.id)
                }
            }
            Button("Dismiss") { center.dismiss(toast.id) }
        }
        .swipeToDismiss(toast.id)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: ToastFramesKey.self, value: [proxy.frame(in: .global)])
            }
        }
        .transition(style.transition(from: tuning.placement))
    }

    /// 0 for the newest toast, counting up toward the oldest.
    private func depth(of toast: Toast) -> Int {
        guard let index = center.visible.firstIndex(where: { $0.id == toast.id }) else { return 0 }
        return center.visible.count - 1 - index
    }

    /// Older cards peek out on the side away from the edge.
    private func deckPeek(_ depth: Int) -> CGFloat {
        let peek = CGFloat(min(depth, 2)) * ToastMetrics.scaled(10)
        return tuning.placement == .top ? peek : -peek
    }
}
