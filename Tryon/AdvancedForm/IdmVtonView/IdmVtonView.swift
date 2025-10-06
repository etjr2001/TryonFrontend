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
    @State private var showTryOnImage: Bool = false
    
    private var labelWidth: CGFloat = 120
    private var fieldWidth: CGFloat = 215
    
    private var showAdvancedOptions: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                if showAdvancedOptions{
                    WeightDType(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    WidthResolution(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    HeightResolution(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    NumInferenceSteps(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    GuidanceScale(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    Strength(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    Seed(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    GarmentDescription(labelWidth: labelWidth, fieldWidth: fieldWidth)
                    NegativePrompt(labelWidth: labelWidth, fieldWidth: fieldWidth)
                }
            }
        }
    }
    
}

enum ResolutionError: Error {
    case invalidResolution
}
