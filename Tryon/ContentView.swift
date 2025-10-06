//
//  ContentView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    enum ActiveSheet: Identifiable {
        case basicForm
        case advancedForm
        
        var id: Int {
            hashValue
        }
    }
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        VStack {
            Button("Generate basic try-on") {
                activeSheet = .basicForm
            }
            .buttonStyle(.borderedProminent)
            .padding()
            Button("Generate with advanced options") {
                activeSheet = .advancedForm
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .basicForm:
                BasicFormView()
                    .environmentObject(viewModel)
            case .advancedForm:
                AdvancedFormView()
                    .environmentObject(viewModel)
            }
        }
        .task {
            await viewModel.fetchWorkflows()
            await viewModel.fetchSampleImages()
        }
    }
}

#Preview {
    let mockVM = ViewModel()
    
    ContentView()
        .environmentObject(mockVM)
}
