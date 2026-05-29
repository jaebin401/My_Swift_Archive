//
//  ContentView2.swift
//  TabView study
//
//  Created by Jaebin Ahn on 5/28/26.
//

import SwiftUI

struct ContentView2: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView (selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                TipView()
                    .tabItem {
                        Label("Tip", systemImage: "stethoscope.circle.fill")
                    }
                    .tag(1)
                MyView()
                    .tabItem {
                        Label("My", systemImage: "person.fill")
                    }
                    .tag(2)
            }
        }
        
    }
}

#Preview {
    ContentView2()
}
