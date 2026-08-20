//
//  CSVImportService.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//

import Foundation
import SwiftData

@MainActor // 얜 뭐임?
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
            throw error
        }
    }
}
