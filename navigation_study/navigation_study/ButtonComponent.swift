//
//  ButtonComponent.swift
//  navigation_study
//
//  Created by Jaebin Ahn on 5/29/26.
//

// 이 코드는 단순히 NavigationLink 버튼 자체만을 담고있는 컴포넌트이다.
// 그러면 이 버튼을 클릭했을 때 이동하는 destination NavigationLink는 어디냐?
// -> 실제 이 컴포넌트가 사용될 부분에서 중괄호로 지정될 뷰에서 중괄호에 들어갈 부분이다
//      e.g
//      ButtonComponent(title: "버튼 이름") {
//           subPage() // 여기로 이동함
//      }

import SwiftUI

struct ButtonComponent<Destination: View>: View {
    
    let title: String
    @ViewBuilder let destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination()) {
            label
        }
        // .buttonStyle(.plain)
    }
    
    // MARK: - Subviews
    private var label: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.body)
                .foregroundStyle(.black)
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}

#Preview {
    NavigationStack {
        ButtonComponent(title: "버튼 클릭") {
            
        }
    }
}
