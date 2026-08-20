//
//  CSVFileLoader.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//

import Foundation

struct CSVFileLoader {
    func load(from url: URL) throws -> String {
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        guard hasAccess else {
            throw CSVImportError.permissionDenied
        }
        
        // 이게 디폴트?
        // 답변: defer는 디폴트값이 아니라 Swift 문법. "현재 함수가 끝날 때 실행할 코드를 미리 등록하는 역할"
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        return try String(
            contentsOf: url,
            encoding: .utf8
        )
    }
}

// 기존 CSVImportView에 있던거랑은 어떤게 다르지?
// 답변: View에 있던 파일 읽기 로직을 CSVFileLoader로 분리한 것. View는 화면과 사용자 입력 처리, ViewModel은 상태 관리, CSVFileLoader는 실제 파일 읽기만 담당.
