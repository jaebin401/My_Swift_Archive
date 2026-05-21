//
//  ContentView.swift
//  watch_test Watch App
//
//  Created by Jaebin Ahn on 5/19/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var motion = MotionManager()
    
    var body: some View {
        
        NavigationStack {
            ScrollView{
                VStack {
                    Text("CoreMotion Test")
                        .font(.title3)
                        .bold()
                    
                    NavigationLink("Magnetic"){
                        Text("Magnetic")
                            .bold()
                        VStack(alignment: .leading, spacing: 10)
                        {
                            Text(String(format: "R: %+2.2f°", motion.magRoll))
                            Text(String(format: "P: %+2.2f°", motion.magPitch))
                            Text(String(format: "Y: %+2.2f°", motion.magYaw))
                        }.onAppear {
                            motion.magnetic()
                        }
                        .onDisappear {
                            motion.stop()
                        }
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    
                    NavigationLink("Accelerometer"){
                        Text("Accelerometer")
                        VStack(alignment: .leading, spacing: 10)
                        {
                            Text(String(format: "R: %+2.2f°", motion.roll))
                            Text(String(format: "P: %+2.2f°", motion.pitch))
                            Text(String(format: "Y: %+2.2f°", motion.yaw))
                        }.onAppear {
                            motion.motionStart()
                        }
                        .onDisappear {
                            motion.stop()
                        }
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    
                    
                    NavigationLink("Accel"){
                        Text("Accelerometer")
                            .bold()
                        VStack(alignment: .leading, spacing: 10)
                        {
                            Text(String(format: "X: %+2.2f°", motion.accelX))
                            Text(String(format: "Y: %+2.2f°", motion.accelY))
                            Text(String(format: "Z: %+2.2f°", motion.accelZ))
                        }.onAppear {
                            motion.acceleration()
                        }
                        .onDisappear {
                            motion.stop()
                        }
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            .padding()
            // View가 화면에 나타날 때 센서 시작
            
        }
    }
}

#Preview {
    ContentView()
}
