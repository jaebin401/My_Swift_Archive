# CSV 선택부터 SwiftData 저장까지의 핵심 흐름

## 1. 문서 목적

이 문서는 사용자가 CSV 파일을 선택한 시점부터 CSV의 각 행이 SwiftData 객체로 저장되기까지의 핵심 흐름을 설명한다.

특정 파일명이나 프로젝트 디렉터리 구조에는 의존하지 않는다. 구현 구조가 변경되더라도 다음 데이터 흐름은 동일하게 유지된다.

```text
파일 선택
→ 파일 읽기
→ CSV 파싱
→ 데이터 변환 및 검증
→ SwiftData 저장
→ 저장 결과 출력
```

## 2. 전체 흐름

```text
사용자
  ↓ CSV 선택

File Importer
  ↓ 파일 URL

File Loader
  ↓ CSV 원문 String 또는 Data

CSV Parser
  ↓ 헤더와 행 배열

Record Mapper
  ↓ SwiftData 모델 객체 배열

Persistence
  ↓ insert 및 save

SwiftData 저장소
  ↓ Query

SwiftUI 화면
```

각 단계에서는 데이터의 형태와 책임이 달라진다.

## 3. CSV 파일 선택

샌드박스가 활성화된 앱은 사용자의 파일 시스템에 있는 임의의 파일을 직접 읽을 수 없다. 따라서 사용자가 시스템 파일 선택창에서 CSV를 직접 선택해야 한다.

SwiftUI에서는 `.fileImporter`를 사용할 수 있다.

```swift
.fileImporter(
    isPresented: $isShowingImporter,
    allowedContentTypes: [.commaSeparatedText],
    allowsMultipleSelection: false
) { result in
    // 선택 결과 처리
}
```

이 단계의 결과는 파일 내용이 아니라 파일을 가리키는 `URL`이다.

```text
입력: 사용자의 파일 선택
출력: URL
```

파일 선택은 성공하거나 실패할 수 있다.

```swift
switch result {
case .success(let urls):
    // 선택한 파일 URL 사용

case .failure(let error):
    // 파일 선택 실패 처리
}
```

`fileImporter`의 책임은 파일 URL을 전달하는 것까지다. 파일을 선택했다고 해서 CSV 내용이 자동으로 읽히거나 분석되는 것은 아니다.

## 4. 파일 접근 및 로딩

### 4.1 Security-scoped URL

사용자가 선택한 파일은 앱의 샌드박스 외부에 있을 수 있다. 파일을 읽기 전 임시 접근 권한을 활성화한다.

```swift
guard url.startAccessingSecurityScopedResource() else {
    throw ImportError.permissionDenied
}

defer {
    url.stopAccessingSecurityScopedResource()
}

// 파일 읽기
```

`defer`를 사용하면 파일 읽기 성공 여부와 관계없이 함수가 종료될 때 접근 권한을 반환할 수 있다.

### 4.2 파일 내용 읽기

CSV 파일을 문자열로 읽을 수 있다.

```swift
let csvText = try String(
    contentsOf: url,
    encoding: .utf8
)
```

이 단계에서는 CSV 내용을 해석하지 않는다.

```text
입력: URL
출력: String
```

파일 로딩 단계는 외부 파일 접근, 인코딩, 파일 읽기와 접근 권한 반환을 담당한다. CSV 헤더 구성, 데이터 타입, SwiftData 모델, 화면 출력 방식은 알 필요가 없다.

## 5. CSV 파싱

파싱은 CSV 원문 문자열을 코드에서 다룰 수 있는 구조로 변환하는 과정이다.

```text
String
→ 헤더 배열
→ 행 배열
```

예를 들어 다음 CSV가 있다.

```csv
본명,이름,나이,키
안재빈,vince,24,177
홍길동,steve,30,180
```

헤더는 다음과 같이 분리된다.

```swift
["본명", "이름", "나이", "키"]
```

각 행은 헤더와 값을 연결한 형태로 표현할 수 있다.

```swift
[
    "본명": "안재빈",
    "이름": "vince",
    "나이": "24",
    "키": "177"
]
```

### 5.1 중간 데이터 구조

파싱 결과를 SwiftData 모델로 바로 만들지 않고, 저장 방식과 무관한 중간 데이터로 표현한다.

```swift
struct ParsedCSV {
    let headers: [String]
    let rows: [ParsedCSVRow]
}

struct ParsedCSVRow {
    let rowNumber: Int
    let values: [String: String]
}
```

### 5.2 파싱 단계에서 모든 값을 String으로 유지하는 이유

CSV는 기본적으로 텍스트 형식이다. 따라서 파싱 단계에서는 `"24"`, `"177.5"`, `"true"`, `"2026-08-20"` 같은 값을 모두 문자열로 유지한다.

예를 들어 `"00123"`은 숫자처럼 보이지만 사원 번호, 우편번호 또는 상품 코드일 수 있다. `Int`로 즉시 변환하면 앞의 `00`이 사라진다.

CSV 문법을 해석하는 단계와 앱 데이터 타입을 결정하는 단계를 분리해야 한다.

### 5.3 파싱 단계의 검증

파싱 단계에서는 CSV 구조 자체를 검사한다.

- 파일이 비어 있는가?
- 헤더가 존재하는가?
- 중복 헤더가 있는가?
- 행마다 열 개수가 동일한가?
- 큰따옴표가 정상적으로 닫혀 있는가?
- 지원하는 인코딩인가?

## 6. 데이터 매핑 및 타입 변환

매핑은 파싱된 CSV 행을 앱이 사용하는 SwiftData 모델 객체로 변환하는 과정이다.

```text
ParsedCSVRow
→ SwiftData 모델 객체
```

파싱 결과가 다음과 같다고 가정한다.

```swift
[
    "본명": "안재빈",
    "이름": "vince",
    "나이": "24",
    "키": "177"
]
```

매핑 단계에서는 다음 변환을 수행한다.

```text
"본명" → realName: String?
"이름" → name: String?
"나이" → age: Int?
"키"   → height: Double?
```

결과는 저장 가능한 모델 객체가 된다.

```swift
ImportedRecord(
    realName: "안재빈",
    name: "vince",
    age: 24,
    height: 177,
    sourceFileName: "test.csv",
    sourceRowNumber: 2
)
```

### 6.1 Optional 값 처리 원칙

CSV에 없는 속성과 잘못된 값은 구분해야 한다.

```text
열이 없음             → nil
셀이 비어 있음        → nil
정상적인 값           → 변환해서 저장
값이 있지만 변환 실패 → 오류
```

나이 값이 `"스물넷"`인 경우 조용히 `nil`로 바꾸지 않고 타입 변환 오류로 처리하는 것이 좋다. 잘못된 값을 모두 `nil`로 바꾸면 원본 데이터의 문제를 발견하기 어렵기 때문이다.

### 6.2 Mapper의 책임 범위

매핑 단계는 다음을 담당한다.

- CSV 헤더와 모델 속성 연결
- 문자열 공백 처리
- 빈 값의 Optional 처리
- `String`을 `Int`, `Double`, `Bool`, `Date` 등으로 변환
- 타입 변환 오류 발생
- SwiftData 모델 객체 생성

Mapper는 SwiftData에 객체를 저장하지 않는다. Mapper의 결과는 저장할 준비가 된 메모리상의 모델 객체다.

## 7. SwiftData 저장

매핑된 모델 객체를 SwiftData의 `ModelContext`에 추가하고 저장한다.

```swift
for record in records {
    modelContext.insert(record)
}

try modelContext.save()
```

데이터 흐름은 다음과 같다.

```text
[ImportedRecord]
→ ModelContext.insert()
→ ModelContext.save()
→ SwiftData 저장소
```

### 7.1 저장과 매핑을 분리하는 이유

Mapper에서 바로 저장하면 타입 변환과 데이터베이스 저장이 하나의 작업으로 섞인다. 이 경우 타입 변환 실패와 저장 실패를 구분하기 어려워지고, 몇 번째 행까지 저장됐는지 파악하기 어려워진다.

권장 흐름은 다음과 같다.

```text
전체 CSV 파싱
→ 모든 행 타입 변환
→ 모든 행 검증 성공
→ SwiftData 저장
```

예를 들어 100번째 행에서 타입 오류가 발생하면 저장을 시작하지 않을 수 있다. 이를 통해 일부 행만 저장되는 상황을 방지하기 쉽다.

### 7.2 저장 단위

가능하면 CSV 파일 하나를 하나의 가져오기 작업 단위로 취급한다.

```text
전체 성공 → 전부 저장
일부 실패 → 저장하지 않고 오류 표시
```

부분 성공을 지원해야 한다면 성공한 행, 실패한 행, 실패한 열, 실패 원인과 실제 저장 개수를 별도로 관리해야 한다. 초기 구현에서는 전체 성공 또는 전체 실패 방식이 단순하다.

## 8. 저장 결과 출력

SwiftData에 저장된 데이터는 `@Query`를 사용해 SwiftUI 화면에 표시할 수 있다.

```swift
@Query
private var records: [ImportedRecord]
```

저장이 완료되면 Query 결과가 변경되고 SwiftUI 화면이 다시 렌더링된다.

```text
SwiftData save
→ Query 결과 변경
→ SwiftUI 화면 갱신
```

화면에는 CSV 원문이 아니라 실제로 저장된 SwiftData 객체를 출력한다. 이를 통해 한 행이 객체 하나로 저장됐는지, 타입 변환과 Optional 처리가 정상적인지 확인할 수 있다.

## 9. 오류 전달 흐름

오류는 발생한 단계에서 감지하고 화면을 관리하는 단계까지 전달한다.

```text
파일 접근 오류
CSV 구조 오류
타입 변환 오류
SwiftData 저장 오류
        ↓
      throw
        ↓
상위 계층에서 catch
        ↓
사용자 메시지로 변환
        ↓
SwiftUI에서 표시
```

대표 오류는 다음과 같다.

### 파일 선택 및 로딩

- 사용자가 파일 선택을 취소함
- 파일 접근 권한을 얻지 못함
- 파일이 존재하지 않음
- UTF-8로 읽을 수 없음

### CSV 파싱

- CSV가 비어 있음
- 헤더가 없음
- 중복 헤더가 있음
- 행의 열 개수가 다름
- 큰따옴표 형식이 잘못됨

### 데이터 매핑

- 나이를 `Int`로 바꿀 수 없음
- 키를 `Double`로 바꿀 수 없음
- 날짜 형식이 올바르지 않음
- 필수 속성이 누락됨

### SwiftData 저장

- 저장소 생성 실패
- 모델 스키마 불일치
- 저장 공간 부족
- 저장 중 오류 발생

## 10. 단계별 데이터 형태

CSV 가져오기 과정에서 데이터는 다음과 같이 변한다.

```text
URL
→ CSV 원문 String
→ ParsedCSVRow 배열
→ SwiftData 모델 객체 배열
→ Persistent Store
```

각 데이터 형태의 의미는 다음과 같다.

1. `URL`: 사용자가 선택한 파일의 위치
2. `String`: 아직 해석하지 않은 CSV 원문
3. `ParsedCSVRow`: 헤더와 값이 연결된 중간 데이터
4. 모델 객체: 타입 변환과 검증이 끝난 메모리상의 객체
5. Persistent Store: 앱 종료 후에도 조회할 수 있는 저장 상태

## 11. 핵심 설계 원칙

### 파일 읽기와 CSV 파싱을 분리한다

파일을 어디서 읽는지와 CSV를 어떻게 해석하는지는 서로 다른 문제다.

### CSV 파싱과 타입 변환을 분리한다

CSV Parser는 문법을 해석하고, Mapper는 데이터의 의미를 해석한다.

### 타입 변환과 저장을 분리한다

Mapper는 객체를 만들고, 저장 단계는 `ModelContext`를 관리한다.

### 원본 위치를 기록한다

저장 객체에 원본 파일명과 CSV 행 번호를 기록하면 오류 추적이 쉽다.

### 빈 값과 잘못된 값을 구분한다

빈 값은 `nil`일 수 있지만, 잘못된 값은 오류로 처리한다.

### 가능하면 저장 전에 전체 데이터를 검증한다

전체 검증 이후 저장하면 부분 저장을 방지하기 쉽다.

## 12. 현재 방식의 한계와 확장

단순히 쉼표와 줄바꿈으로 파싱하면 다음과 같은 큰따옴표 내부 쉼표를 처리할 수 없다.

```csv
name,address
vince,"Pohang, Korea"
```

실제 CSV 지원 범위를 넓힐 때는 다음 항목을 고려해야 한다.

- 큰따옴표 내부 쉼표
- `""`로 표현한 큰따옴표
- 큰따옴표 내부 줄바꿈
- UTF-8 BOM
- 빈 행
- 날짜 형식
- 숫자 로케일

현재 구조는 전체 CSV를 문자열과 배열로 메모리에 보관한다. 매우 큰 CSV에서는 일정 행 단위로 파싱, 매핑, 저장하는 스트리밍 구조를 고려할 수 있다.

## 13. 핵심 요약

CSV 가져오기 기능은 다음 다섯 단계로 이해할 수 있다.

```text
1. 선택: 사용자가 파일을 선택하고 URL을 얻는다.
2. 로딩: URL에서 CSV 원문을 읽는다.
3. 파싱: 원문을 헤더와 행 배열로 바꾼다.
4. 매핑: 각 행을 타입이 지정된 SwiftData 모델 객체로 바꾼다.
5. 저장: 모든 객체를 ModelContext에 추가하고 저장한다.
```

각 단계의 출력은 다음 단계의 입력이 된다.

```text
URL
→ String
→ ParsedCSVRow 배열
→ SwiftData 모델 객체 배열
→ Persistent Store
```

이 흐름을 유지하면 프로젝트의 파일명, 디렉터리 구조 또는 화면 구성이 변경되더라도 CSV 가져오기 기능의 핵심 설계는 바뀌지 않는다.
