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
        
        // isFloatingPresented를 .task() 내부로 넣고 FloatingPanelModifier에 인자로 바로 전달해서 바로 실행하면 안되나?
        // 굳이 이 커스텀 메서드를 거쳐야 하는 이유가 궁금하다
        // 답변: `.task()`는 비동기 작업을 실행하는 용도라서 패널의 생성/표시/닫힘을 View 생명주기에 붙여 관리하기엔 맞지 않음. 여기서는 커스텀 modifier가 `onAppear`, `onDisappear`, `onChange`를 묶어서 SwiftUI 상태 변화에 맞게 NSPanel을 관리함.
        // 답변: `.floatingPanel(...)`은 직접 FloatingPanelModifier를 쓰는 코드를 감싼 편의 메서드. 그래서 ContentView에서는 패널을 띄운다는 의도만 짧게 표현하고, 실제 NSPanel 연결 로직은 modifier 안에 숨겨둔 것임.
        .floatingPanel(
            isPresented: $isFloatingPanelPresented,
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 280)
        ) {
            FloatingPanelView(isPresented: $isFloatingPanelPresented)
        }
    }
}

#Preview {
    ContentView()
}
