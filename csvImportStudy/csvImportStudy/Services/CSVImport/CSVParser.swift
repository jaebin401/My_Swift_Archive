//
//  CSVParser.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//

import Foundation

// 파싱을할 때 바로 각 열 속성별로 구분하지 않고 이렇게 배열을 중첩적으로 거치면서 하는 이유는?
// 답변: CSV는 파일마다 헤더와 열 구성이 달라질 수 있어서 고정 속성으로 바로 만들기 어렵다. 먼저 headers와 rows로 일반화해서 저장하면 어떤 CSV 구조든 읽기 쉬움.
struct ParsedCSV {
    let headers: [String]
    let rows: [ParsedCSVRow]
}

struct ParsedCSVRow: Identifiable {
    let id = UUID()
    let rowNumber: Int
    let values: [String: String]
}

struct CSVParser {
    
    // 여기서 들어가는 text는 view model의 file loader로 입력됨
    func parse(_ text: String) throws -> ParsedCSV {
        
        var normalizedText = text

        // UTF-8 BOM 제거
        if normalizedText.first == "\u{FEFF}" {
            normalizedText.removeFirst()
        }

        let lines = normalizedText
            .split(whereSeparator: \.isNewline)
            .map(String.init)
        
        // throw의 정확한 정의와 기능이 뭐임? 그냥 에러 던지는건가?
        // 답변: throw는 현재 함수 실행을 중단하고 에러를 호출한 쪽으로 전달하는 문법. 이 함수는 throws라서 CSVImportError.emptyFile 같은 에러를 밖으로 던질 수 있음.
        guard !lines.isEmpty else {
            throw CSVImportError.emptyFile
        }

        let headers = splitLine(lines[0])

        guard !headers.isEmpty else {
            throw CSVImportError.missingHeader
        }

        if let duplicateHeader = findDuplicateHeader(in: headers) {
            throw CSVImportError.duplicateHeader(duplicateHeader)
        }
        
        // let(상수)에서 try 가 있는건 뭐임? 조건적으로 상수를 선언하는건가?
        // 답변: 조건적 선언은 아니고, rows 값을 만드는 과정에서 에러가 날 수 있다는 표시. try가 실패하면 rows에 값이 들어가기 전에 함수가 중단되고 catch 쪽으로 넘어감.
        let rows = try lines
            .dropFirst()
            .enumerated()
            .map { offset, line in
                let rowNumber = offset + 2
                let fields = splitLine(line)

                guard fields.count == headers.count else {
                    throw CSVImportError.columnCountMismatch(
                        row: rowNumber,
                        expected: headers.count,
                        actual: fields.count
                    )
                }

                let values = Dictionary(
                    uniqueKeysWithValues: zip(headers, fields)
                )

                return ParsedCSVRow(
                    rowNumber: rowNumber,
                    values: values
                )
            }

        return ParsedCSV(
            headers: headers,
            rows: rows
        )
    }

    // 여기서 괄호 내에 _는 뭐임?
    // 답변: _는 함수를 호출할 때 외부 매개변수 이름을 생략하겠다는 뜻. 그래서 splitLine(line:)이 아니라 splitLine(line)처럼 호출 가능.
    private func splitLine(_ line: String) -> [String] {
        line
            .split(
                separator: ",",
                omittingEmptySubsequences: false
            )
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
    }

    // 이 함수의 기능과 목적은? 구체적인 로직도 궁금함
    // 답변: 헤더 배열에서 같은 이름이 두 번 나오는지 검사하는 함수. Set에 이미 본 헤더를 저장해두고, 같은 헤더를 다시 만나면 그 헤더 이름을 반환.
    private func findDuplicateHeader(
        in headers: [String]
    ) -> String? {
        var existingHeaders = Set<String>()

        for header in headers {
            if existingHeaders.contains(header) {
                return header
            }

            existingHeaders.insert(header)
        }

        return nil
    }
}
