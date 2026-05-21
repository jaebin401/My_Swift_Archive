# csv Export

## 작성일자
2026.05.21

## 학습 목표
CSV 파일 만들고, 내보내는 기능 구현

## 학습 맥락
C3 앱 개발 중, CoreMotion 측정 데이터 녹화 후 CreatML 학습을 위해서 CSV 파일 내보내기 기능 필요 <br>
그래서 간단히 텍스트필드로 입력한 문자열 CSV로 내보내기 기능 학습

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
- **ShareLink**: SwiftUI 표준 공유 컴포넌트
- **URL**: Universal Resource Locator, 웹 뿐만 아니라 로컬의 자원 저장 주소에 대한 개념. 
- 파일 디렉토리 관련
    ``` swift
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    ```
    - FileManager.default : <br>
     FileManager는 파일 시스템(파일/폴더 만들기, 읽기, 삭제 등)을 다루는 Apple 표준 클래스 <br>
     .default는 그중 앱 전체가 공유하는 기본 인스턴스를 가져오는 것
    - temporaryDirectory: 파일을 임시로 저장하는 개념, FileManager 객체
    - .appendingPathComponent(fileName): url의 가장 마지막에 fileName으로 주소 지정해주는것
- .write(...) { ... }
    ```swift
    // 문자열을 파일로 쓰기
    do {
        try csvString.write(to: url, atomically: true, encoding: .utf8)
        return url
    } catch {
        print("CSV write failed: \(error)")
        return nil
    }
    ```
    - csvString.write() 메서드가 결국 핵심, csvWrite 라는 문자열을 csv로 입력해주는 기능
    - 변수 url 에다가, .utf8 인코딩
    - atomically true :
        1. 시스템이 먼저 임시 파일(보이지 않는 백업용 파일)에 데이터를 다 씀
        2. 쓰기가 완전히 성공하면, 그 임시 파일을 목적지 이름으로 한 번에 교체
        3. 만약 중간에 앱이 죽거나 전원이 꺼지면 → 원본 파일은 손상되지 않음 <br>
    - atomically가 false일 때 :데이터를 목적지 파일에 바로 쓰기 시작함. 그래서 중간에 앱이 꺼지면 → 절반만 쓰인 깨진 파일이 남을 수 있음



<!-- ## 사진
스크린샷 또는 GIF -->