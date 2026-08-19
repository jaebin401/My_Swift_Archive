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
    FloatingPanelView(isPresented: .constant(true))
}
