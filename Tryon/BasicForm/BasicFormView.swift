//
//  BasicFormView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

struct BasicFormView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var sheetCancelled: Bool
    
    private let pages: [WorkflowEditPage] = [
        .uploadHumanImage,
        .uploadGarmentImage
    ]
    
    var body: some View {
        WorkflowNavigationView(pages: pages,
                               runWorkflow: {
            try await viewModel.runDefaultAndUpdateImage()
        },
                               sheetCancelled: $sheetCancelled
        )
            .environmentObject(viewModel)
    }
}
