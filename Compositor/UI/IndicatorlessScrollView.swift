import AppKit
import SwiftUI

/// The tool rail scrolls when it overflows without showing or reserving space
/// for a macOS scroller, even when the system setting always shows scroll bars.
struct IndicatorlessScrollView<Content: View>: NSViewRepresentable {
    @ViewBuilder let content: () -> Content

    func makeNSView(context: Context) -> IndicatorlessScrollContainer {
        IndicatorlessScrollContainer(rootView: AnyView(content()))
    }

    func updateNSView(_ view: IndicatorlessScrollContainer, context: Context) {
        view.host.rootView = AnyView(content())
        view.host.invalidateIntrinsicContentSize()
        view.updateDocumentSize()
    }
}

// File scope rather than nested in the generic representable: the deallocator of a class
// nested in a generic type crashes the Swift 6.3 compiler (EarlyPerfInliner) when the
// deployment target is below macOS 26. AnyView for the same reason.
final class IndicatorlessScrollContainer: NSScrollView {
    let host: NSHostingView<AnyView>

    init(rootView: AnyView) {
        host = NSHostingView(rootView: rootView)
        super.init(frame: .zero)
        drawsBackground = false
        borderType = .noBorder
        hasVerticalScroller = false
        hasHorizontalScroller = false
        horizontalScrollElasticity = .none
        documentView = host
        updateDocumentSize()
    }

    required init?(coder: NSCoder) { nil }

    override func layout() {
        super.layout()
        updateDocumentSize()
    }

    func updateDocumentSize() {
        let height = host.fittingSize.height
        let size = NSSize(width: 56, height: height)
        if host.frame.size != size { host.setFrameSize(size) }
        verticalScrollElasticity = height > contentView.bounds.height + 1 ? .allowed : .none
    }
}
