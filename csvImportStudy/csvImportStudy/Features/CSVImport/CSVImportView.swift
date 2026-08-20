//
//  ContentView.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/19/26.
//
// file importer로 파일 경로 선택, .fileImporter의 result에 파일 url이 저장됨
// 이후 viewModel에 있는 loadCSV라는 함수에 전달된 url의 파일을 읽어 변수 csvText 변수에 저장


import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct CSVImportView: View {
    @State private var isShowingFileImporter = false
    @State private var viewModel = CSVImportViewModel()
    
    var body: some View {
        VStack {
            Button("CSV 선택") {
                isShowingFileImporter = true
            }
            
//            ScrollView {
//                Text(viewModel.errorMessage ?? viewModel.csvText)
//                // .textSelection: Text를 드래그해서 복사할 수 있게 해주는 modifier. 버튼은 아니고, 텍스트 선택 기능만 켠다.
//                    .textSelection(.enabled)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//            }
            
            if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(       // 얜 뭐임?
                    "CSV 가져오기 실패",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if let parsedCSV = viewModel.parsedCSV {
                List(parsedCSV.rows) { row in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CSV \(row.rowNumber)번째 행")
                            .font(.headline)

                        ForEach(parsedCSV.headers, id: \.self) { header in
                            HStack(alignment: .top) {
                                Text(header)
                                    .fontWeight(.semibold)
                                    .frame(width: 80, alignment: .leading)

                                Text(row.values[header] ?? "")
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                ContentUnavailableView(
                    "선택된 CSV가 없습니다",
                    systemImage: "tablecells",
                    description: Text("CSV 선택 버튼을 눌러 파일을 선택하세요.")
                )
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
                viewModel.loadCSV(from: url) // 파일 선택이 끝나면 성공/실패 결과가 result로 들어오고, 그 결과를 viewmodel에 있는 loadCSV(from:)에서 처리.
                
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
