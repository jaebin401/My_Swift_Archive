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
        Group {
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
        .onAppear {
            WatchConnector.shared.onStartCalibrationCommand = { [weak model] in
                model?.retry()
                model?.start()
            }
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

                // 디버그 오버레이
                // watchMinusY_inRef: 우측(y≈+1) / 좌측(x≈-1) 판별용
                if let classifier {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("디버그")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(String(format: "accel RMS:  %.4f g", classifier.rmsAccel))
                            .font(.system(.caption, design: .monospaced))
                        Text(String(format: "-Y in ref x: %+.3f", classifier.watchMinusYx))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(classifier.watchMinusYx < 0.6 ? .orange : .primary)
                        Text(String(format: "-Y in ref y: %+.3f", classifier.watchMinusYy))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(classifier.watchMinusYy > 0.6 ? .blue : .primary)
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
