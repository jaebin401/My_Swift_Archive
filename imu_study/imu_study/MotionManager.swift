import CoreMotion
import Combine

// ObservableObject: SwiftUI View가 이 클래스의 변화를 구독할 수 있게 해줌
class MotionManager: ObservableObject {
    
    // CoreMotion의 핵심 객체. 센서 시작/정지를 담당.
    private let motionManager = CMMotionManager()
    
    // @Published가 붙은 프로퍼티는 값이 바뀔 때마다 View에게 "다시 그려!" 신호를 보냄
    @Published var roll: Double = 0.0   // 좌우 기울기 (Y축 회전)
    @Published var pitch: Double = 0.0  // 앞뒤 기울기 (X축 회전)
    @Published var yaw: Double = 0.0    // 수평 회전 (Z축 회전)
    
    // 센서 업데이트 시작
    func start() {
        // 기기가 device motion을 지원하는지 확인 (시뮬레이터는 지원 안 함!)
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available. 실제 기기에서 실행하세요.")
            return
        }
        
        // 업데이트 주기: 1초에 60번 (60Hz)
        motionManager.deviceMotionUpdateInterval = 1.0 / 100.0
        
        // 센서 데이터를 받을 때마다 실행될 콜백 등록
        // to: .main → 메인 스레드에서 콜백 실행 (UI 업데이트 안전)
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            // self가 아직 살아있고, motion 데이터가 nil이 아닐 때만 진행
            guard let self = self, let motion = motion else { return }
            
            // motion.attitude: 기기의 현재 자세 정보 (라디안 단위)
            let attitude = motion.attitude
            
            // 라디안 → 도(degree) 변환 후 저장
            self.roll  = attitude.roll  * 180.0 / .pi
            self.pitch = attitude.pitch * 180.0 / .pi
            self.yaw   = attitude.yaw   * 180.0 / .pi
        }
    }
    
    // 센서 업데이트 정지 (배터리 절약을 위해 필수!)
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
