//
//  csvExport_study
//
//  Created by Jaebin Ahn on 5/21/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVExportView: View {
    // 1. TextField에 바인딩될 데이터
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var field3: String = ""
    
    // 2. 생성된 CSV 파일의 URL (공유 시트에 넘길 대상)
    @State private var csvFileURL: URL?
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $field1)
            TextField("Value", text: $field2)
            TextField("Note", text: $field3)
            
            Button("Export to CSV") {
                csvFileURL = generateCSV()
            }
            .buttonStyle(.borderedProminent)
            
            // 3. CSV 파일이 생성되면 ShareLink 표시
            if let url = csvFileURL {
                ShareLink(
                    item: url,
                    //preview: SharePreview(, image: Image(systemName: "text.document"))
                ) {
                    Label("Share CSV", systemImage: "square.and.arrow.up")
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding()
    }
    
    // 4. CSV 문자열 생성 → 파일 쓰기 → URL 반환
    private func generateCSV() -> URL? {
        // 헤더 + 한 줄 데이터
        let header = "name,value,note\n"
        let row = "\(field1),\(field2),\(field3)\n"
        let csvString = header + row
        
        // 파일 제목 지정, 날짜 포함
        let fileName = "export_\(Date()).csv"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        
        // 문자열을 파일로 쓰기
        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("CSV write failed: \(error)")
            return nil
        }
    }
}
#Preview {
    CSVExportView()
}
