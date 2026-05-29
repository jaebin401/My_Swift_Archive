# SwiftDate_Study

## 작성일자
2026.05.29

## 학습 목표
- SwiftData로 데이터의 CRUD 하는 방법에 대한 기초 학습

## 학습 맥락
- C3 앱 개발 중, 양치 데이터 저장 필요성을 느꼈고, 애플 공식 튜토리얼에서 결과되는 샘플 코드 기록

<!-- ##  구성
| 파일 | 역할 |
|------|------|
| `XxxView.swift` |   |
| `YyyModel.swift` |   |
| `ZzzManager.swift` |   | -->

<!-- ## 핵심 개념 
- `LazyVGrid`, `ScrollView`, `GeometryReader`
- `CMMotionManager`, `deviceMotion`
- (이 폴더에서 처음 다뤄본 문법이나 API) -->

## 배운 점 / 메모

### SwiftData 4요소
| 요소 | 역할 |
|------|------|
| `@Model` | 저장 가능한 데이터 모델 정의 (schema 생성) | 
| `modelContainer` | 실제 저장소(storage)를 만들고 앱에 주입 |
| `@Query` | 저장소에서 데이터를 **읽어오는** 통로 (read 전담, 자동 갱신) | 
| `modelContext` | 데이터를 **쓰는** 통로 (insert/delete, 변경 추적·저장) | 

### CRUD 매핑

| 동작 | 사용 방법 | 코드 예시 |
|------|-----------|-----------|
| **C**reate | `context.insert(_:)` | `context.insert(newFriend)` |
| **R**ead | `@Query` | `friends` 배열을 `List`에서 순회 |
| **U**pdate | 객체의 property를 그냥 바꾸면 됨 | `friend.name = "..."` (별도 함수 호출 불필요) |
| **D**elete | `context.delete(_:)` | `context.delete(friend)` |

