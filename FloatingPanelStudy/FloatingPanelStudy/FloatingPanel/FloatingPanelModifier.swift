//
//  FloatingPanelModifier.swift
//  FloatingPanelStudy
//
//  Created by Jaebin Ahn on 7/20/26.
//
//  이 코드가 전반의 시스템에 있어 어떤 역할들을 하는지 궁금하다
// 답변: SwiftUI 뷰에 `.floatingPanel(...)` 기능을 붙여주는 연결 코드. SwiftUI 상태값(isPresented)에 따라 FloatingPanel을 만들고, 보여주고, 닫는 역할을 함.

import SwiftUI

struct FloatingPanelModifier<PanelContent: View>: ViewModifier {   // 이 PanelContent라는건 뭐임? 해당 줄의 설명이 필요하다
    // 답변: PanelContent는 패널 안에 들어갈 SwiftUI 뷰의 타입 이름. 어떤 뷰가 들어올지 미리 정하지 않고, ContentView에서 넘긴 뷰 타입을 받아 쓰기 위한 제네릭임.
    @Binding var isPresented: Bool  // 이건 해당 구조체를 다른곳에서 쓸 때
    // 답변: 이 modifier를 사용하는 바깥 View의 Bool 상태와 연결되는 값. 바깥에서 true/false가 바뀌면 여기서도 같은 값을 보고 패널을 열거나 닫음.
    
    let contentRect: CGRect
    @ViewBuilder let panelContent: () -> PanelContent // Viewbuilder가 뭐임?
    // 답변: 여러 SwiftUI 뷰를 중괄호 안에 자연스럽게 적으면 하나의 View로 만들어주는 기능. 여기서는 패널 내부에 표시할 내용을 만드는 클로저임.

    @State private var panel: FloatingPanel<PanelContent>?   // 이 FloatingPanel은 클래스 객체일텐데, init에 들어가는 파라미터는 어디서 입력 받음?
    // 답변: 아래 `.onAppear`에서 FloatingPanel을 만들 때 입력함. `view`는 panelContent, `contentRect`는 이 modifier가 받은 값, `isPresented`는 Binding으로 넘김.

    func body(content: Content) -> some View {
        content // 이게 실제로 사용될 땐 어디서 받아오는 인자인거지? 자료형이 궁금한데
        // 답변: 이 modifier가 붙은 원래 SwiftUI 뷰가 들어오는 자리. 자료형은 ViewModifier가 제공하는 `Content`이고, 예를 들면 ContentView에 붙이면 ContentView 쪽 화면이 여기로 들어옴.
            .onAppear {
                panel = FloatingPanel(
                    view: panelContent,
                    contentRect: contentRect,
                    isPresented: $isPresented
                )
                panel?.center()

                if isPresented {
                    present()
                }
            }
            .onDisappear {
                panel?.close()
                panel = nil
            }
            .onChange(of: isPresented) { _, value in  // 여기서 .onChange(of: isPresented)의 의미가 이해가 안된다
                // 답변: `isPresented` 값이 바뀔 때마다 실행되는 코드. 새 값인 `value`가 true면 패널을 보여주고, false면 패널을 닫음.
                if value {
                    present()
                } else {
                    panel?.close()
                }
            }
    }

    // 이 함수는 뭐임?
    // 답변: 만들어진 패널을 화면 앞으로 가져오고 입력 가능한 창으로 만드는 함수. `orderFront`는 보이게 하고, `makeKey`는 키보드 입력을 받을 수 있게 함.
    private func present() {
        panel?.orderFront(nil)
        panel?.makeKey()
    }
}

extension View {  // 이 extension이 뭐지?
    // 답변: 모든 SwiftUI View에 새 기능을 추가하는 문법. 다른 말로는 이미 존재하는 자료형에서 기능을 추가하는 문법이다.
    // 즉, 기존의 View라는 자료형에서 floatingPanel이라는 메서드를 붙여쓸 수 있도록하는것
    
    /// Presents an `NSPanel` with SwiftUI content.
    func floatingPanel<Content: View>(
        isPresented: Binding<Bool>,
        contentRect: CGRect = CGRect(x: 0, y: 0, width: 624, height: 512),
        @ViewBuilder content: @escaping () -> Content     // 이 구문 전체가 이해가 안됨
        // 답변: 패널 안에 들어갈 SwiftUI 뷰를 클로저로 받는 파라미터. `@ViewBuilder`로 여러 뷰를 적을 수 있고, `@escaping`은 함수가 끝난 뒤에도 modifier가 이 클로저를 저장해 쓰기 때문에 필요함.
        // 아 이건 뭔가 너무 어렵다... 나중에 따로 한번 더 공부 필요할듯
        
        // 클로저의 개념이 뭐지?
        // 답변: 실행할 코드 자체를 값으로 만들어서 전달하는 코드 묶음이라고 생각하면된다.
        
    ) -> some View {
        modifier(  // 이 modifier는 뭐야?
            // 답변: 현재 View에 `FloatingPanelModifier`를 적용하는 SwiftUI 기본 메서드. 원래 화면은 유지하면서 패널을 띄우는 동작을 추가함.
            FloatingPanelModifier(
                isPresented: isPresented,
                contentRect: contentRect,
                panelContent: content
            )
        )
    }
}

// 이건 뭐임?
// 답변: SwiftUI Environment에 `floatingPanel`이라는 값을 저장하기 위한 키. 기본값은 nil이라서 패널이 주입되지 않은 상태에서는 아무 NSPanel도 없다는 뜻임.
private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

// 얘는 EnvironmentValues라는 자료형을 확장하는 개념인건가?
// 답변: 맞음. SwiftUI EnvironmentValues에 `floatingPanel`이라는 새 프로퍼티를 추가해서, 하위 SwiftUI 뷰들이 현재 NSPanel에 접근할 수 있게 만든 것임.
extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}
