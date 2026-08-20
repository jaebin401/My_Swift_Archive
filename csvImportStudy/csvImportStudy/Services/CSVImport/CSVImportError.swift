//
//  CSVImportError.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//

import Foundation

enum CSVImportError: LocalizedError {
    case permissionDenied
    case invalidEncoding
    case emptyFile
    case missingHeader
    case duplicateHeader(String)
    
    // enum에서 이런 매개변수가 나오는건 뭐임? 이런걸 어떤 개념이라고 부르지
    // 답변: Associated Value(연관값)라고 부름. enum case가 단순 이름만 가지는 게 아니라, 그 에러에 필요한 추가 데이터를 함께 저장할 수 있음.
    case columnCountMismatch(
        row: Int,
        expected: Int,
        actual: Int
    )
    
    case invalidValue(
        row: Int,
        column: String,
        value: String,
        expectedType: String
    )

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "파일 접근 권한을 얻지 못했습니다."

        case .invalidEncoding:
            return "지원하지 않는 문자 인코딩입니다."

        case .emptyFile:
            return "CSV 파일이 비어 있습니다."

        case .missingHeader:
            return "CSV의 헤더를 찾지 못했습니다."

        case .duplicateHeader(let header):
            return "중복된 헤더가 있습니다: \(header)"

        // 얘는 그러면 해당 case일 때 각 상수들의 내용을 return에 활용하는거임?
        // 답변: 맞음. .columnCountMismatch case 안에 저장된 row, expected, actual 값을 let으로 꺼내서 에러 메시지 문자열에 넣는 구조.
        case .columnCountMismatch(
            let row,
            let expected,
            let actual
        ):
            return """
            \(row)번째 행의 열 개수가 올바르지 않습니다.
            예상: \(expected), 실제: \(actual)
            """
            
        case .invalidValue(
            let row,
            let column,
            let value,
            let expectedType
        ):
            return """
            \(row)번째 행의 \(column) 값을 변환할 수 없습니다.
            값: \(value)
            필요한 타입: \(expectedType)
            """
        }
    }
}
