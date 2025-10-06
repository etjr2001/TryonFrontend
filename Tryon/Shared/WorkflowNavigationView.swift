//
//  WorkflowNavigationView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

struct WorkflowNavigationView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    let pages: [WorkflowEditPage]
    let runWorkflow: () async -> Void
    
    @State private var currentPageIndex: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                if currentPageIndex > 0 {
                    Button("Previous") {
                        currentPageIndex -= 1
                    }
                } else if currentPageIndex == 0 {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                Spacer()
                
                if currentPageIndex < pages.count - 1 {
                    Button("Next") {
                        currentPageIndex += 1
                    }
                } else {
                    Button("Generate try-on") {
                        Task {
                            await runWorkflow()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            
            pages[currentPageIndex]
                .view(with: viewModel)
                .padding()
            
            Spacer()
        }
    }
}
