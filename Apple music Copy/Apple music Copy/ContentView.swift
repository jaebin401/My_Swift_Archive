//
//  ContentView.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AlbumInfo()
            Four_buttons()
            PlayList()
            PausePlay()
                .padding(.bottom, 30)
            Volume()
                .padding(.bottom, 15)
            bottom()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
