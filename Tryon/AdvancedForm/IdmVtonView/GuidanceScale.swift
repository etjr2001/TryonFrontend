//
//  GuidanceScale.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 30/9/25.
//

import SwiftUI

struct GuidanceScale: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var refreshTrigger: Bool
    
    @FocusState private var isGuidanceScaleFocused: Bool
    
    @State private var guidanceScaleErrorMessage: String = ""
    @State private var showGuidanceScaleErrorMessage: Bool = false
    @State private var guidanceScaleText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Guidance Scale")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Enter guidance scale", text: $guidanceScaleText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(showGuidanceScaleErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                )
                .focused($isGuidanceScaleFocused)
                .onChange(of: guidanceScaleText) {
                    let filtered = guidanceScaleText.filter {
                        "1234567890.".contains($0)}
                    if filtered != guidanceScaleText {
                        guidanceScaleText = filtered
                    }
                }
                .onChange(of: isGuidanceScaleFocused) { oldFocusState, newFocusState in
                    if (!newFocusState){
                        let guidanceScale = formatGuidance()
                        guidanceScaleText = String(guidanceScale)
                        viewModel.updateGuidanceScale(to: guidanceScale)
                    }
                }
                .onChange(of: refreshTrigger) {
                    showGuidanceScaleErrorMessage = false
                    guidanceScaleText = String(viewModel.guidance_scale)
                }
            InfoButton(infoTitle: "IDM-VTON Guidance Scale", infoText: "Tryon image guidance scale. Higher values give more weight to the prompt. A value of 0 gives random images. Default 2.0. To 1 decimal place.")
        }
        .padding(.vertical, 0.5)
        .onAppear {
            guidanceScaleText = String(viewModel.guidance_scale)
        }
        
        if (showGuidanceScaleErrorMessage) {
            HStack {
                Text(guidanceScaleErrorMessage)
                    .foregroundColor(Color.red)
                    .padding(4)
            }
            .padding(.vertical, 0.5)
        }
    }
    
    func formatGuidance() -> Double {
        guard let number = Double(guidanceScaleText) else {
            guidanceScaleErrorMessage = "Invalid guidance scale \(guidanceScaleText).\nGuidance scale set to 2.0 (default)."
            showGuidanceScaleErrorMessage = true
            return 2.0
        }
        
        if (number < 0) {
            guidanceScaleErrorMessage = "Warning. Negative guidance scale."
            showGuidanceScaleErrorMessage = true
        } else if (number > 3) {
            guidanceScaleText = "Warning. Higher guidance scale may result in blank images."
            showGuidanceScaleErrorMessage = true
        } else {
            showGuidanceScaleErrorMessage = false
        }
        
        let rounded = round(number * 10) / 10
        
        if (rounded != number) {
            guidanceScaleErrorMessage = "Guidance scale rounded to nearest 1 decimal place."
            showGuidanceScaleErrorMessage = true
        } else {
            showGuidanceScaleErrorMessage = false
        }
        
        return rounded
    }
}
