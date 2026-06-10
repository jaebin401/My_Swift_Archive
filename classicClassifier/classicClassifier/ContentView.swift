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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("RMS (1초 window)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("x (우측)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.blue)
                            Spacer()
                            Text(String(format: "%.4f g", frame.rmsX))
                                .font(.system(.caption, design: .monospaced))
                        }
                        HStack {
                            Text("y (좌측)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.orange)
                            Spacer()
                            Text(String(format: "%.4f g", frame.rmsY))
                                .font(.system(.caption, design: .monospaced))
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
            // Watch로부터 수신한 calibration 상태 표시
            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                Text(connector.calibrationStatus.message)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }

            // Calibration 시작 버튼
            // calibrating 중에는 비활성화
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
    ContentView()
}
