//
//  BrushingFrame.swift
//  classicClassifier (Shared)
//
//  Created by Jaebin Ahn on 6/10/26.
//

import Foundation

// MARK: - Watch → iPhone 전송 페이로드
// Watch: BrushingClassifier → WatchConnector.send()
// iPhone: PhoneConnector.didReceiveMessage → latestFrame
struct BrushingFrame: Codable {
    let zone: String          // "right" | "left" | "unclear"
    let rmsX: Double
    let rmsY: Double
    let timestamp: TimeInterval

    var dictionary: [String: Any] {
        ["zone": zone, "rmsX": rmsX, "rmsY": rmsY, "timestamp": timestamp]
    }
}
