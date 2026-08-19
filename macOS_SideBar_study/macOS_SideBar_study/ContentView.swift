//
//  ContentView.swift
//  macOS_SideBar_study
//
//  Created by Jaebin Ahn on 7/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showingPanel = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "macwindow.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Expandable Floating Panel")
                .font(.title)
                .fontWeight(.semibold)

            Text("버튼을 누르면 sidebar와 content를 접고 펼칠 수 있는 NSPanel이 열립니다.")
                .foregroundStyle(.secondary)

            Button {
                showingPanel.toggle()
            } label: {
                Label("Present Panel", systemImage: "rectangle.on.rectangle")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(minWidth: 420, minHeight: 280)
        .padding(32)
        .floatingPanel(
            isPresented: $showingPanel,
            contentRect: CGRect(x: 0, y: 0, width: 624, height: 512)
        ) {
            FloatingPanelExpandableLayout {
                Label("Library", systemImage: "square.grid.2x2")
                    .font(.headline)
            } sidebar: {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Views", systemImage: "rectangle.3.group")
                    Label("Modifiers", systemImage: "slider.horizontal.3")
                    Label("Controls", systemImage: "switch.2")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            } content: {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Content")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("오른쪽 상단 버튼을 누르면 panel frame이 sidebar 너비로 줄어들고, 다시 누르면 이전 확장 너비로 복원됩니다.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(24)
            }
        }
    }
}

#Preview {
    ContentView()
}
