//
//  SwiftData_StudyApp.swift
//  SwiftData_Study
//
//  Created by Jaebin Ahn on 5/29/26.
//

import SwiftUI
import SwiftData

@main
struct SwiftData_StudyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Friend.self, Gift.self])
        }
    }
}
