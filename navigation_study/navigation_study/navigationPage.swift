//
//  navigationPage.swift
//  navigation_study
//
//  Created by Jaebin Ahn on 5/29/26.
//

import SwiftUI

struct navigationPage: View {
    
    // SwiftUI에서 View는 계층을 넘나들며 값을 전달하기 번거롭기 때문에
    // 위에서 아래 방향으로 흘러내려오는 공용 환경 저장소를 만들어 뒀고,
    // 하위 View들이 필요한 값을 꺼내 쓸 수 있게 한다.
    //
    // @Environment는 그 저장소에서 값을 꺼내오는 Property Wrapper이고,
    // (\.dismiss)는 꺼내올 값의 이름표다.
    //
    // private var dismiss: 꺼내온 값을 담는 변수.
    //   → 타입은 DismissAction (SwiftUI 내장 구조체).
    //   → dismiss() 처럼 함수처럼 호출하면 현재 View를 닫음(pop/sheet dismiss).
    //   → NavigationStack에서 push된 View라면 이전 화면으로 돌아가고,
    //     .sheet로 띄워진 View라면 모달이 닫힘.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("Hello, World!")
        Button("뒤로 가기") {
            dismiss()
        }
        .padding(16)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .navigationTitle("제목")    
        NavigationLink("hello") {
            navigationPageSub()
        }
    }
}

#Preview {
    navigationPage()
}

