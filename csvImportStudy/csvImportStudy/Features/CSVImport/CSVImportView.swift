//
//  ContentView.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/19/26.
//
// file importer로 파일 경로 선택, .fileImporter의 result에 파일 url이 저장됨
// 이후 viewModel에 있는 loadCSV라는 함수에 전달된 url의 파일을 읽어 변수 csvText 변수에 저장


import SwiftUI
import SwiftData
import Foundation
import UniformTypeIdentifiers

struct CSVImportView: View {
    @Environment(\.modelContext)
    private var modelContext
    
    @Query(
        sort: \ImportedRecord.sourceRowNumber,
        order: .forward
    )
    private var records: [ImportedRecord]
    
    @State private var isShowingFileImporter = false
    @State private var viewModel = CSVImportViewModel()
    
    var body: some View {
        VStack {
            Button("CSV 선택") {
                    isShowingFileImporter = true
                }

                if viewModel.isImporting {
                    ProgressView("CSV 가져오는 중...")
                }

                if let errorMessage = viewModel.errorMessage { // if let이면 상수 errorMessage를 선언과 동시에 if문으로 쓰는건가?
                    ContentUnavailableView(
                        "CSV 가져오기 실패",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if records.isEmpty {
                    ContentUnavailableView(
                        "저장된 데이터가 없습니다",
                        systemImage: "externaldrive",
                        description: Text("CSV 파일을 선택하세요.")
                    )
                } else {
                    List(records) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(record.name ?? "이름 없음")
                                .font(.headline)

                            Text("본명: \(record.realName ?? "없음")")
                            Text("성별: \(record.gender ?? "없음")")

                            Text(
                                "나이: \(record.age.map { String($0) } ?? "없음")"
                            )

                            Text(
                                "키: \(record.height.map { String($0) } ?? "없음")"
                            )

                            Text(
                                "\(record.sourceFileName) · \(record.sourceRowNumber)행"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
        }
        // SwiftUI가 제공하는 파일 선택 modifier. 이 메서드의 실행 결과로 loadCSV가 실행된다.
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.commaSeparatedText], // 허용되는 파일의 타입
            allowsMultipleSelection: false              // 여러 파일선택 허용할건지 여부
        ) { result in
            
            // switch 이거 뭐임?
            // 답변: result가 .success인지 .failure인지 경우를 나눠서 처리하는 조건문. if보다 여러 케이스를 명확하게 분기할 때 사용.
            // 여기서 나오는 result.success나 result.failure는 .fileImporter 메서드에서 나오는 것
            switch result {
            case .success(let urls):
                // .success(let urls): 파일 선택이 성공했을 때 URL 배열을 urls라는 이름으로 꺼냄.
                guard let url = urls.first else { return }
                
                viewModel.importCSV(from: url, modelContext: modelContext)
                //viewModel.loadCSV(from: url) // 파일 선택이 끝나면 성공/실패 결과가 result로 들어오고, 그 결과를 viewmodel에 있는 loadCSV(from:)에서 처리.
                
            case .failure(let error):
                // .failure(let error): 파일 선택이 실패했을 때 Error 값을 error라는 이름으로 꺼냄.
                viewModel.handleFileSelectionError(error)
            }
        }
        //    // loadCSV 함수의 매개변수: .fileImporter에서 반환환하는 url 혹은 error
        //    private func loadCSV(url result: Result<[URL], Error>) {
        //        // do-catch: do 안에서 try가 실패하면 즉시 catch 블록으로 이동.
        //        do {
        //            guard let url = try result.get().first else {
        //                return
        //            }
        //
        //            // startAccessingSecurityScopedResource(): 사용자가 선택한 외부 파일을 앱 샌드박스 안에서 읽기 위한 임시 접근 권한 요청.
        //            let hasAccess = url.startAccessingSecurityScopedResource()
        //
        //            guard hasAccess else {
        //                errorMessage = "선택한 파일의 접근 권한을 얻지 못했습니다."
        //                return
        //            }
        //
        //            // defer: 현재 함수가 끝날 때 반드시 실행되는 코드. 파일 접근을 시작했으니 끝날 때 해제.
        //            defer {
        //                url.stopAccessingSecurityScopedResource()
        //            }
        //
        //            // String(contentsOf:encoding:): 파일 내용을 읽어서 String으로 변환. csvText도 String 타입.
        //            csvText = try String(
        //                contentsOf: url,
        //                encoding: .utf8
        //            )
        //        } catch {
        //            errorMessage = error.localizedDescription
        //        }
        //    }
    }
}

#Preview {
    CSVImportView()
}
