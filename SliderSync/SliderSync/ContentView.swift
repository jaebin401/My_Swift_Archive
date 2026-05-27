import SwiftUI

struct ContentView: View {
    @State private var value: Double = 0.5
    
    var body: some View {
        VStack(spacing: 24) {
            Text(String(format: "%.2f", value))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
            
            Slider(value: $value, in: 0...1)
                .padding(.horizontal)
                .onChange(of: value) { _, newValue in
                    PhoneConnector.shared.send(value: newValue)
                }
        }
        .padding()
        .onAppear {
            _ = PhoneConnector.shared      // 앱 시작 시 세션 활성화 트리거
        }
    }
}

#Preview {
    ContentView()
}
