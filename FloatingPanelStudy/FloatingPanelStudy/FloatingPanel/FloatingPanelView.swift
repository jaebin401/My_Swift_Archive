//
//  FloatingPanelContentView.swift
//  FloatingPanelStudy
//
//  Created by Jaebin Ahn on 7/20/26.
//

import SwiftUI

struct FloatingPanelView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Label("Floating Panel", systemImage: "rectangle.inset.filled")
                        .font(.headline)

                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderless)
                }

                Text("이 패널은 NSPanel을 SwiftUI에서 사용할 수 있도록 감싼 예제입니다.")
                    .foregroundStyle(.secondary)

//                Divider()
//
//                HStack(spacing: 12) {
//                    Label("Key window 가능", systemImage: "keyboard")
//                    Label("앱 위에 float", systemImage: "square.stack.3d.up")
//                }
//                .font(.callout)
//                .foregroundStyle(.secondary)

                //Spacer()
            }
            .padding(24)
        }
        .frame(minWidth: 420, minHeight: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    FloatingPanelView(isPresented: .constant(true)) // 여기에 들어가는 true가 binding으로 받을 isPresented인건 알겠다. 근데 .constant(true)는 뭐임?
    // 답변: Preview에서 임시로 쓰는 고정 Binding 값. 실제 상태를 바꾸는 @State 없이도 `isPresented`에 항상 true인 Binding을 넘겨서 미리보기를 띄우기 위한 것임.
}
