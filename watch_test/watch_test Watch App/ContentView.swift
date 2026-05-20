//
//  ContentView.swift
//  watch_test Watch App
//
//  Created by Jaebin Ahn on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    
    
    @StateObject private var motion = MotionManager()
    
    var text1: String = "문장1"
    var text2: String = "문장2"
    
    var body: some View {
        VStack(spacing: 30) {
                    
            Text("Motion Test")
                //.font(.title)
                //.bold()
            
            // 숫자 값 표시
            VStack(alignment: .leading, spacing: 10) {
//                Text(String(format: "R: %+2.2f°", motion.roll))
//                Text(String(format: "P: %+2.2f°", motion.pitch))
//                Text(String(format: "Y: %+2.2f°", motion.yaw))
                
                Text(String(format: "R: %+2.2f°", motion.roll))
                Text(String(format: "P: %+2.2f°", motion.pitch))
                Text(String(format: "Y: %+2.2f°", motion.yaw))
                
            }
            .font(.system(.title3, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            
            
        }
        .padding()
        // View가 화면에 나타날 때 센서 시작
        .onAppear {
            motion.start()
        }
        // View가 사라질 때 센서 정지
        .onDisappear {
            motion.stop()
        }
    }
}

#Preview {
    ContentView()
}
