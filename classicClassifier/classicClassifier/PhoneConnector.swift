//
//  PhoneConnector.swift
//  classicClassifier
//
//  Created by Jaebin Ahn on 6/10/26.
//

import Foundation
import WatchConnectivity

// MARK: - PhoneConnector
// 역할: WCSession 양방향 관리
//   iPhone → Watch: "startCalibration" command 송신
//   Watch → iPhone: BrushingFrame 수신 (분류 결과)
//   Watch → iPhone: CalibrationStatus 수신 (calibration 상태)
@Observable
final class PhoneConnector: NSObject {

    static let shared = PhoneConnector()

    var latestFrame: BrushingFrame? = nil
    var isReachable: Bool = false
    var calibrationStatus: CalibrationStatus = .idle

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Calibration 시작 command 송신
    func sendStartCalibration() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["command": "startCalibration"],
                                      replyHandler: nil) { error in
            print("PhoneConnector sendCommand error: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate
extension PhoneConnector: WCSessionDelegate {

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
        DispatchQueue.main.async { [weak self] in
            self?.isReachable = session.isReachable
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isReachable = session.isReachable
        }
    }

    // MARK: - Watch → iPhone 수신
    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "brushingFrame":
            guard
                let zone      = message["zone"]      as? String,
                let rmsX      = message["rmsX"]      as? Double,
                let rmsY      = message["rmsY"]      as? Double,
                let timestamp = message["timestamp"] as? TimeInterval
            else { return }
            let frame = BrushingFrame(zone: zone, rmsX: rmsX, rmsY: rmsY, timestamp: timestamp)
            DispatchQueue.main.async { [weak self] in
                self?.latestFrame = frame
            }

        case "calibrationStatus":
            guard
                let rawStatus = message["status"] as? String,
                let status    = CalibrationStatus(rawValue: rawStatus)
            else { return }
            DispatchQueue.main.async { [weak self] in
                self?.calibrationStatus = status
            }

        default:
            break
        }
    }
}
