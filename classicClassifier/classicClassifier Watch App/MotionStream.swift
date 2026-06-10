//
//  MotionStream.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import CoreMotion
import Foundation

// MARK: - 센서 샘플
// userAcceleration: body frame 기준 선형 가속도 (중력 제거)
// rotationMatrix:  CMAttitude.rotationMatrix — R_att(t), body → world 변환용
struct MotionSample {
    let timestamp: TimeInterval
    let accelX, accelY, accelZ: Double       // userAcceleration (body frame)
    let rotationMatrix: CMRotationMatrix     // R_att(t)
}

// MARK: - CoreMotion 수집 레이어
// 역할: deviceMotion → MotionSample 변환 → onSample 콜백
// ML 추론 및 좌표 변환에 관여하지 않는 순수 센서 레이어
final class MotionStream {

    // ⚠️ Create ML 학습 설정의 "Sample Rate (Hz)" 값과 반드시 일치시킬 것
    static let sampleRate: Double = 50.0

    // 샘플 수신 콜백 — 백그라운드 스레드에서 호출됨
    var onSample: ((MotionSample) -> Void)?

    private let manager = CMMotionManager()
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.name = "classicclassifier.motionstream"
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .userInitiated
        return q
    }()

    func start() {
        guard manager.isDeviceMotionAvailable else {
            print("MotionStream: deviceMotion 미지원")
            return
        }
        guard !manager.isDeviceMotionActive else { return }   // 중복 시작 방지

        manager.deviceMotionUpdateInterval = 1.0 / MotionStream.sampleRate
        manager.startDeviceMotionUpdates(to: queue) { [weak self] data, error in
            guard let data, let self else { return }
            let sample = MotionSample(
                timestamp:      data.timestamp,
                accelX:         data.userAcceleration.x,
                accelY:         data.userAcceleration.y,
                accelZ:         data.userAcceleration.z,
                rotationMatrix: data.attitude.rotationMatrix
            )
            self.onSample?(sample)
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
