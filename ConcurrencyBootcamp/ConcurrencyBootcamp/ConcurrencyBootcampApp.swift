//
//  ConcurrencyBootcampApp.swift
//  ConcurrencyBootcamp
//
//  Created by Uri on 6/7/24.
//

import SwiftUI

@main
struct ConcurrencyBootcampApp: App {
    var body: some Scene {
        WindowGroup {
            DownloadImageAsync()
        }
    }
}
