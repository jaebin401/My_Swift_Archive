//
//  CalibrationModel.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import CoreMotion
import Foundation
import WatchKit

// MARK: - Calibration 상태
enum CalibrationState: Equatable {
    case idle
    case calibrating(progress: Double)
    case calibrated
    case failed(reason: String)
}

// MARK: - Calibration 상태머신
@Observable
final class CalibrationModel {

    // MARK: - 공개 상태
    var state: CalibrationState = .idle
    var referenceFrame: ReferenceFrame? = nil

    // MARK: - 설정값
    private let windowDuration: Double = 3.0
    private let varianceThreshold: Double = 0.01

    // MARK: - 내부 상태
    private let stream = MotionStream()
    private var buffer: [MotionSample] = []
    private var targetCount: Int {
        Int(windowDuration * MotionStream.sampleRate)
    }

    // MARK: - Extended Runtime Session (화면 상시 켜짐)
    private var extendedSession: WKExtendedRuntimeSession?

    // MARK: - Calibration 시작
    func start() {
        guard case .idle = state else { return }
        buffer.removeAll()
        state = .calibrating(progress: 0.0)

        startExtendedSession()
        WatchConnector.shared.sendCalibrationStatus(.calibrating)

        stream.onSample = { [weak self] sample in
            self?.receive(sample)
        }
        stream.start()
    }

    // MARK: - 재시도
    func retry() {
        stream.stop()
        invalidateExtendedSession()
        buffer.removeAll()
        referenceFrame = nil
        state = .idle
        WatchConnector.shared.sendCalibrationStatus(.idle)
    }

    // MARK: - 샘플 수신 (백그라운드 스레드)
    private func receive(_ sample: MotionSample) {
        buffer.append(sample)
        let progress = min(Double(buffer.count) / Double(targetCount), 1.0)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.buffer.count < self.targetCount {
                self.state = .calibrating(progress: progress)
                return
            }
            self.stream.stop()
            self.finalize()
        }
    }

    // MARK: - 안정성 검증 + R_cal 저장 (Gram-Schmidt Z축 고정)
    private func finalize() {
        let samples = buffer
        let magnitudes = samples.map { sample in
            sqrt(sample.accelX * sample.accelX
               + sample.accelY * sample.accelY
               + sample.accelZ * sample.accelZ)
        }
        let mean     = magnitudes.reduce(0, +) / Double(magnitudes.count)
        let variance = magnitudes.map { ($0 - mean) * ($0 - mean) }
                                 .reduce(0, +) / Double(magnitudes.count)

        if variance > varianceThreshold {
            invalidateExtendedSession()
            WatchConnector.shared.sendCalibrationStatus(.failed)
            state = .failed(reason: "움직임이 감지됐어요. 칫솔을 정지한 채 다시 시도해주세요.")
            return
        }

        guard let lastSample = samples.last else { return }

        // MARK: 4.1 Gram-Schmidt Z축 고정
        // calibration 순간 Watch -Y축의 world 방향을 기준 +Y 후보로 사용.
        // Z축은 world up (0,0,1)으로 강제 고정해 calibration 기울기 오차 제거.
        //
        // R_att의 2번째 column = Watch +Y in world = (m12, m22, m32)
        // Watch -Y in world = (-m12, -m22, -m32)
        let R           = lastSample.rotationMatrix
        let watchMinusY = SIMD3(-R.m12, -R.m22, -R.m32)   // 기준 +Y 후보

        // Step 1: Z축 고정 (world up)
        let zRef = SIMD3<Double>(0, 0, 1)

        // Step 2: Gram-Schmidt — watchMinusY에서 Z 성분 제거 후 정규화
        // yRef = normalize(watchMinusY - (watchMinusY · zRef) * zRef)
        let dot   = watchMinusY.x * zRef.x + watchMinusY.y * zRef.y + watchMinusY.z * zRef.z
        let yRaw  = SIMD3(watchMinusY.x - dot * zRef.x,
                          watchMinusY.y - dot * zRef.y,
                          watchMinusY.z - dot * zRef.z)
        let yNorm = sqrt(yRaw.x*yRaw.x + yRaw.y*yRaw.y + yRaw.z*yRaw.z)

        guard yNorm > 1e-6 else {
            // watchMinusY가 Z축과 평행 — 칫솔이 하늘/땅을 향하는 자세
            invalidateExtendedSession()
            WatchConnector.shared.sendCalibrationStatus(.failed)
            state = .failed(reason: "자세를 확인해주세요. 칫솔이 하늘/땅을 향하고 있어요.")
            return
        }
        let yRef = SIMD3(yRaw.x / yNorm, yRaw.y / yNorm, yRaw.z / yNorm)

        // Step 3: xRef = yRef × zRef (오른손 법칙)
        let xRef = SIMD3(
            yRef.y * zRef.z - yRef.z * zRef.y,
            yRef.z * zRef.x - yRef.x * zRef.z,
            yRef.x * zRef.y - yRef.y * zRef.x
        )

        // Step 4: R_cal 재구성
        // 각 열(column)이 기준축의 world 방향
        // CMRotationMatrix row-major 표기 (mRC: R=행, C=열)
        // R_cal = [xRef | yRef | zRef]
        let rCal = CMRotationMatrix(
            m11: xRef.x, m12: yRef.x, m13: zRef.x,
            m21: xRef.y, m22: yRef.y, m23: zRef.y,
            m31: xRef.z, m32: yRef.z, m33: zRef.z
        )

        referenceFrame = ReferenceFrame(
            rCal:        rCal,
            capturedAt:  Date(),
            sampleCount: samples.count
        )

        WKInterfaceDevice.current().play(.success)
        WatchConnector.shared.sendCalibrationStatus(.calibrated)
        state = .calibrated
    }

    // MARK: - Extended Runtime Session 관리
    private func startExtendedSession() {
        guard extendedSession == nil else { return }
        let session = WKExtendedRuntimeSession()
        session.delegate = extendedSessionDelegate
        session.start()
        extendedSession = session
    }

    func invalidateExtendedSession() {
        extendedSession?.invalidate()
        extendedSession = nil
    }

    private var extendedSessionDelegate = ExtendedSessionDelegate()
}

// MARK: - WKExtendedRuntimeSessionDelegate
private final class ExtendedSessionDelegate: NSObject, WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("ExtendedRuntimeSession 시작됨")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("ExtendedRuntimeSession 만료 예정")
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: (any Error)?) {
        print("ExtendedRuntimeSession 무효화: \(reason)")
    }
}
