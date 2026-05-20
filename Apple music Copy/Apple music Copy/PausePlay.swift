//
//  PausePlay.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI

struct PausePlay: View {
    @State var isPlaying: Bool = true
    @State var playicon: String = "play.fill"
    var body: some View {
        HStack{
            Spacer()
            // 이전 곡
            Button {
                
            } label: {
                Image(systemName: "backward.fill")
            }.font(.largeTitle)
                .bold()
                .foregroundStyle(Color.black)
            Spacer()
            // 재생, 정지
            Button {
                isPlaying.toggle()
                playicon = isPlaying ? "play.fill" : "pause.fill"
            } label: {
                Image(systemName: playicon)
            }.font(.largeTitle)
                .bold()
                .foregroundStyle(Color.black)
            Spacer()
            
            // 다음 곡
            Button {
                
            } label: {
                Image(systemName: "forward.fill")
            }.font(.largeTitle)
                .bold()
                .foregroundStyle(Color.black)
            Spacer()
        }
    }
}

#Preview {
    PausePlay()
}
