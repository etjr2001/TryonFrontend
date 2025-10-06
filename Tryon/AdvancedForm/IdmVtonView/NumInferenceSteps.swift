//
//  NumInferenceSteps.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 30/9/25.
//

import SwiftUI

struct NumInferenceSteps: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isFocused: Bool
    
    @State private var numInferenceStepsErrorMessage: String = ""
    @State private var showNumInferenceStepsErrorMessage: Bool = false
    @State private var numInferenceStepsText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Inference steps")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Number of inference steps", text: $numInferenceStepsText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(showNumInferenceStepsErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                )
                .focused($isFocused)
                .onChange(of: numInferenceStepsText) {
                    let filtered = numInferenceStepsText.filter {
                        "1234567890".contains($0)}
                    if filtered != numInferenceStepsText {
                        numInferenceStepsText = filtered
                    }
                }
                .onChange(of: isFocused) { oldFocusState, newFocusState in
                    if !newFocusState {
                        let numInferenceSteps = formatNumInferenceSteps()
                        numInferenceStepsText = String(numInferenceSteps)
                        viewModel.updateNumInferenceSteps(to: numInferenceSteps)
                    }
                }
            InfoButton(infoTitle: "IDM-VTON Num Inference Steps", infoText: "Tryon number of inference steps. The higher the number, the longer it will take to generate the output. Default 30, maximum 1000.")
        }
        .onAppear {
            numInferenceStepsText = String(viewModel.numInferenceSteps)
        }
        
        if (showNumInferenceStepsErrorMessage) {
            HStack {
                Text(numInferenceStepsErrorMessage)
                    .foregroundColor(Color.red)
                    .padding(4)
            }
            .padding(.vertical, 0.5)
        }
    }
    
    func formatNumInferenceSteps() -> Int {
        guard let number = Int(numInferenceStepsText) else {
            numInferenceStepsErrorMessage = "Invalid number of inference steps \(numInferenceStepsText).\nNumber of inference steps set automatically to 30 (default)."
            showNumInferenceStepsErrorMessage = true
            return 30
        }
        
        if (number < 1) {
            numInferenceStepsErrorMessage = "Number of inference steps must be at least 1.\nResolution set automatically to 1."
            showNumInferenceStepsErrorMessage = true
            return 1
        }
        
        if (number > 1000) {
            numInferenceStepsErrorMessage = "Number of inference steps is at most 1000.\nNumber of inference steps set to 1000."
            showNumInferenceStepsErrorMessage = true
            return 1000
        }
        
        showNumInferenceStepsErrorMessage = false
        
        return number
    }
}
