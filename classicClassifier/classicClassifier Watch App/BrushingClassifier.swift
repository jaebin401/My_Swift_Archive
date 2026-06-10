//
//  BrushingClassifier.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import CoreMotion
import Foundation

// MARK: - 분류 결과
// rawValue: WatchConnectivity 전송 시 String으로 직렬화
enum BrushingZone: String {
    case right   = "right"    // 우측 이빨 (기준 좌표계 X축 방향 운동 우세)
    case left    = "left"     // 좌측 이빨 (기준 좌표계 Y축 방향 운동 우세)
    case unclear = "unclear"  // RMS 차이가 너무 작아 판정 불가
}

// MARK: - 런타임 분류기
// 역할: ReferenceFrame을 받아 실시간 샘플을 a_ref로 변환,
//       window 단위 RMS 비교로 BrushingZone 판정 후 iPhone으로 전송
// 파이프라인: a_ref(t) = R_cal^T · R_att(t) · a_body(t)
@Observable
final class BrushingClassifier {

    // MARK: - 공개 상태
    var currentZone: BrushingZone = .unclear
    var rmsX: Double = 0.0   // 디버그용 실시간 RMS 수치
    var rmsY: Double = 0.0

    // MARK: - 설정값
    // window 크기: 50샘플 = 1초 @50Hz → 판정 주기 1Hz
    private let windowSize: Int = 50
    // RMS 차이가 이 값 미만이면 .unclear 판정
    // 단위: g, 실험으로 조정 필요
    private let unclearThreshold: Double = 0.05

    // MARK: - 내부 상태
    private let stream = MotionStream()
    private var buffer: [SIMD3<Double>] = []   // a_ref 누적 buffer
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
        // Step 1: body → world
        // a_world = R_att(t) · a_body
        let aBody  = SIMD3(sample.accelX, sample.accelY, sample.accelZ)
        let aWorld = sample.rotationMatrix.applying(to: aBody)

        // Step 2: world → 기준 좌표계 A
        // a_ref = R_cal^T · a_world
        let aRef = referenceFrame.rCal.transposed.applying(to: aWorld)

        buffer.append(aRef)

        // window가 꽉 차면 판정 후 buffer 초기화 (텀블링 window, 1Hz)
        guard buffer.count >= windowSize else { return }
        let window = buffer
        buffer.removeAll()
        classify(window: window)
    }

    // MARK: - RMS 계산 및 판정
    private func classify(window: [SIMD3<Double>]) {
        let rmsXVal = rms(window.map { $0.x })
        let rmsYVal = rms(window.map { $0.y })

        let zone: BrushingZone
        if abs(rmsXVal - rmsYVal) < unclearThreshold {
            zone = .unclear
        } else if rmsXVal > rmsYVal {
            zone = .right
        } else {
            zone = .left
        }

        // iPhone으로 전송 (1Hz — window 완료마다 1회)
        let frame = BrushingFrame(
            zone:      zone.rawValue,
            rmsX:      rmsXVal,
            rmsY:      rmsYVal,
            timestamp: Date().timeIntervalSince1970
        )
        WatchConnector.shared.send(frame)

        DispatchQueue.main.async { [weak self] in
            self?.rmsX = rmsXVal
            self?.rmsY = rmsYVal
            self?.currentZone = zone
        }
    }

    // MARK: - RMS 헬퍼
    // RMS = sqrt( Σ(x²) / N )
    private func rms(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sumOfSquares = values.reduce(0.0) { $0 + $1 * $1 }
        return sqrt(sumOfSquares / Double(values.count))
    }
}
