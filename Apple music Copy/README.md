# Apple music Copy

> Apple Music 재생 화면 UI를 SwiftUI로 모사해보며 화면을 컴포넌트 단위로 분해·조립하는 연습.

## 작성일자
2026.04.07

## 학습 목표
- SwiftUI에서 하나의 화면을 **여러 개의 작은 View 구조체로 쪼개 조립**하는 방식 익히기
- `HStack` / `VStack` / `Spacer` / `padding` 만으로 실제 앱과 유사한 레이아웃 만들기
- `@State`와 토글, 삼항연산자를 활용한 **간단한 인터랙티브 버튼**(셔플, 재생/일시정지) 구현
- `Slider`, `Menu`, `Button`, `Image(systemName:)` 등 자주 쓰는 컨트롤들에 익숙해지기
- SF Symbols 이름을 상태에 따라 바꿔서 아이콘이 변하는 패턴 경험

## 학습 맥락
- 테크멘토 Jasung의 권장으로, Swift와 SwiftUI 기본을 익히기 위해 직접 Apple Music의 UI를 클론 해 보며 학습

##  구성
| 파일 | 역할 |
|------|------|
| `Apple_music_CopyApp.swift` | 앱 진입점. `ContentView`를 띄우는 `@main` 구조체 |
| `ContentView.swift` | 전체 화면 컴포지션. 아래 서브 View들을 위→아래로 쌓아 한 화면을 구성 |
| `AlbumInfo.swift` | 앨범 커버 이미지 + 곡/아티스트 정보 + 즐겨찾기(별표) + 더보기(`Menu`) 영역 |
| `Four_buttons.swift` | 셔플 / 반복 / 무한재생 / 자동재생 4개 토글 버튼 행. `@State`로 셔플 토글 구현 |
| `PlayList.swift` | "계속 재생" 섹션 헤더(현재는 자리만 잡아둔 스켈레톤) |
| `PausePlay.swift` | 이전곡 / 재생·일시정지 / 다음곡 컨트롤. 재생 상태에 따라 SF Symbol 토글 |
| `Volume.swift` | 좌우 스피커 아이콘 사이의 볼륨 `Slider` |
| `bottom.swift` | 하단 가사·AirPlay·재생목록 아이콘 바 |
| `popup.swift` | `AlbumInfo`의 `Menu`에서 열리는 컨텍스트 메뉴 항목들(노래 고정, 플레이리스트 추가 등) |
| `ModalView.swift` | 전체 레이아웃을 주석으로 설계해본 스케치 단계의 모달 View |

## 핵심 개념
- `VStack` / `HStack` / `Spacer` 기반 레이아웃과 `.padding()` 으로 간격 잡기
- `@State` + 삼항연산자(`isShuffle ? "shuffle.fill" : "shuffle"`)로 **토글되는 아이콘** 만들기
- `Image(systemName:)` 으로 **SF Symbols** 활용, `.font(.title3.bold())`로 크기/굵기 조절
- `Button { ... } label: { ... }` 형태의 트레일링 클로저 + 라벨 구문
- `Menu { popup() } label: { ... }` 로 **드롭다운/팝업 메뉴** 붙이기
- `Slider(value: $volume, in: 0...100, step: 1)` — 양방향 바인딩(`$`) 첫 사용
- `ScrollView(.horizontal)` 로 긴 텍스트 가로 스크롤
- `#Preview { ... }` 매크로로 서브 View 단위 미리보기 — **컴포넌트 단위 개발 습관**
- `enum reapeatType { case repeated, repeatOne, nonrepeat }` — 반복 상태를 표현하기 위한 enum 정의 시도

## 배운 점 / 메모
- 한 화면을 통째로 그리지 말고 **`AlbumInfo`, `Four_buttons`, `PausePlay` …** 처럼 영역별로 잘게 쪼개면, 각 컴포넌트를 `#Preview`로 따로 띄워보며 디버깅할 수 있어 훨씬 편하다.
- 같은 패턴 메모: **"아이콘이 상태에 따라 바뀌어야 한다" → `@State var icon: String` + 삼항연산자로 토글**.
- `Spacer()`를 양쪽에 넣어주면 자동으로 가운데 정렬되고, 사이에 넣으면 균등 분배된다. CSS의 `justify-content: space-between/around` 감각.
- 막혔던 부분 / 다음에 다시 볼 한 줄: _직접 채워넣기_
- (예시 메모: 반복 버튼은 `Bool`이 아니라 3-state라서 `enum`이 필요했다 — 위 `reapeatType` 처럼 미리 타입을 정의해두면 깔끔)

## 참고 자료
- [Apple Developer — SwiftUI Overview](https://developer.apple.com/documentation/swiftui)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Apple Developer — Slider](https://developer.apple.com/documentation/swiftui/slider)


