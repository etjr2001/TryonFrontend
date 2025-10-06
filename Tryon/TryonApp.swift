//
//  TryonApp.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

@main
struct TryonApp: App {
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
