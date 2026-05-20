import SwiftUI

struct ContentView: View {
    
    // @StateObject: 이 View가 MotionManager를 소유하고 생명주기를 관리함
    // View가 처음 생성될 때 한 번만 만들어지고, 이후 재사용됨
    @StateObject private var motion = MotionManager()
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Motion Sensor Test")
                .font(.title)
                .bold()
            
            // 숫자 값 표시
            VStack(alignment: .leading, spacing: 10) {
                Text(String(format: "Roll:  %+7.2f°", motion.roll))
                Text(String(format: "Pitch: %+7.2f°", motion.pitch))
                Text(String(format: "Yaw:   %+7.2f°", motion.yaw))
            }
            .font(.system(.title3, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
            
            Text("기기를 천천히 기울여 보세요")
                .font(.caption)
                .foregroundStyle(.secondary)
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
