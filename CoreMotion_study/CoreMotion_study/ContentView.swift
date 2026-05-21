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
            ScrollView {
                VStack {
                    Text("CoreMotion Test")
                        .font(.title3)
                        .bold()
                    
                    // MARK: - Device Motion (fusion)
                    
                    NavigationLink("Attitude (Euler)") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Attitude (Euler)").bold()
                                Text(String(format: "R: %+2.2f°", motion.roll))
                                Text(String(format: "P: %+2.2f°", motion.pitch))
                                Text(String(format: "Y: %+2.2f°", motion.yaw))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Attitude (Quaternion)") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Quaternion").bold()
                                Text(String(format: "x: %+1.3f", motion.quatX))
                                Text(String(format: "y: %+1.3f", motion.quatY))
                                Text(String(format: "z: %+1.3f", motion.quatZ))
                                Text(String(format: "w: %+1.3f", motion.quatW))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("User Acceleration") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("User Acceleration (g)").bold()
                                Text(String(format: "X: %+2.3f", motion.userAccelX))
                                Text(String(format: "Y: %+2.3f", motion.userAccelY))
                                Text(String(format: "Z: %+2.3f", motion.userAccelZ))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Gravity") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Gravity (g)").bold()
                                Text(String(format: "X: %+2.3f", motion.gravityX))
                                Text(String(format: "Y: %+2.3f", motion.gravityY))
                                Text(String(format: "Z: %+2.3f", motion.gravityZ))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Rotation Rate") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Rotation Rate (rad/s)").bold()
                                Text(String(format: "X: %+2.3f", motion.rotRateX))
                                Text(String(format: "Y: %+2.3f", motion.rotRateY))
                                Text(String(format: "Z: %+2.3f", motion.rotRateZ))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Calibrated Magnetic") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Calibrated Mag (μT)").bold()
                                Text(String(format: "X: %+3.2f", motion.calMagX))
                                Text(String(format: "Y: %+3.2f", motion.calMagY))
                                Text(String(format: "Z: %+3.2f", motion.calMagZ))
                                Text("Accuracy: \(motion.magAccuracy)")
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Heading") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Heading").bold()
                                Text(String(format: "H: %+3.2f°", motion.heading))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.motionStart() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    // MARK: - Raw sensors
                    
                    NavigationLink("Raw Magnetometer") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Raw Magnetometer (μT)").bold()
                                Text(String(format: "X: %+3.2f", motion.magRoll))
                                Text(String(format: "Y: %+3.2f", motion.magPitch))
                                Text(String(format: "Z: %+3.2f", motion.magYaw))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.magnetic() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Raw Accelerometer") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Raw Accelerometer (g)").bold()
                                Text(String(format: "X: %+2.3f", motion.accelX))
                                Text(String(format: "Y: %+2.3f", motion.accelY))
                                Text(String(format: "Z: %+2.3f", motion.accelZ))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.acceleration() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                    
                    NavigationLink("Raw Gyroscope") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Raw Gyroscope (rad/s)").bold()
                                Text(String(format: "X: %+2.3f", motion.gyroX))
                                Text(String(format: "Y: %+2.3f", motion.gyroY))
                                Text(String(format: "Z: %+2.3f", motion.gyroZ))
                            }
                            .font(.system(.title3, design: .monospaced))
                        }
                        .onAppear  { motion.gyro() }
                        .onDisappear { motion.stop() }
                    }
                    .cardStyle()
                }
            }
        }
    }
}

// MARK: - 카드 스타일 헬퍼
private extension View {
    func cardStyle() -> some View {
        self
            .font(.system(.title3, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
