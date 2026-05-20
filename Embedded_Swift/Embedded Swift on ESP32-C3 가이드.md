# Embedded Swift on ESP32-C3 가이드

<aside>

</aside>

## macOS CLI 환경 기준 · ESP32-C3 보드

---

> 📌 **참고 문서**
> 
> - [Build Embedded Swift Application for ESP32-C6 — Espressif Developer Portal](https://developer.espressif.com/blog/build-embedded-swift-application-for-esp32c6/)
> - [ESP-IDF Get Started — Espressif Docs](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html)
> 
> **환경**: macOS (Apple Silicon) · **보드**: ESP32-C3 Super Mini · **방식**: CLI
> 

---

## Embedded Swift란?

Embedded Swift는 WWDC24에서 Apple이 발표한 실험적 기능으로, Swift 언어를 마이크로컨트롤러 같은 리소스 제한 환경에서 동작하도록 경량화한 컴파일 모드다. 전체 Swift 런타임 없이도 동작하며 바이너리 크기가 수 KB 수준으로 작다.

> ⚠️ **주의**: Embedded Swift는 현재 **experimental** 단계다. RISC-V 아키텍처 기반 칩(ESP32-C3, C6, H2, P4)만 지원하며, Xtensa 기반(ESP32, S2, S3)은 미지원이다.
> 

---

## 사전 준비물

| 항목 | 비고 |
| --- | --- |
| ESP32-C3 보드 | Super Mini 포함 모든 C3 계열 |
| USB-C 케이블 | 데이터 통신 지원 필수 (충전 전용 X) |
| macOS (Apple Silicon) | Intel Mac도 동일하나 일부 경로 다를 수 있음 |
| Homebrew | 미설치 시 [brew.sh](https://brew.sh/) 참고 |

---

## 전체 흐름

```
Homebrew 패키지 설치
    ↓
ESP-IDF 설치 (EIM CLI 방식)
    ↓
환경변수 활성화
    ↓
Swiftly + Swift 6.2 snapshot 설치
    ↓
swift-embedded-examples 클론
    ↓
빌드 + 플래시
```

---

## Step 1: Homebrew 패키지 설치

```bash
brew install cmake ninja dfu-util python3
```

---

## Step 2: ESP-IDF 설치 (EIM CLI)

공식 문서에서는 EIM(ESP-IDF Installation Manager)을 통한 설치를 권장한다.

```bash
brew tap espressif/eim
brew install eim
```

설치 확인:

```bash
eim --version
```

EIM으로 ESP-IDF 설치

```bash
eim install
```

중간에 버전 선택 프롬프트가 나오면 안정 버전(stable)을 선택한다.

설치가 완료되면 `~/.espressif/` 아래에 ESP-IDF와 툴체인이 설치된다.

- **⚠️ 트러블슈팅: Python venv FAIL 오류**
    
    `eim install` 실행 시 아래 오류가 발생할 수 있다.
    
    ```
    [PASS] Python Version
    [PASS] pip
    [FAIL] venv
           Hint: Reinstall Python from python.org
    [PASS] Standard Library
    [PASS] ctypes
    [FAIL] SSL/HTTPS
    ```
    
    **원인**: Homebrew Python은 `venv` 모듈이 분리되어 있고, 시스템 기본 `python3` (`/usr/bin/python3`, 3.9.x)이 사용되기 때문이다.
    
    - **해결 1: python.org에서 Python 3.12 설치**
        
        터미널에서 직접 다운로드:
        
        ```bash
        curl -O https://www.python.org/ftp/python/3.12.10/python-3.12.10-macos11.pkg
        open python-3.12.10-macos11.pkg
        ```
        
        `.pkg` 설치 완료 후 인증서 설치:
        
        ```bash
        /Applications/Python\ 3.12/Install\ Certificates.command
        ```
        
    - **해결 2: PATH 우선순위 변경**
        
        python.org 설치 후 `eim`이 올바른 Python을 찾도록 PATH를 잡아준다.
        
        ```bash
        export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
        ```
        
        확인:
        
        ```bash
        which python3
        python3 --version
        # Python 3.12.x 가 나와야 함
        ```
        
        > 💡 이 `export` 명령은 현재 터미널 세션에만 적용된다. 영구 적용하려면 `~/.zshrc`에 추가한다.
        > 

---

## Step 3: 환경변수 활성화

ESP-IDF를 사용하려면 **새 터미널을 열 때마다** 아래 명령어를 실행해야 한다.

```bash
. ~/.espressif/v6.0.1/esp-idf/export.sh
```

> 버전 번호(`v6.0.1`)는 설치된 버전에 따라 다를 수 있다.
> 

매번 치기 번거로우면 alias를 등록해두면 편하다:

```bash
echo 'alias get_idf="source /Users/jae/.espressif/tools/activate_idf_v6.0.1.sh"' >> ~/.zshrc
source ~/.zshrc
```

이후부터 `get_idf` 한 줄로 활성화 가능하다.

활성화 확인:

```bash
idf.py --version
# ESP-IDF v6.x.x 형태로 출력되면 성공
```

---

## Step 4: Swiftly + Swift 6.2 snapshot 설치

```bash
# Swiftly 설치
curl -L https://swift.org/install/swiftly | bash
source ~/.local/share/swiftly/env.sh

# Swift 6.2 snapshot 설치
swiftly install 6.2-snapshot

# 확인
swiftc --version
# swift-driver version: ... (6.2-dev ...) 형태면 성공
```

---

## Step 5: 예제 프로젝트 클론

```bash
git clone https://github.com/swiftlang/swift-embedded-examples.git \
  --single-branch --branch main
cd swift-embedded-examples/esp32-led-blink-sdk

# 이 프로젝트에서 6.2 snapshot 사용 지정
swiftly use 6.2-snapshot
```

- **⚠️ 트러블슈팅: 프로젝트 경로에 공백이 있을 경우**
    
    iCloud Drive 경로(`Mobile Documents`, `Apple Developer Academy` 등)처럼 **공백이 포함된 경로**에서 빌드하면 `swiftc`가 경로를 쪼개서 읽는 오류가 발생한다.
    
    ```
    error: unexpected input file: Documents/com~apple~CloudDocs/Apple
    error: unexpected input file: Develeoper
    error: unexpected input file: Academy/5.
    ```
    
    **해결**: 프로젝트를 공백 없는 로컬 경로로 옮긴다.
    
    ```bash
    mkdir -p ~/projects
    cp -r ~/path/to/swift-embedded-examples ~/projects/swift-embedded-examples
    cd ~/projects/swift-embedded-examples/esp32-led-blink-sdk
    ```
    
    또는 Finder에서 직접 복사해도 된다:
    
    1. `swift-embedded-examples` 폴더 찾기
    2. 홈 폴더(`/Users/사용자명`) 아래에 `projects` 폴더 생성
    3. `Option` 키를 누른 채 드래그하면 복사됨
    
    > ⚠️ **iCloud Drive 경로에서 개발하지 말 것**: 공백 문제 외에도 파일 동기화 타이밍 이슈가 발생할 수 있다. 개발 폴더는 항상 `~/projects/` 같은 로컬 경로에 두는 것을 권장한다.
    > 

---

## Step 6: 빌드

```bash
# 빌드 캐시가 남아있으면 반드시 삭제 후 진행
rm -rf build

# C3 타겟 설정
idf.py set-target esp32c3

# 빌드
idf.py build
```

> 💡 빌드가 실패하고 `ninja: error: build.ninja` 관련 오류가 나오면 `rm -rf build` 후 처음부터 다시 시도한다.
> 

---

## Step 7: 플래시 + 모니터

보드를 USB-C로 연결한 뒤:

```bash
idf.py flash monitor
```

- 연결 포트를 명시하려면:
    
    ```bash
    # 포트 목록 확인
    ls /dev/cu.*
    
    # 포트 지정
    idf.py -p /dev/cu.usbmodem1234 flash monitor
    ```
    

모니터 종료: `Ctrl + ]`

---

### 예상 출력

플래시 성공 시 시리얼 모니터에 아래와 같이 출력된다:

```
Hello from Swift on ESP32-C3!
```

LED가 GPIO8 핀에서 깜빡이기 시작하면 성공이다.

---

## 코드 살펴보기

예제의 핵심 파일은 `main/Main.swift`다.

```swift
@_cdecl("app_main")
func app_main() {
    print("Hello from Swift on ESP32-C3!")

    let blinkDelayMs: UInt32 = 500
    let led = Led(gpioPin: 8)   // ESP32-C3 내장 LED = GPIO8

    var ledOn = false
    while true {
        led.setLed(value: ledOn)
        ledOn.toggle()
        vTaskDelay(blinkDelayMs / (1000 / UInt32(configTICK_RATE_HZ)))
    }
}
```

> ⚠️ ESP32-C3 Super Mini의 내장 LED(GPIO8)는 **반전 로직**이다. `true`가 OFF, `false`가 ON이므로 필요 시 `!ledOn`으로 반전해서 사용한다.
> 

---

## 자주 발생하는 오류 요약

| 오류 | 원인 | 해결 |
| --- | --- | --- |
| `zsh: command not found: idf.py` | export.sh 미실행 | `. ~/.espressif/v6.x.x/esp-idf/export.sh` |
| `[FAIL] venv` | Homebrew Python 사용 중 | python.org에서 3.12 설치 후 PATH 변경 |
| `[FAIL] SSL/HTTPS` | 인증서 미설치 | `Install Certificates.command` 실행 |
| `error: unexpected input file` | 경로에 공백 포함 | 로컬 경로(`~/projects/`)로 이동 |
| `ninja: build.ninja not found` | 빌드 캐시 오염 | `rm -rf build` 후 재빌드 |
| 모니터에 이전 C++ 코드 출력 | flash 없이 monitor만 실행 | `idf.py flash monitor` 함께 실행 |

---

## 참고 링크

- [Embedded Swift 공식 문서](https://www.swift.org/get-started/embedded/)
- [swift-embedded-examples 레포지토리](https://github.com/swiftlang/swift-embedded-examples)
- [ESP-IDF macOS 설치 가이드](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/macos-setup.html)
- [Swiftly 설치 가이드](https://www.swift.org/install/)