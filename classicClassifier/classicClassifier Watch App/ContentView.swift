//
//  ContentView.swift
//  classicClassifier Watch App
//
//  Created by Jaebin Ahn on 6/10/26.
//

import CoreMotion
import SwiftUI

struct ContentView: View {
    @State private var model = CalibrationModel()

    var body: some View {
        switch model.state {
        case .idle:
            IdleView(model: model)
        case .calibrating(let progress):
            CalibratingView(progress: progress)
        case .calibrated:
            CalibratedView(model: model)
        case .failed(let reason):
            FailedView(reason: reason, model: model)
        }
    }
    // iPhone → Watch command 수신 핸들러 등록
    // navigationRoot에서 한 번만 등록 (타이밍 문제 방지)
    .onAppear {
        WatchConnector.shared.onStartCalibrationCommand = { [weak model] in
            model?.retry()   // idle 상태로 초기화 후
            model?.start()   // 바로 시작
        }
    }
}

// MARK: - Idle
private struct IdleView: View {
    let model: CalibrationModel

    var body: some View {
        VStack(spacing: 12) {
            Text("칫솔을\n우측 이빨 방향으로\n향하게 하세요")
                .font(.footnote)
                .multilineTextAlignment(.center)

            Button("Calibration 시작") {
                model.start()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Calibrating
private struct CalibratingView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: progress)
                .progressViewStyle(.circular)

            Text("정지 상태 유지 중...")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("\(Int(progress * 100))%")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.medium)
        }
        .padding()
    }
}

// MARK: - Calibrated
private struct CalibratedView: View {
    let model: CalibrationModel
    @State private var classifier: BrushingClassifier?

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {

                if let classifier {
                    ZoneIndicator(zone: classifier.currentZone)
                }

                if let classifier {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RMS (1초 window)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(String(format: "x (우측): %.4f g", classifier.rmsX))
                            .font(.system(.caption, design: .monospaced))
                        Text(String(format: "y (좌측): %.4f g", classifier.rmsY))
                            .font(.system(.caption, design: .monospaced))
                    }
                    .padding(8)
                    .background(.secondary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if let ref = model.referenceFrame {
                    Text("캘리브레이션: \(ref.sampleCount) 샘플")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Button("재시도") {
                    classifier?.stop()
                    model.invalidateExtendedSession()
                    model.retry()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .onAppear {
            guard let ref = model.referenceFrame else { return }
            let c = BrushingClassifier(referenceFrame: ref)
            classifier = c
            c.start()
        }
        .onDisappear {
            classifier?.stop()
        }
    }
}

// MARK: - Zone 표시 컴포넌트
private struct ZoneIndicator: View {
    let zone: BrushingZone

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundStyle(color)
            Text(label)
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var iconName: String {
        switch zone {
        case .right:   "arrow.right.circle.fill"
        case .left:    "arrow.left.circle.fill"
        case .unclear: "minus.circle.fill"
        }
    }

    private var label: String {
        switch zone {
        case .right:   "우측 이빨"
        case .left:    "좌측 이빨"
        case .unclear: "판정 중..."
        }
    }

    private var color: Color {
        switch zone {
        case .right:   .blue
        case .left:    .orange
        case .unclear: .secondary
        }
    }
}

// MARK: - Failed
private struct FailedView: View {
    let reason: String
    let model: CalibrationModel

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.orange)

            Text(reason)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("다시 시도") {
                model.retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
