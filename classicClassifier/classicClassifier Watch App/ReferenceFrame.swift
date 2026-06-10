//
//  ReferenceFrame.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import CoreMotion
import Foundation

// MARK: - Calibration 결과값 타입
// R_cal: calibration 순간 저장한 rotation matrix
// 이후 런타임에서 R_cal^T · R_att(t) · a_body(t) 계산에 사용
struct ReferenceFrame {
    let rCal: CMRotationMatrix   // calibration 순간의 R_att — 세션 내내 고정
    let capturedAt: Date
    let sampleCount: Int         // calibration에 사용된 안정 샘플 수
}

// MARK: - CMRotationMatrix 헬퍼
// CMRotationMatrix는 Swift struct이므로 연산 메서드를 extension으로 추가
extension CMRotationMatrix {

    // 전치행렬 (transpose) = 회전행렬의 역행렬
    var transposed: CMRotationMatrix {
        CMRotationMatrix(
            m11: m11, m12: m21, m13: m31,
            m21: m12, m22: m22, m23: m32,
            m31: m13, m32: m23, m33: m33
        )
    }

    // 행렬 × 3D 벡터 곱
    // 용도: R_att(t) · a_body(t) → a_world(t)
    //       R_cal^T  · a_world(t) → a_ref(t)
    func applying(to v: SIMD3<Double>) -> SIMD3<Double> {
        SIMD3(
            x: m11 * v.x + m12 * v.y + m13 * v.z,
            y: m21 * v.x + m22 * v.y + m23 * v.z,
            z: m31 * v.x + m32 * v.y + m33 * v.z
        )
    }

    // 행렬 × 행렬 곱 (합성 변환용)
    static func * (lhs: CMRotationMatrix, rhs: CMRotationMatrix) -> CMRotationMatrix {
        CMRotationMatrix(
            m11: lhs.m11*rhs.m11 + lhs.m12*rhs.m21 + lhs.m13*rhs.m31,
            m12: lhs.m11*rhs.m12 + lhs.m12*rhs.m22 + lhs.m13*rhs.m32,
            m13: lhs.m11*rhs.m13 + lhs.m12*rhs.m23 + lhs.m13*rhs.m33,
            m21: lhs.m21*rhs.m11 + lhs.m22*rhs.m21 + lhs.m23*rhs.m31,
            m22: lhs.m21*rhs.m12 + lhs.m22*rhs.m22 + lhs.m23*rhs.m32,
            m23: lhs.m21*rhs.m13 + lhs.m22*rhs.m23 + lhs.m23*rhs.m33,
            m31: lhs.m31*rhs.m11 + lhs.m32*rhs.m21 + lhs.m33*rhs.m31,
            m32: lhs.m31*rhs.m12 + lhs.m32*rhs.m22 + lhs.m33*rhs.m32,
            m33: lhs.m31*rhs.m13 + lhs.m32*rhs.m23 + lhs.m33*rhs.m33
        )
    }
}
