//
//  Four_buttons.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI
import Foundation

enum reapeatType {
    case repeated
    case repeatOne
    case nonrepeat
}

struct Four_buttons: View {
    @State var isShuffle: Bool = false
    @State var shuffleicon: String = "shuffle"
    @State var isRepeat: Bool = false
    @State var isInfinity: Bool = false
    
    var body: some View {
        HStack(){
            //Text("\(isShuffle)")
            // 셔플버튼
            Button() {
                isShuffle = isShuffle ? false : true // 삼항연산자 형태
                shuffleicon = isShuffle ? "shuffle.fill" : "shuffle"
            }
            label: {
                Image(systemName: "\(shuffleicon)")
                    .foregroundStyle(Color(.gray))
                    .font(.title3.bold())
                    .padding(10)
            }.buttonStyle(.bordered)
            Spacer()
            
            // 반복 버튼
            Button() {
                
            }
            label: {
                Image(systemName: "repeat")
                    .foregroundStyle(Color(.gray))
                    .font(.title3.bold())
                    .padding(10)
            }.buttonStyle(.bordered)
            
            Spacer()
            // 무한재생 버튼
            Button() {
               
            }
            label: {
                Image(systemName: "infinity")
                    .foregroundStyle(Color(.gray))
                    .font(.title3.bold())
                    .padding(10)
            }.buttonStyle(.bordered)
            
            Spacer()
            // ?
            Button() {
                
            }
            label: {
                Image(systemName: "arrow.2.circlepath.circle")
                    .foregroundStyle(Color(.gray))
                    .font(.title3.bold())
                    .padding(10)
            }.buttonStyle(.bordered)
        }
    }
}

#Preview {
    Four_buttons()
}
