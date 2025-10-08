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
    let runWorkflow: () async throws -> Void
    
    @Binding var sheetCancelled: Bool
    
    @State private var currentPageIndex: Int = 0
    @State private var showConfirmation: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        if isLoading {
            ProgressView("Generating Try-on Image...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            
        } else {
            VStack {
                HStack {
                    if currentPageIndex > 0 {
                        Button("Previous") {
                            currentPageIndex -= 1
                        }
                    } else if currentPageIndex == 0 {
                        Button("Cancel") {
                            sheetCancelled = true
                            dismiss()
                        }
                    }
                    
                    Spacer()
                    
                    if currentPageIndex < pages.count - 1 {
                        Button("Next") {
                            currentPageIndex += 1
                        }
                    } else {
                        Button("Generate") {
                            showConfirmation = true
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
            .alert("Generate Try-on Image", isPresented: $showConfirmation) {
                Button("Confirm", role: .none) {
                    print("Confirmed")
                    Task {
                        sheetCancelled = false
                        isLoading = true
                        try await runWorkflow()
                        isLoading = false
                        dismiss()
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

