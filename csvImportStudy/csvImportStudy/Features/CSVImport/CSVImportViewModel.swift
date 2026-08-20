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

    private let fileLoader = CSVFileLoader()
    
    // 기존 CSVImportView에 있던 함수랑 뭐가 다르지?
    // ViewModel의 loadCSV: View에서 URL을 받은 뒤, 실제 파일 읽기는 CSVFileLoader에게 맡기고 화면에 보여줄 상태만 업데이트.
    func loadCSV(from url: URL) {
        do {
            csvText = try fileLoader.load(from: url)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // localizedDescription 가 뭐지?
    // handleFileSelectionError: 파일 선택 자체가 실패했을 때 에러 메시지를 화면 상태에 저장. localizedDescription은 사용자에게 보여줄 수 있는 에러 설명 문자열.
    func handleFileSelectionError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}
