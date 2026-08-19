//
//  FloatingPanelModifier.swift
//  macOS_SideBar_study
//
//  Created by Jaebin Ahn on 7/21/26.
//

import SwiftUI

struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    @Binding var isPresented: Bool

    let contentRect: CGRect
    @ViewBuilder let panelContent: () -> PanelContent

    @State private var panel: FloatingPanel<PanelContent>?

    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = FloatingPanel(
                    view: panelContent,
                    contentRect: contentRect,
                    isPresented: $isPresented
                )
                panel?.center()

                if isPresented {
                    present()
                }
            }
            .onDisappear {
                panel?.close()
                panel = nil
            }
            .onChange(of: isPresented) { _, value in
                if value {
                    present()
                } else {
                    panel?.close()
                }
            }
    }

    private func present() {
        panel?.orderFront(nil)
        panel?.makeKey()
    }
}

extension View {
    /// SwiftUI view에 floating panel 표시 기능을 modifier 형태로 붙입니다.
    func floatingPanel<Content: View>(
        isPresented: Binding<Bool>,
        contentRect: CGRect = CGRect(x: 0, y: 0, width: 624, height: 512),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            FloatingPanelModifier(
                isPresented: isPresented,
                contentRect: contentRect,
                panelContent: content
            )
        )
    }
}

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
    /// panel 내부 SwiftUI view가 자신을 담고 있는 NSPanel에 접근할 수 있게 해줍니다.
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}
