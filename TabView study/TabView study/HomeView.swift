//
//  HomeView.swift
//  TabView study
//
//  Created by Jaebin Ahn on 5/28/26.
//

import SwiftUI

struct HomeView: View {
    
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack() {
            Text("Home")
            Button("to Tip") {selectedTab = 1}
        }
    }
}
