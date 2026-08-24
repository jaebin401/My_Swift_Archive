//
//  FloatingPanel.swift
//  FloatingPanelStudy
//
//  Created by Jaebin Ahn on 7/20/26.
//
// 이 코드의 전체적인 목적과 기능이 알고싶다
// 답변: SwiftUI 뷰를 macOS의 떠있는 패널(NSPanel) 안에 넣어 보여주는 코드. 패널 위치 제한, 화면 가장자리 스냅, 닫힘 상태 동기화까지 담당함.

import SwiftUI

/// An `NSPanel` subclass that behaves like a floating SwiftUI panel.
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

        // 이건 무슨말이여
        // 답변: 부모 클래스인 NSPanel을 실제로 초기화하는 부분. 패널 크기, 창 스타일, 화면 버퍼 방식 등을 넘겨서 macOS 창 객체를 만드는 단계임.
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

        isFloatingPanel = true
        level = .screenSaver
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
