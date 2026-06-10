//
//  CalibrationStatus.swift
//  classicClassifier (Shared — iPhone 타겟용)
//
//  Created by Jaebin Ahn on 6/10/26.
//

import Foundation

// MARK: - Calibration 상태 (Watch → iPhone 역전송용)
enum CalibrationStatus: String {
    case idle        = "idle"
    case calibrating = "calibrating"
    case calibrated  = "calibrated"
    case failed      = "failed"

    var message: String {
        switch self {
        case .idle:        return "대기 중"
        case .calibrating: return "Calibration 진행 중..."
        case .calibrated:  return "Calibration 완료"
        case .failed:      return "실패 — 재시도 필요"
        }
    }
}
