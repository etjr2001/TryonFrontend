//
//  IdmVtonView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 29/9/25.
//

import SwiftUI

struct IdmVtonView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var showLoading: Bool = false
    
    var labelWidth: CGFloat = 120
    var fieldWidth: CGFloat = 215
    
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var refreshTrigger: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                
                WeightDType(labelWidth: labelWidth, fieldWidth: fieldWidth)
                WidthResolution(refreshTrigger: $refreshTrigger, labelWidth: labelWidth, fieldWidth: fieldWidth)
                HeightResolution(refreshTrigger: $refreshTrigger, labelWidth: labelWidth, fieldWidth: fieldWidth)
                NumInferenceSteps(refreshTrigger: $refreshTrigger, labelWidth: labelWidth, fieldWidth: fieldWidth)
                GuidanceScale(refreshTrigger: $refreshTrigger, labelWidth: labelWidth, fieldWidth: fieldWidth)
                Strength(refreshTrigger: $refreshTrigger, labelWidth: labelWidth, fieldWidth: fieldWidth)
                Seed(refreshTrigger: $refreshTrigger, labelWidth: labelWidth, fieldWidth: fieldWidth)
                NegativePrompt(labelWidth: labelWidth, fieldWidth: fieldWidth)
                
                Button {
                    viewModel.resetPipelineParameters()
                    showErrorMessage = false
                    refreshTrigger.toggle()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                
                
                if (showErrorMessage) {
                    HStack {
                        Text(errorMessage)
                            .foregroundColor(Color.red)
                            .padding(4)
                    }
                    .padding(.vertical, 0.5)
                }
                
                if showLoading {
                    Spacer()
                    ProgressView("Loading \(ImageType.mask.type) Image...")
                }
            }
        }
    }
    
}
