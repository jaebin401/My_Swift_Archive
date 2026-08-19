//
//  FloatingPanelExpandableLayout.swift
//  macOS_SideBar_study
//
//  Created by Jaebin Ahn on 7/21/26.
//

import SwiftUI

/// FloatingPanel 안에서 toolbar, sidebar, content 영역을 확장/축소 가능한 구조로 배치합니다.
public struct FloatingPanelExpandableLayout<Toolbar: View, Sidebar: View, Content: View>: View {
    @ViewBuilder var toolbar: () -> Toolbar
    @ViewBuilder var sidebar: () -> Sidebar
    @ViewBuilder var content: () -> Content

    /// sidebar가 축소 상태에서도 유지해야 하는 최소 너비입니다.
    var sidebarWidth: CGFloat = 256.0
    /// sidebar와 content를 함께 보여주기 위한 최소 전체 너비입니다.
    var totalWidth: CGFloat = 512.0
    /// panel content의 최소 높이입니다.
    var minHeight: CGFloat = 512.0

    /// 축소했다가 다시 펼칠 때 복원할 이전 확장 너비를 저장합니다.
    @State private var expandedWidth = 512.0

    /// 이 view를 담고 있는 부모 NSPanel에 접근해서 frame을 직접 조정합니다.
    @Environment(\.floatingPanel) private var panel

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                VisualEffectView(material: .sidebar)

                VStack(spacing: 0) {
                    HStack {
                        toolbar()

                        Spacer()

                        Button(action: toggleExpand) {
                            Image(systemName: expanded(for: geometry.size.width) ? "menubar.rectangle" : "uiwindow.split.2x1")
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.secondary)
                        .help(expanded(for: geometry.size.width) ? "Collapse" : "Expand")
                    }
                    .padding(16)

                    Divider()

                    HStack(spacing: 0) {
                        VStack {
                            Spacer()

                            // 접힌 상태에서는 sidebar가 panel 전체 폭을 쓰고, 펼친 상태에서는 고정 폭만 사용합니다.
                            sidebar()
                                .frame(
                                    minWidth: sidebarWidth,
                                    maxWidth: expanded(for: geometry.size.width) ? sidebarWidth : totalWidth
                                )

                            Spacer()
                        }

                        if expanded(for: geometry.size.width) {
                            HStack(spacing: 0) {
                                Divider()

                                content()
                                    .frame(width: geometry.size.width - sidebarWidth)
                            }
                            .transition(.move(edge: .trailing))
                        }
                    }
                    .animation(.spring(), value: expanded(for: geometry.size.width))
                }
            }
        }
        .frame(minWidth: sidebarWidth, minHeight: minHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// 현재 panel 너비를 기준으로 축소/확장 상태를 토글합니다.
    private func toggleExpand() {
        guard let panel else {
            return
        }

        let frame = panel.frame
        let isExpanded = expanded(for: frame.width)

        if isExpanded {
            expandedWidth = frame.width
        }

        let newWidth = isExpanded ? sidebarWidth : max(expandedWidth, totalWidth)
        let newFrame = CGRect(
            x: frame.midX - newWidth / 2,
            y: frame.origin.y,
            width: newWidth,
            height: frame.height
        )

        panel.setFrame(newFrame, display: true, animate: true)
    }

    /// content 영역을 보여줄 만큼 충분히 넓은지 계산합니다.
    private func expanded(for width: CGFloat) -> Bool {
        width >= totalWidth
    }
}

#Preview {
    FloatingPanelExpandableLayout {
        Text("Toolbar")
    } sidebar: {
        Text("Sidebar")
    } content: {
        Text("Content")
    }
}
