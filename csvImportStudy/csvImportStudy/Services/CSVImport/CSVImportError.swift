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

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "파일 접근 권한을 얻지 못했습니다."

        case .invalidEncoding:
            return "지원하지 않는 문자 인코딩입니다."

        case .emptyFile:
            return "CSV 파일이 비어 있습니다."
        }
    }
}
