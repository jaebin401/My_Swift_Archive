//
//  ContentView.swift
//  FloatingPanelStudy
//
//  Created by Jaebin Ahn on 7/20/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isFloatingPanelPresented = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "macwindow.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Floating Panel Study")
                .font(.title)
                .fontWeight(.semibold)

            Text("Button을 누르면 SwiftUI content를 담은 NSPanel이 열립니다.")
                .foregroundStyle(.secondary)

            Button {
                isFloatingPanelPresented.toggle()
            } label: {
                Label("Show Floating Panel", systemImage: "rectangle.on.rectangle")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(minWidth: 420, minHeight: 280)
        .padding(32)
        .floatingPanel(
            isPresented: $isFloatingPanelPresented,
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 280)
        ) {
            FloatingPanelContentView(isPresented: $isFloatingPanelPresented)
        }
    }
}

#Preview {
    ContentView()
}
