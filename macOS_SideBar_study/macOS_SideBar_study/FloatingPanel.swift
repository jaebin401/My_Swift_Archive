//
//  FloatingPanel.swift
//  macOS_SideBar_study
//
//  Created by Jaebin Ahn on 7/21/26.
//

import SwiftUI

/// SwiftUI view를 담을 수 있는 macOS floating panel입니다.
final class FloatingPanel<Content: View>: NSPanel {
    @Binding private var isPresented: Bool

    private let edgeSnapDistance: CGFloat = 24

    init(
        view: () -> Content,
        contentRect: NSRect,
        backing: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = false,
        isPresented: Binding<Bool>
    ) {
        self._isPresented = isPresented

        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .resizable,
                .closable,
                .fullSizeContentView
            ],
            backing: backing,
            defer: flag
        )

        // 일반 window가 아니라 앱 위에 떠 있는 보조 panel처럼 동작하게 설정합니다.
        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        animationBehavior = .utilityWindow

        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        isOpaque = false
        backgroundColor = .clear

        // SwiftUI content를 AppKit window에 올리기 위해 NSHostingView로 감쌉니다.
        let hostingView = NSHostingView(
            rootView: view()
                .ignoresSafeArea()
                .environment(\.floatingPanel, self)
        )
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 16
        hostingView.layer?.masksToBounds = true

        contentView = hostingView
    }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        guard let screen else {
            return super.constrainFrameRect(frameRect, to: screen)
        }

        let visibleFrame = screen.visibleFrame
        var constrainedFrame = frameRect

        // 화면 밖으로 나가지 않게 제한하고, 가장자리 근처에서는 딱 붙도록 snap 처리합니다.
        constrainedFrame.origin.x = snappedOrigin(
            value: constrainedFrame.origin.x,
            minimum: visibleFrame.minX,
            maximum: visibleFrame.maxX - constrainedFrame.width
        )
        constrainedFrame.origin.y = snappedOrigin(
            value: constrainedFrame.origin.y,
            minimum: visibleFrame.minY,
            maximum: visibleFrame.maxY - constrainedFrame.height
        )

        return constrainedFrame
    }

    override func close() {
        super.close()
        isPresented = false
    }

    private func snappedOrigin(value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        guard minimum <= maximum else {
            return minimum
        }

        let clampedValue = min(max(value, minimum), maximum)

        if abs(clampedValue - minimum) <= edgeSnapDistance {
            return minimum
        }

        if abs(clampedValue - maximum) <= edgeSnapDistance {
            return maximum
        }

        return clampedValue
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
