//
//  ButtonComponent.swift
//  navigation_study
//
//  Created by Jaebin Ahn on 5/29/26.
//

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
