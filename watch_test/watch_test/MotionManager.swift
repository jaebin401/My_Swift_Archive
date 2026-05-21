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
    
    @Published var accelX: Double = 0.0
    @Published var accelY: Double = 0.0
    @Published var accelZ: Double = 0.0
    
    // 센서 업데이트 시작
    func motionStart() {
        
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available. 실제 기기에서 실행하세요.")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            
            guard let self = self, let motion = motion else { return }

            let attitude = motion.attitude
            
            self.roll  = attitude.roll  * 180.0 / .pi
            self.pitch = attitude.pitch * 180.0 / .pi
            self.yaw   = attitude.yaw   * 180.0 / .pi
        }

    }
    
    func magnetic() {
        
        guard motionManager.isMagnetometerAvailable else { return }
        
        motionManager.magnetometerUpdateInterval = 1.0 / 60.0
        motionManager.startMagnetometerUpdates(to: .main) { [weak self] data, error in
            guard let self, let data else { return }
            
            let f = data.magneticField       // CMMagneticField (μT 단위)
            self.magRoll  = f.x
            self.magPitch = f.y
            self.magYaw   = f.z
        }
    }
    
    func acceleration() {
        
        guard motionManager.isAccelerometerAvailable else {
               print("⚠️ Accelerometer not available")
               return
           }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] acceleration, error in
            
            guard let self = self, let accel = acceleration else { return }
            
            let x = accel.acceleration.x
            let y = accel.acceleration.y
            let z = accel.acceleration.z
            
            self.accelX = x
            self.accelY = y
            self.accelZ = z
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopMagnetometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}
