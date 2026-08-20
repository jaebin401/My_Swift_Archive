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
    case columnCountMismatch(
        row: Int,
        expected: Int,
        actual: Int
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

        case .columnCountMismatch(
            let row,
            let expected,
            let actual
        ):
            return """
            \(row)번째 행의 열 개수가 올바르지 않습니다.
            예상: \(expected), 실제: \(actual)
            """
        }
    }
}
