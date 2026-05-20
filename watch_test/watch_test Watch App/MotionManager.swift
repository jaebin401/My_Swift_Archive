import CoreMotion
import Combine

class MotionManager: ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    // megnet 센싱 시도 (그런데 결론적으론 안됨)
    @Published var magRoll: Double = 0.0
    @Published var magPitch: Double = 0.0
    @Published var magYaw: Double = 0.0
    
    // 센서 업데이트 시작
    func start() {
        
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available. 실제 기기에서 실행하세요.")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            
            guard let self = self, let motion = motion else { return }

            let attitude = motion.attitude
            let magnet = motion.magneticField
            
            self.roll  = attitude.roll  * 180.0 / .pi
            self.pitch = attitude.pitch * 180.0 / .pi
            self.yaw   = attitude.yaw   * 180.0 / .pi
            
            self.magRoll = magnet.field.x
            self.magPitch = magnet.field.y
            self.magYaw = magnet.field.z
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
