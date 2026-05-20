//
//  popup.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI

struct popup: View {
    var body: some View {
        ScrollView{
            Divider()
            Button("노래 고정", systemImage: "pin") {}
            Button("플레이리스트에 추가", systemImage: "text.badge.plus") {}
            Divider()
            Button("스테이션 생성", systemImage: "badge.plus.radiowaves.forward") {}
            Divider()
            Button {}
            label :{
                Image(systemName: "music.note.square.stack")
                VStack (alignment: .leading){
                    Text("앨범으로 이동")
                    Text("Endless Shine - Sinlge")
                        .font(.caption)
                }
            }
            Button {}
            label :{
                Image(systemName: "music.microphone")
                VStack (alignment: .leading){
                    Text("아티스트로 이동")
                    Text("Thuesday Beach Club")
                        .font(.caption)
                }
            }
            
            Button("크레딧 보기", systemImage: "info.circle") {}
            Button("가사 공유", systemImage: "square.and.arrow.up") {}
            Divider()
            Button("제안 줄이기", systemImage: "hand.thumbsdown") {}
            
        }
    }
}

#Preview {
    popup()
}
