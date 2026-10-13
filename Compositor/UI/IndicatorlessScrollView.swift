import AppKit
import SwiftUI

/// The tool rail scrolls when it overflows without showing or reserving space
/// for a macOS scroller, even when the system setting always shows scroll bars.
struct IndicatorlessScrollView<Content: View>: NSViewRepresentable {
    @ViewBuilder let content: () -> Content

    func makeNSView(context: Context) -> Container {
        Container(rootView: AnyView(content()))
    }

    func updateNSView(_ view: Container, context: Context) {
        view.host.rootView = AnyView(content())
        view.host.invalidateIntrinsicContentSize()
        view.updateDocumentSize()
    }

    // AnyView rather than NSHostingView<Content>: the generic deallocator crashes the
    // Swift 6.3 compiler (EarlyPerfInliner) when the deployment target is below macOS 26.
    final class Container: NSScrollView {
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
}
