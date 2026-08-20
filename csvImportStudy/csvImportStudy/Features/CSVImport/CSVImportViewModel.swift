//
//  CSVImportViewModel.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//
import SwiftUI

@MainActor
@Observable

final class CSVImportViewModel {
    var csvText = ""
    var errorMessage: String?
    var parsedCSV: ParsedCSV?

    private let fileLoader = CSVFileLoader()
    private let parser = CSVParser()
    private let recordMapper = CSVRecordMapper()
    
    // 기존 CSVImportView에 있던 함수랑 뭐가 다르지?
    // ViewModel의 loadCSV: View에서 URL을 받은 뒤, 실제 파일 읽기는 CSVFileLoader에게 맡기고 화면에 보여줄 상태만 업데이트.
    func loadCSV(from url: URL) {
        do {
            let text = try fileLoader.load(from: url)
            let parsedCSV = try parser.parse(text)

            let records = try parsedCSV.rows.map { row in
                try recordMapper.map(
                    row: row,
                    sourceFileName: url.lastPathComponent
                )
            }

            csvText = text
            self.parsedCSV = parsedCSV
            errorMessage = nil

            for record in records {
                let nameText = record.name ?? "nil"
                let ageText = record.age.map { String($0) } ?? "nil"
                let heightText = record.height.map { String($0) } ?? "nil"

                print(
                    """
                    이름: \(nameText)
                    나이: \(ageText)
                    키: \(heightText)
                    파일: \(record.sourceFileName)
                    행: \(record.sourceRowNumber)
                    """
                )
            }
        } catch {
            parsedCSV = nil
            errorMessage = error.localizedDescription
        }
    }
    // localizedDescription 가 뭐지?
    // handleFileSelectionError: 파일 선택 자체가 실패했을 때 에러 메시지를 화면 상태에 저장. localizedDescription은 사용자에게 보여줄 수 있는 에러 설명 문자열.
    func handleFileSelectionError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}
