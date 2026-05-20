# watch_test

> 애플워치 연결 시도 및 기본 개발환경 구성방법 학습, CoreMotion

## 작성일자
2026.05.19

## 학습 목표
- Xcode에서 watchOS 타깃을 포함한 iOS + Watch App 프로젝트 구조를 만들어보고, 실기기에서 빌드/실행이 되는지 확인한다.
- Apple Watch에서 `CoreMotion`의 `CMMotionManager`를 통해 자세(attitude) 데이터(roll, pitch, yaw)를 받아 화면에 실시간으로 표시해본다.
- `magneticField` 값(자기장)을 가져올 수 있는지 함께 시도하며 어떤 값이 들어오는지 확인한다.

## 학습 맥락
- Apple Watch를 활용한 동작/자세 인식에 관심이 생겨, 우선 가장 단순한 형태로 시계 위에서 IMU 값을 화면에 띄워보는 것이 목표였다.
- 직전에 iPhone에서 `CoreMotion`을 다뤘던 경험을 기반으로(`bd18f6f iPhone CoreMotion, imu study`), 동일한 방식이 watchOS에서도 동작하는지 비교해보고자 했다.
- iOS 앱은 기본 템플릿 상태로 두고, 실제 학습/실험은 Watch App 타깃에서 진행했다.

##  구성
| 파일 | 역할 |
|------|------|
| `watch_test/ContentView.swift` | iOS 앱 측 기본 화면 (템플릿 그대로, 동작 확인용) |
| `watch_test/watch_testApp.swift` | iOS 앱 진입점 |
| `watch_test Watch App/ContentView.swift` | Watch App 화면. roll/pitch/yaw를 실시간으로 표시 |
| `watch_test Watch App/MotionManager.swift` | `CMMotionManager`를 감싸 attitude/자기장 값을 `@Published`로 노출 |
| `watch_test Watch App/watch_testApp.swift` | Watch App 진입점 |

## 핵심 개념
- `CMMotionManager`, `startDeviceMotionUpdates(to:withHandler:)`
- `CMDeviceMotion.attitude` (roll / pitch / yaw, 라디안 → degree 변환)
- `CMDeviceMotion.magneticField` (시계에서의 자기장 값 시도)
- `ObservableObject` + `@Published` + `@StateObject` 를 사용한 SwiftUI 데이터 바인딩
- `.onAppear` / `.onDisappear` 라이프사이클을 이용한 센서 start/stop 처리
- iOS 앱 + watchOS 앱이 함께 들어있는 멀티 타깃 Xcode 프로젝트 구성

## 배운 점 / 메모
- watchOS에서도 `CMMotionManager`의 `deviceMotion` API를 그대로 사용할 수 있고, 60Hz(`1.0 / 60.0`) 정도의 업데이트 주기로 무리 없이 값을 받을 수 있었다.

- 시뮬레이터에서는 `isDeviceMotionAvailable`이 false 이므로 반드시 실기기에서 실행해야 한다는 점을 가드 처리로 확인.

## 참고 자료
> - [Apple Developer - Core Motion](https://developer.apple.com/documentation/coremotion)
> - [Apple Developer - CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager)
> - [Apple Developer - CMDeviceMotion](https://developer.apple.com/documentation/coremotion/cmdevicemotion)

<!-- ## 사진
스크린샷 또는 GIF -->
