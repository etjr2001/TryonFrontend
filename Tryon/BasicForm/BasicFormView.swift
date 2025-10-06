//
//  BasicFormView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

struct BasicFormView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    private let pages: [WorkflowEditPage] = [
        .uploadImage(imageType: .human),
        .uploadImage(imageType: .garment),
    ]
    
    var body: some View {
        WorkflowNavigationView(pages: pages) {
            await runDefaultWorkflow()
        }
        .environmentObject(viewModel)
    }
    
    private func runDefaultWorkflow() async {
        
    }
}
