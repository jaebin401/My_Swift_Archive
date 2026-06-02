// PhoneConnector.swift

import Foundation
import WatchConnectivity

// final class: 이 클래스는 더이상 상속할 수 없음을 명시 (no more child)
// NSObject라는 상위 클래스를 상속 받을 것임을 의미
// WCSessionDelegate는 상속받는 상위 클래스가 아니라, 프로토콜임
// Swfit에선 클래스의 상속은 하나만 받을 수 있다.
final class PhoneConnector: NSObject, WCSessionDelegate {
    
    // 싱글톤 패턴으로 선언한 인스턴스
    // PhoneConnector()라는 클래스의 인스턴스를 선언하는 것. 그러나 타입 그 자체로 만드는 것
    // 이 PhoneConnector() 인스턴스는 하나만 있어야 하기 때문에, static을 붙여 싱글톤 패턴으로 선언한것이다.
    static let shared = PhoneConnector()
    
    // 클래스 내부에서만 접근할 수 있는 private 변수
    // 사실 Date = Date.distantPast 라고 선언된건데, Swift의 특성으로 Date 중복 기입을 피할 수 있음
    // Date.distantPast: 아주 먼 과거의 시점으로 부터 현재까지 상대적인 시간
    // 극단적인 과거로 변수를 초기화 해두고, 첫 호출에서 무조건 쓰로틀링 검사를 통과 시키기는 것을 의도함
    private var lastSentTime: Date = .distantPast
    private let minInterval: TimeInterval = 0.01    // 10ms = 초당 100회
    
    // 생성자
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
        
        // throttling: 현재 시각과 마지막으로 데이터를 보낸 시점의 상대시간 interval 계산 후 minInterval 과 비교
        // 그래서 만약 minInterval 보다 크다면, 통과해서 데이터 보내기.
        // *throttling의 개념: 간헐적으로 이벤트가 들어오는 상황 가정, 쿨타임이 차서 이벤트 통과 가능한 시점에 들어온것만 통과 시키는 것
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
