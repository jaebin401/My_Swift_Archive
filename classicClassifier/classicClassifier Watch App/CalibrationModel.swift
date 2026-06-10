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

    // MARK: - 안정성 검증 + R_cal 저장
    private func finalize() {
        let samples = buffer
        let magnitudes = samples.map { sample in
            sqrt(sample.accelX * sample.accelX
               + sample.accelY * sample.accelY
               + sample.accelZ * sample.accelZ)
        }
        let mean = magnitudes.reduce(0, +) / Double(magnitudes.count)
        let variance = magnitudes.map { ($0 - mean) * ($0 - mean) }
                                 .reduce(0, +) / Double(magnitudes.count)

        if variance > varianceThreshold {
            invalidateExtendedSession()
            WatchConnector.shared.sendCalibrationStatus(.failed)
            state = .failed(reason: "움직임이 감지됐어요. 칫솔을 정지한 채 다시 시도해주세요.")
            return
        }

        guard let lastSample = samples.last else { return }
        referenceFrame = ReferenceFrame(
            rCal:        lastSample.rotationMatrix,
            capturedAt:  Date(),
            sampleCount: samples.count
        )

        WKInterfaceDevice.current().play(.success)
        WatchConnector.shared.sendCalibrationStatus(.calibrated)
        state = .calibrated
        // ExtendedRuntimeSession은 분류 세션이 끝날 때까지 유지
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

    // delegate를 별도 객체로 분리 (CalibrationModel이 NSObject 상속 불필요)
    private lazy var extendedSessionDelegate = ExtendedSessionDelegate()
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
