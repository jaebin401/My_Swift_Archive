# FloatingPanelStudy

SwiftUI에서 macOS `NSPanel` 기반 floating panel을 사용하는 방법을 정리한 학습용 프로젝트입니다.

## Overview

이 프로젝트는 SwiftUI view에서 `.floatingPanel(...)` modifier를 호출해 별도의 floating panel을 열 수 있도록 구성되어 있습니다.

주요 동작은 다음과 같습니다.

- SwiftUI content를 `NSHostingView`로 감싸 `NSPanel`에 표시
- 앱 window 위에 떠 있는 floating panel 제공
- panel이 key/main window가 될 수 있도록 설정
- panel이 닫히면 SwiftUI `@State` binding과 상태 동기화
- `NSVisualEffectView`를 SwiftUI에서 사용할 수 있도록 bridge
- panel 하단 corner가 각져 보이지 않도록 layer clipping 적용

## Project Structure

```text
FloatingPanelStudy/FloatingPanelStudy
├── FloatingPanel
│   ├── FloatingPanel.swift
│   ├── FloatingPanelModifier.swift
│   └── VisualEffectView.swift
├── MainApp
│   ├── ContentView.swift
│   ├── FloatingPanelContentView.swift
│   └── FloatingPanelStudyApp.swift
└── Assets.xcassets
```

## FloatingPanel

`FloatingPanel` 폴더는 앱 화면과 분리된 재사용 가능한 panel 구현을 담고 있습니다.

### FloatingPanel.swift

`NSPanel`을 상속한 핵심 panel 타입입니다.

담당하는 설정:

- `.nonactivatingPanel`, `.titled`, `.resizable`, `.closable`, `.fullSizeContentView`
- `level = .floating`
- `titleVisibility = .hidden`
- `titlebarAppearsTransparent = true`
- `hidesOnDeactivate = true`
- 기본 window button 숨김
- 투명 배경과 rounded clipping 설정
- `close()` 시 `isPresented` binding을 `false`로 동기화

### FloatingPanelModifier.swift

SwiftUI에서 panel을 쉽게 붙이기 위한 modifier와 extension을 포함합니다.

```swift
.floatingPanel(isPresented: $isFloatingPanelPresented) {
    FloatingPanelContentView(isPresented: $isFloatingPanelPresented)
}
```

이 파일에는 다음 코드가 함께 있습니다.

- `FloatingPanelModifier`
- `View.floatingPanel(...)`
- `FloatingPanelKey`
- `EnvironmentValues.floatingPanel`

짧은 helper 타입들을 기능 단위로 묶어서 파일 분산을 줄였습니다.

### VisualEffectView.swift

`NSVisualEffectView`를 SwiftUI에서 사용할 수 있도록 `NSViewRepresentable`로 감싼 타입입니다.

`FloatingPanelContentView`에서 macOS native blur material을 배경으로 사용합니다.

## MainApp

`MainApp` 폴더는 실제 앱 화면과 예제 panel content를 담고 있습니다.

### ContentView.swift

메인 window 화면입니다.

`Show Floating Panel` 버튼을 누르면 `isFloatingPanelPresented` 값이 바뀌고, `.floatingPanel(...)` modifier를 통해 panel이 열립니다.

### FloatingPanelContentView.swift

floating panel 내부에 표시되는 SwiftUI view입니다.

`VisualEffectView`를 배경으로 사용하고, close button을 눌러 binding을 `false`로 바꿔 panel을 닫습니다.

### FloatingPanelStudyApp.swift

앱 entry point입니다.

## Usage

새 SwiftUI view에서 floating panel을 사용하려면 `@State`로 표시 상태를 만들고 `.floatingPanel(...)`을 붙이면 됩니다.

```swift
struct ExampleView: View {
    @State private var isPresented = false

    var body: some View {
        Button("Open Panel") {
            isPresented = true
        }
        .floatingPanel(
            isPresented: $isPresented,
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 280)
        ) {
            Text("Panel Content")
                .frame(width: 420, height: 280)
        }
    }
}
```

## Notes

- 이 프로젝트는 macOS 앱을 기준으로 합니다.
- `FloatingPanel` 구현은 SwiftUI 전용 API가 아니라 AppKit `NSPanel`을 SwiftUI에서 쓰기 쉽게 감싼 구조입니다.
- panel content의 시각적 rounding은 `NSHostingView` layer clipping과 SwiftUI `clipShape`를 함께 사용합니다.
- 앱 고유 화면은 `MainApp`, 재사용 가능한 panel infrastructure는 `FloatingPanel` 폴더에 둡니다.
