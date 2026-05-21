import CoreMotion
import Combine

class MotionManager: ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    // MARK: - Device Motion: Attitude (Euler angles, degrees)
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var yaw: Double = 0.0
    
    // MARK: - Device Motion: Attitude (Quaternion)
    // gimbal lock 없이 회전을 표현. (x, y, z, w)
    @Published var quatX: Double = 0.0
    @Published var quatY: Double = 0.0
    @Published var quatZ: Double = 0.0
    @Published var quatW: Double = 1.0
    
    // MARK: - Device Motion: User Acceleration (중력 제거된 사용자 가속도, g 단위)
    @Published var userAccelX: Double = 0.0
    @Published var userAccelY: Double = 0.0
    @Published var userAccelZ: Double = 0.0
    
    // MARK: - Device Motion: Gravity (중력 벡터만 분리, g 단위)
    @Published var gravityX: Double = 0.0
    @Published var gravityY: Double = 0.0
    @Published var gravityZ: Double = 0.0
    
    // MARK: - Device Motion: Rotation Rate (bias 제거된 각속도, rad/s)
    @Published var rotRateX: Double = 0.0
    @Published var rotRateY: Double = 0.0
    @Published var rotRateZ: Double = 0.0
    
    // MARK: - Device Motion: Calibrated Magnetic Field (μT)
    @Published var calMagX: Double = 0.0
    @Published var calMagY: Double = 0.0
    @Published var calMagZ: Double = 0.0
    @Published var magAccuracy: Int32 = 0     // CMMagneticFieldCalibrationAccuracy의 rawValue
    
    // MARK: - Device Motion: Heading (도 단위, -1이면 미지원)
    @Published var heading: Double = -1.0
    
    // MARK: - Raw Magnetometer (μT)
    // 결론적으로 무보정 raw 값. calibrated 자기장은 Device Motion 쪽이 더 유용.
    @Published var magRoll: Double = 0.0
    @Published var magPitch: Double = 0.0
    @Published var magYaw: Double = 0.0
    
    // MARK: - Raw Accelerometer (g 단위, 중력 포함)
    @Published var accelX: Double = 0.0
    @Published var accelY: Double = 0.0
    @Published var accelZ: Double = 0.0
    
    // MARK: - Raw Gyroscope (rad/s, bias 포함)
    @Published var gyroX: Double = 0.0
    @Published var gyroY: Double = 0.0
    @Published var gyroZ: Double = 0.0
    
    
    // MARK: - Device Motion 업데이트 시작
    func motionStart() {
        
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available. 실제 기기에서 실행하세요.")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.showsDeviceMovementDisplay = true   // heading/자기장 보정 UI 트리거 허용
        
        // 자기장 기반 reference frame 사용 → heading & calibrated magneticField 사용 가능
        motionManager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical,
            to: .main
        ) { [weak self] motion, error in
            
            guard let self = self, let motion = motion else { return }
            
            // Attitude (Euler)
            let attitude = motion.attitude
            self.roll  = attitude.roll  * 180.0 / .pi
            self.pitch = attitude.pitch * 180.0 / .pi
            self.yaw   = attitude.yaw   * 180.0 / .pi
            
            // Attitude (Quaternion)
            let q = attitude.quaternion
            self.quatX = q.x
            self.quatY = q.y
            self.quatZ = q.z
            self.quatW = q.w
            
            // User Acceleration (중력 제거)
            let ua = motion.userAcceleration
            self.userAccelX = ua.x
            self.userAccelY = ua.y
            self.userAccelZ = ua.z
            
            // Gravity (중력 벡터만)
            let g = motion.gravity
            self.gravityX = g.x
            self.gravityY = g.y
            self.gravityZ = g.z
            
            // Rotation Rate (bias 제거됨)
            let rr = motion.rotationRate
            self.rotRateX = rr.x
            self.rotRateY = rr.y
            self.rotRateZ = rr.z
            
            // Calibrated Magnetic Field
            let cmf = motion.magneticField
            self.calMagX = cmf.field.x
            self.calMagY = cmf.field.y
            self.calMagZ = cmf.field.z
            self.magAccuracy = cmf.accuracy.rawValue
            
            // Heading (iOS 11+)
            self.heading = motion.heading
        }
    }
    
    // MARK: - Raw Magnetometer
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
    
    // MARK: - Raw Accelerometer
    func acceleration() {
        
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] acceleration, error in
            
            guard let self = self, let accel = acceleration else { return }
            
            self.accelX = accel.acceleration.x
            self.accelY = accel.acceleration.y
            self.accelZ = accel.acceleration.z
        }
    }
    
    // MARK: - Raw Gyroscope
    func gyro() {
        
        guard motionManager.isGyroAvailable else {
            print("⚠️ Gyroscope not available")
            return
        }
        
        motionManager.gyroUpdateInterval = 1.0 / 60.0
        motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            let r = data.rotationRate
            self.gyroX = r.x
            self.gyroY = r.y
            self.gyroZ = r.z
        }
    }
    
    // MARK: - 정지
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopMagnetometerUpdates()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
}
