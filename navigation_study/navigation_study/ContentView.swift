//
//  ContentView.swift
//  navigation_study
//
//  Created by Jaebin Ahn on 5/20/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("page 1") {
                    navigationPage()
                }
                .padding(16)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                
                NavigationLink("page 2") {
                    Text("this is page 2")
                }
                .padding(16)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    ContentView()
}
