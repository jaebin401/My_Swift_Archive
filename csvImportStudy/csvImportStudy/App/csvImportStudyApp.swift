//
//  csvImportStudyApp.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/19/26.
//

import SwiftUI
import SwiftData

@main
struct csvImportStudyApp: App {
    var body: some Scene {
        WindowGroup {
            CSVImportView()
        }
        .modelContainer(for: ImportedRecord.self)
    }
}
