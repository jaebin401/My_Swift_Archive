//
//  FloatingPanelModifier.swift
//  FloatingPanelStudy
//
//  Created by Jaebin Ahn on 7/20/26.
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
    /// Presents an `NSPanel` with SwiftUI content.
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
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}
