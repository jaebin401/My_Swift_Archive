//
//  navigationPage.swift
//  navigation_study
//
//  Created by Jaebin Ahn on 5/29/26.
//

import SwiftUI

struct navigationPage: View {
    
    // @Environment: 프로퍼티 wrapper,
    // 
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("Hello, World!")
        Button("뒤로 가기") {
            dismiss()
        }
        .padding(16)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    navigationPage()
}

