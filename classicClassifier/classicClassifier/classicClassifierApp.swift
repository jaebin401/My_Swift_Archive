//
//  classicClassifierApp.swift
//  classicClassifier
//
//  Created by Jaebin Ahn on 6/10/26.
//

import SwiftUI

@main
struct classicClassifierApp: App {
    // WCSession은 앱 시작 시 가능한 빨리 activate해야 함
    private let connector = PhoneConnector.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
