//
//  ContentView.swift
//  classicClassifier
//
//  Created by Jaebin Ahn on 6/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var connector = PhoneConnector.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // MARK: 연결 상태
                HStack(spacing: 6) {
                    Circle()
                        .fill(connector.isReachable ? Color.green : Color.secondary)
                        .frame(width: 8, height: 8)
                    Text(connector.isReachable ? "Watch 연결됨" : "Watch 연결 안됨")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // MARK: Calibration 제어
                CalibrationControlView(connector: connector)

                Divider()

                // MARK: Zone 판정 결과
                if let frame = connector.latestFrame {
                    ZoneIndicator(zone: frame.zone)

                    // 디버그 수치
                    // rmsX = accel magnitude RMS (움직임 활성 감지)
                    // rmsY = watchMinusY_inRef.y (우측 판별 기준, ≈ +1이면 우측)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("디버그 (1초 window)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("accel RMS")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.4f g", frame.rmsX))
                                .font(.system(.caption, design: .monospaced))
                        }
                        HStack {
                            Text("-Y in ref y  (우측 ≈ +1)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(frame.rmsY > 0.5 ? .blue : .secondary)
                            Spacer()
                            Text(String(format: "%+.3f", frame.rmsY))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(frame.rmsY > 0.6 ? .blue : .primary)
                        }
                    }
                    .padding()
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "applewatch.radiowaves.left.and.right")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Calibration 후 양치를 시작하세요")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("classicClassifier")
        }
    }
}

// MARK: - Calibration 제어 컴포넌트
private struct CalibrationControlView: View {
    let connector: PhoneConnector

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                Text(connector.calibrationStatus.message)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }

            Button {
                connector.sendStartCalibration()
            } label: {
                Label("Calibration 시작", systemImage: "arrow.trianglehead.2.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!connector.isReachable
                      || connector.calibrationStatus == .calibrating)
        }
    }

    private var statusIcon: String {
        switch connector.calibrationStatus {
        case .idle:        "circle"
        case .calibrating: "progress.indicator"
        case .calibrated:  "checkmark.circle.fill"
        case .failed:      "exclamationmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch connector.calibrationStatus {
        case .idle:        .secondary
        case .calibrating: .blue
        case .calibrated:  .green
        case .failed:      .orange
        }
    }
}

// MARK: - Zone 표시 컴포넌트
private struct ZoneIndicator: View {
    let zone: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 52))
                .foregroundStyle(color)
            Text(label)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var iconName: String {
        switch zone {
        case "right": "arrow.right.circle.fill"
        case "left":  "arrow.left.circle.fill"
        default:      "minus.circle.fill"
        }
    }

    private var label: String {
        switch zone {
        case "right": "우측 이빨"
        case "left":  "좌측 이빨"
        default:      "판정 중..."
        }
    }

    private var color: Color {
        switch zone {
        case "right": .blue
        case "left":  .orange
        default:      .secondary
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
