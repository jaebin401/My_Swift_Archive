// PhoneConnector.swift

import Foundation
import WatchConnectivity

final class PhoneConnector: NSObject, WCSessionDelegate {
    
    static let shared = PhoneConnector()
    
    private var lastSentTime: Date = .distantPast
    private let minInterval: TimeInterval = 0.01    // 10ms = 초당 100회
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func send(value: Double) {
        guard WCSession.default.activationState == .activated else { return }
        guard WCSession.default.isReachable else { return }
        
        // 🔑 throttling
        let now = Date()
        guard now.timeIntervalSince(lastSentTime) >= minInterval else { return }
        lastSentTime = now
        
        WCSession.default.sendMessage(["value": value],
                                      replyHandler: nil,
                                      errorHandler: nil)
    }

    
    // MARK: - WCSessionDelegate 필수 메서드 (iOS)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("iPhone session activated: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()      // 다른 watch로 전환 시 재활성화
    }
}
