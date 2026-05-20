//
//  Volume.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI

struct Volume: View {
    @State var volume: CGFloat = 0.0
    var body: some View {
        HStack{
            Spacer()
            Image(systemName: "speaker.fill")
            Slider(value: $volume, in: 0...100, step: 1)
            Image(systemName: "speaker.wave.3.fill")
            Spacer()
        }
    }
}

#Preview {
    Volume()
}
