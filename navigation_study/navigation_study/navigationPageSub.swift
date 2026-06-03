//
//  navigationPage.swift
//  navigation_study
//
//  Created by Jaebin Ahn on 5/29/26.
//


// ContentView -> navigationPage -> navigationPageSub 계층 구조로 됨
// 이 navigationPageSub에서 dismiss를 하면 그 이전인 navigationPage로 돌아감

import SwiftUI

struct navigationPageSub: View {
    
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
        
    }
}

#Preview {
    navigationPageSub()
}

