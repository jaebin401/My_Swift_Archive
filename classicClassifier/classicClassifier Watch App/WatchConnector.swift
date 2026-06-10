//
//  WatchConnector.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import Foundation
import WatchConnectivity

// MARK: - WatchConnector
// 역할: WCSession 양방향 관리
//   Watch → iPhone: BrushingFrame (분류 결과, 1Hz)
//   Watch → iPhone: CalibrationStatus (calibration 상태 역전송)
//   iPhone → Watch: "startCalibration" command 수신 → CalibrationModel.start()
// 싱글톤: WCSession은 앱 전체에서 delegate 하나만 가질 수 있음
@Observable
final class WatchConnector: NSObject {

    static let shared = WatchConnector()

    // iPhone 연결 상태 (UI 표시용)
    var isReachable: Bool = false

    // iPhone으로부터 startCalibration command 수신 시 호출되는 핸들러
    // CalibrationModel을 직접 참조하지 않고 콜백으로 분리 (순환 의존 방지)
    var onStartCalibrationCommand: (() -> Void)?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - BrushingFrame 전송 (분류 결과, 1Hz)
    func send(_ frame: BrushingFrame) {
        guard WCSession.default.isReachable else { return }
        var dict = frame.dictionary
        dict["type"] = "brushingFrame"
        WCSession.default.sendMessage(dict, replyHandler: nil) { error in
            print("WatchConnector send error: \(error.localizedDescription)")
        }
    }

    // MARK: - CalibrationStatus 역전송
    // iPhone이 Watch Calibration 상태를 알 수 있도록 전송
    func sendCalibrationStatus(_ status: CalibrationStatus) {
        guard WCSession.default.isReachable else { return }
        let dict: [String: Any] = [
            "type":    "calibrationStatus",
            "status":  status.rawValue,
            "message": status.message
        ]
        WCSession.default.sendMessage(dict, replyHandler: nil) { error in
            print("WatchConnector sendStatus error: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnector: WCSessionDelegate {

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
        DispatchQueue.main.async { [weak self] in
            self?.isReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isReachable = session.isReachable
        }
    }

    // MARK: - iPhone → Watch 수신
    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        guard let command = message["command"] as? String else { return }
        if command == "startCalibration" {
            DispatchQueue.main.async { [weak self] in
                self?.onStartCalibrationCommand?()
            }
        }
    }
}
