//
//  ContentView.swift
//  SliderSync Watch App
//
//  Created by Jaebin Ahn on 5/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var connector = WatchConnector.shared
    
    var body: some View {
        Text(String(format: "%.2f", connector.value))
            .font(.system(size: 36, weight: .bold, design: .monospaced))
    }
}

#Preview {
    ContentView()
}
