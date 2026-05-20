# imu_study

> iOS 기기의 내장 IMU(자이로+가속도계)를 Core Motion으로 읽어와 Roll / Pitch / Yaw 자세각을 실시간으로 표시해보는 학습용 미니 앱.

## 학습 목표
- iOS 기기의 **IMU 센서 데이터**를 Swift에서 직접 받아오는 방법 익히기
- `CMMotionManager`의 `startDeviceMotionUpdates`로 센서 스트림을 구독하고, 콜백에서 자세(attitude)를 추출
- `ObservableObject` + `@Published` + `@StateObject` 조합으로 **센서 → ViewModel → View** 데이터 흐름 구성하기
- View의 라이프사이클(`onAppear` / `onDisappear`)에 맞춰 센서를 시작/정지해 **배터리 누수를 막는 패턴** 익히기
- 라디안 → 도(degree) 단위 변환 등 센서값을 사람이 읽기 좋은 포맷으로 가공

## 학습 맥락
- 본업으로 진행 중인 12자유도 휴머노이드 로봇 제어에서 IMU는 base orientation 관측에 핵심적인데, **휴대폰을 손쉬운 IMU 테스트베드**로 써보고 싶어 시작.
- SwiftUI에서 외부 디바이스/센서 데이터를 다루는 **MVVM 비슷한 흐름**을 처음 익혀보는 실습이기도 함.


##  구성
| 파일 | 역할 |
|------|------|
| `imu_studyApp.swift` | 앱 진입점. `ContentView`를 띄움 |
| `MotionManager.swift` | `CMMotionManager`를 감싼 ObservableObject. roll/pitch/yaw를 `@Published`로 노출하고 `start()` / `stop()` 제공 |
| `ContentView.swift` | `@StateObject`로 `MotionManager`를 소유, 자세각을 모노스페이스 텍스트로 실시간 표시. `onAppear` / `onDisappear`에서 센서 토글 |

## 핵심 개념
- `CMMotionManager`, `startDeviceMotionUpdates(to:withHandler:)`, `stopDeviceMotionUpdates()`
- MotionManager 에서 CoreMotion 호출, 그 내부의 CMMotionManager 객체 인스턴스를 하나 만들어서 관리

## 배운 점 / 메모
- **`@StateObject` vs `@ObservedObject`**: 객체를 "여기서 만들고 소유"할 거면 `@StateObject`, 외부에서 주입받아 보기만 할 거면 `@ObservedObject`. View가 재생성돼도 `@StateObject`는 한 번만 만들어진다.
- MotionManager 에서 CoreMotion 호출, 그 내부의 CMMotionManager 객체 인스턴스를 하나 만들어서 관리
- 센서 콜백에서 `[weak self]` 안 걸어두면 MotionManager가 deallocated 되지 않아 `stop()` 호출해도 콜백이 계속 돈다.
- 업데이트 주기(`deviceMotionUpdateInterval`)는 너무 낮추면 발열·배터리, 너무 높이면 끊김. 100Hz는 모션 시각화 용도로 무난.


<!-- 
## 참고 자료
- [Apple Developer — Core Motion](https://developer.apple.com/documentation/coremotion)
- [Apple Developer — CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager)
- [Apple Developer — CMAttitude](https://developer.apple.com/documentation/coremotion/cmattitude)
- [Apple Developer — ObservableObject](https://developer.apple.com/documentation/combine/observableobject) -->

