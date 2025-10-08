//
//  ContentView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var sheetCancelled: Bool = false
    
    enum ActiveSheet: Identifiable {
        case basicForm
        case advancedForm
        case resultView
        
        var id: Int {
            hashValue
        }
    }
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        VStack {
            Button("Generate basic try-on") {
                sheetCancelled = false
                activeSheet = .basicForm
            }
            .buttonStyle(.borderedProminent)
            .padding()
            Button("Generate with advanced options") {
                sheetCancelled = false
                activeSheet = .advancedForm
            }
            .buttonStyle(.borderedProminent)
            .padding()
            Button("View Last Result") {
                sheetCancelled = false
                activeSheet = .resultView
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .basicForm:
                BasicFormView(sheetCancelled: $sheetCancelled)
                    .environmentObject(viewModel)
            case .advancedForm:
                AdvancedFormView(sheetCancelled: $sheetCancelled)
                    .environmentObject(viewModel)
            case .resultView:
                ResultView()
                    .environmentObject(viewModel)
            }
        }
        .onChange(of: activeSheet) { oldValue, newValue in
            if newValue == nil, let lastSheet = oldValue {
                Task {
                    switch (lastSheet) {
                    case .basicForm:
                        if (!sheetCancelled) {
                            activeSheet = .resultView
                        }
                    case .advancedForm:
                        if (!sheetCancelled) {
                            activeSheet = .resultView
                        }
                    case .resultView:
                        activeSheet = nil
                    }
                }
            }
        }
        .task {
            await viewModel.fetchWorkflows()
            await viewModel.fetchSampleImages()
        }
        
    }
}

//#Preview {
//    let mockVM = ViewModel()
//
//    ContentView()
//        .environmentObject(mockVM)
//}
