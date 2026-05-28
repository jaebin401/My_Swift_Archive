# TabView 학습

SwiftUI의 TabView를 활용해 탭 기반 화면 구성과 프로그래밍 방식의 탭 전환을 학습한 예제

## 작성일자
2026.05.28

## 학습 목표
• SwiftUI TabView의 기본 구조와 .tabItem 사용법 익히기
• selection 바인딩과 .tag()를 활용해 탭을 프로그래밍 방식으로 전환하는 방법 학습
• @State와 @Binding을 통해 부모-자식 뷰 간 탭 상태를 공유하는 패턴 이해

## 학습 맥락
C3 시스템 초안 구축 중에서, 탭뷰의 활용이 궁금해져서 학습함. <br> 단순히 탭을 사용하는게 아니라, 탭을 인덱싱 해서 전환할 수 있다는 방법을 우연히 알게 됨. 


## 구성
| 파일 | 역할 |
|------|------|
| TabView_studyApp.swift | 앱 진입점. 루트 뷰로 ContentView2 사용 |
| ContentView.swift | 초기 버전 (주석 처리됨). selection 없이 단순 TabView만 구성 |
| ContentView2.swift | @State selectedTab + selection: + .tag()로 프로그래밍 탭 전환 구현 |
| HomeView.swift | @Binding var selectedTab을 받아 버튼으로 Tip 탭으로 이동 |

## 핵심 개념
- TabView, .tabItem, Label(systemImage:)
- TabView(selection:)과 .tag()를 이용한 탭 식별 및 전환
- @State / @Binding을 이용한 부모-자식 상태 공유

## 배운 점 / 메모
- .tabItem 이라는 modifier를 달아서 탭의 이름과 아이콘을 지정해줄 수 있다.
- TabView만 사용해도 탭 UI는 만들어지지만, 외부에서 탭을 전환하려면 selection 바인딩이 필수.
- 여기서 selection 인덱싱 변수를 선언해서 사용하기 위해선, 각 탭의 뷰에 .tag(0) 꼴로 modifier를 달아주어야 한다.
- .tag(값)의 타입과 selection에 바인딩한 @State 변수의 타입은 반드시 일치해야 함 (여기서는 Int).
- TabView()에도 selection을 바인딩을 하고, HomeView() 에도 바인딩이 필요하다.