//
//  ContentView.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/19/26.
//
// file importer로 파일 경로 선택, .fileImporter의 result에 파일 url이 저장됨
// 이후 loadCSV라는 함수에 전달된 url의 파일을 읽어 변수 csvText 변수에 저장


import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isShowingFileImporter = false
    @State private var csvText = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Button("CSV 선택") {
                isShowingFileImporter = true
            }

            ScrollView {
                Text(errorMessage ?? csvText)
                    // .textSelection: Text를 드래그해서 복사할 수 있게 해주는 modifier. 버튼은 아니고, 텍스트 선택 기능만 켠다.
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        // SwiftUI가 제공하는 파일 선택 modifier. 이 메서드의 실행 결과로 loadCSV가 실행된다.
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.commaSeparatedText], // 허용되는 파일의 타입
            allowsMultipleSelection: false              // 여러 파일선택 허용할건지 여부
        ) { result in
            // 파일 선택이 끝나면 성공/실패 결과가 result로 들어오고, 그 결과를 loadCSV(from:)에서 처리.
            loadCSV(url: result)
        }
    }

    // loadCSV 함수의 매개변수: .fileImporter에서 반환환하는 url 혹은 error
    private func loadCSV(url result: Result<[URL], Error>) {
        // do-catch: do 안에서 try가 실패하면 즉시 catch 블록으로 이동.
        do {
            guard let url = try result.get().first else {
                return
            }

            // startAccessingSecurityScopedResource(): 사용자가 선택한 외부 파일을 앱 샌드박스 안에서 읽기 위한 임시 접근 권한 요청.
            let hasAccess = url.startAccessingSecurityScopedResource()

            guard hasAccess else {
                errorMessage = "선택한 파일의 접근 권한을 얻지 못했습니다."
                return
            }

            // defer: 현재 함수가 끝날 때 반드시 실행되는 코드. 파일 접근을 시작했으니 끝날 때 해제.
            defer {
                url.stopAccessingSecurityScopedResource()
            }

            // String(contentsOf:encoding:): 파일 내용을 읽어서 String으로 변환. csvText도 String 타입.
            csvText = try String(
                contentsOf: url,
                encoding: .utf8
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
