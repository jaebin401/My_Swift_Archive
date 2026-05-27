import Foundation
import WatchConnectivity

@Observable
final class WatchConnector: NSObject, WCSessionDelegate {
    
    static let shared = WatchConnector()
    
    var value: Double = 0.0      // ← SwiftUI가 관찰
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // MARK: - WCSessionDelegate 필수 메서드
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Watch session activated: \(activationState.rawValue)")
    }
    
    // MARK: - 수신
    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        guard let newValue = message["value"] as? Double else { return }
        
        DispatchQueue.main.async {           // UI 업데이트는 메인 스레드
            self.value = newValue
        }
    }
}
