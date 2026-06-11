//
//  BrushingClassifier.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import CoreMotion
import Foundation

// MARK: - 분류 결과
enum BrushingZone: String {
    case right   = "right"    // 우측 이빨 — Watch -Y가 기준 +Y 방향
    case left    = "left"     // 좌측 이빨 — Watch -Y가 기준 -X 방향
    case unclear = "unclear"  // 정지 중이거나 판정 불가
}

// MARK: - 런타임 분류기
// 판별 파이프라인:
//   1. accel magnitude RMS → 움직임 활성 감지
//   2. R_rel = R_cal^T · R_att(t) → Watch -Y축의 기준계 방향으로 좌/우 판별
//
// 기준 좌표계 정의 (calibration 자세 기준, Gram-Schmidt Z축 고정):
//   기준 +Y = Watch -Y (엄지/우측 이빨 방향)
//   기준 +X = Watch -Z (좌측 이빨 방향)
//   기준 +Z = world up (하늘, 고정)
//
// 판별 기준 (실제 테스트 기반):
//   우측 이빨: watchMinusYy ≈ +0.9  (임계값 > 0.6)
//   좌측 이빨: watchMinusYy ≈ +0.2~0.3  (임계값 < 0.4)
@Observable
final class BrushingClassifier {

    // MARK: - 공개 상태
    var currentZone: BrushingZone = .unclear
    var rmsAccel: Double = 0.0        // 디버그: accel magnitude RMS
    var watchMinusYx: Double = 0.0    // 디버그: watchMinusY_inRef.x
    var watchMinusYy: Double = 0.0    // 디버그: watchMinusY_inRef.y

    // MARK: - 설정값
    // window 크기: 50샘플 = 1초 @50Hz
    private let windowSize: Int = 50
    // accel magnitude RMS 임계값 — 미만이면 정지 판정
    // 단위: g, 실험으로 조정 필요
    private let accelActiveThreshold: Double = 0.05
    // watchMinusY_inRef.y 임계값 — 실제 테스트 기반
    // 우측: 0.9, 좌측: 0.2~0.3 → 명확하게 분리
    private let rightThreshold: Double = 0.85   // 이상이면 우측
    private let leftThreshold: Double = 0.8    // 미만이면 좌측

    // MARK: - 내부 상태
    private let stream = MotionStream()
    private var buffer: [(aRef: SIMD3<Double>, rRel: CMRotationMatrix)] = []
    private var referenceFrame: ReferenceFrame

    // MARK: - 초기화
    init(referenceFrame: ReferenceFrame) {
        self.referenceFrame = referenceFrame
    }

    // MARK: - 시작 / 정지
    func start() {
        buffer.removeAll()
        stream.onSample = { [weak self] sample in
            self?.receive(sample)
        }
        stream.start()
    }

    func stop() {
        stream.stop()
        buffer.removeAll()
    }

    // MARK: - 샘플 수신 (백그라운드 스레드)
    private func receive(_ sample: MotionSample) {
        let rCalT = referenceFrame.rCal.transposed

        // a_ref = R_cal^T · R_att(t) · a_body(t)
        let aBody  = SIMD3(sample.accelX, sample.accelY, sample.accelZ)
        let aWorld = sample.rotationMatrix.applying(to: aBody)
        let aRef   = rCalT.applying(to: aWorld)

        // R_rel = R_cal^T · R_att(t)
        let rRel = rCalT * sample.rotationMatrix

        buffer.append((aRef: aRef, rRel: rRel))

        guard buffer.count >= windowSize else { return }
        let window = buffer
        buffer.removeAll()
        classify(window: window)
    }

    // MARK: - 판정
    private func classify(window: [(aRef: SIMD3<Double>, rRel: CMRotationMatrix)]) {

        // Step 1: accel magnitude RMS — 움직임 활성 감지
        let magnitudes = window.map { entry in
            sqrt(entry.aRef.x * entry.aRef.x
               + entry.aRef.y * entry.aRef.y
               + entry.aRef.z * entry.aRef.z)
        }
        let accelRMS = rms(magnitudes)

        // Step 2: Watch -Y축의 기준계 방향 추출
        let lastRRel = window.last!.rRel
        let minusYx  = -lastRRel.m12   // watchMinusY_inRef.x
        let minusYy  = -lastRRel.m22   // watchMinusY_inRef.y

        // Step 3: 판정 (실제 테스트 데이터 기반)
        let zone: BrushingZone
        if accelRMS < accelActiveThreshold {
            // 정지 중
            zone = .unclear
        } else if minusYy > rightThreshold {
            // Watch -Y가 기준 +Y 방향 → 우측 이빨 (0.9 > 0.6)
            zone = .right
        } else if minusYy < leftThreshold {
            // Watch -Y가 기준 -X 방향(Y 성분 작음) → 좌측 이빨 (0.2~0.3 < 0.4)
            zone = .left
        } else {
            // 0.4 <= minusYy <= 0.6: 회색지대
            zone = .unclear
        }

        // iPhone으로 전송 (1Hz)
        let frame = BrushingFrame(
            zone:      zone.rawValue,
            rmsX:      accelRMS,
            rmsY:      minusYy,
            timestamp: Date().timeIntervalSince1970
        )
        WatchConnector.shared.send(frame)

        DispatchQueue.main.async { [weak self] in
            self?.rmsAccel     = accelRMS
            self?.watchMinusYx = minusYx
            self?.watchMinusYy = minusYy
            self?.currentZone  = zone
        }
    }

    // MARK: - RMS 헬퍼
    private func rms(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sumOfSquares = values.reduce(0.0) { $0 + $1 * $1 }
        return sqrt(sumOfSquares / Double(values.count))
    }
}
