//
//  CSVImportService.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//

import Foundation
import SwiftData

@MainActor // 얜 뭐임?
// 답변: 이 타입의 코드는 Main Actor에서 실행되도록 제한하는 표시. SwiftData의 ModelContext와 화면 상태 변경은 보통 메인 스레드에서 다루는 게 안전해서 붙임.
// 이는 특정 코드가 메인 스레드에서 실행되는 것을 보장한다
struct CSVImportService {
    private let fileLoader = CSVFileLoader()
    private let parser = CSVParser()
    private let recordMapper = CSVRecordMapper()

    func importCSV(
        from url: URL,
        into modelContext: ModelContext
    ) throws -> Int {
        // 1. 파일 로딩
        let text = try fileLoader.load(from: url)

        // 2. CSV 파싱
        let parsedCSV = try parser.parse(text)

        // 3. 모든 행을 ImportedRecord로 변환
        let records = try parsedCSV.rows.map { row in
            try recordMapper.map(
                row: row,
                sourceFileName: url.lastPathComponent
            )
        }

        // 4. 모든 변환이 성공한 다음 저장 시작
        do {
            for record in records {
                modelContext.insert(record)
            }

            if modelContext.hasChanges {
                try modelContext.save()
            }

            return records.count
        } catch {
            modelContext.rollback() // model context의 rollback은 뭐지?
            // 답변: 아직 저장(save)되지 않은 ModelContext의 변경사항을 취소하는 기능. 일부 record insert 후 save 실패가 나면, 중간에 넣은 변경을 되돌리기 위해 사용.
            throw error
        }
    }
}
