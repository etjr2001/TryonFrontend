//
//  HeightResolution.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 30/9/25.
//

import SwiftUI

struct HeightResolution: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var refreshTrigger: Bool
    
    @FocusState private var isHeightFocused: Bool
    
    @State private var heightErrorMessage: String = ""
    @State private var showHeightErrorMessage: Bool = false
    @State private var heightResolutionText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Image Height")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Enter height resolution (multiple of 64)", text: $heightResolutionText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(showHeightErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                )
                .focused($isHeightFocused)
                .onChange(of: heightResolutionText) {
                    let filtered = heightResolutionText.filter {
                        "1234567890,.".contains($0)}
                    if filtered != heightResolutionText {
                        heightResolutionText = filtered
                    }
                }
                .onChange(of: isHeightFocused) { oldFocusState, newFocusState in
                    if (!newFocusState){
                        let heightResolution = formatHeight()
                        heightResolutionText = String(heightResolution)
                        viewModel.updateHeightResolution(to: heightResolution)
                    }
                }
                .onChange(of: refreshTrigger) {
                    showHeightErrorMessage = false
                    heightResolutionText = String(viewModel.heightResolution)
                }
            InfoButton(infoTitle: "IDM-VTON Image Height", infoText: "Tryon image height. Default 1024, maximum 2048. Multiple of 64.")
        }
        .padding(.vertical, 0.5)
        .onAppear {
            heightResolutionText = String(viewModel.heightResolution)
        }
        
        if (showHeightErrorMessage) {
            HStack {
                Text(heightErrorMessage)
                    .foregroundColor(Color.red)
                    .padding(4)
            }
            .padding(.vertical, 0.5)
        }
    }
    
    func formatHeight() -> Int {
        guard let number = Int(heightResolutionText.replacingOccurrences(of: ",", with: "")) else {
            heightErrorMessage = "Invalid height resolution \(heightResolutionText).\nHeight resolution set to 1024 (default)."
            showHeightErrorMessage = true
            return 1024
        }
        
        if (number < 64) {
            heightErrorMessage = "Resolution must be at least 64.\nResolution set automatically to 64."
            showHeightErrorMessage = true
            return 64
        }
        
        if (number > 2048) {
            heightErrorMessage = "Resolution is at most 2048.\nResolution set automatically to 2048."
            showHeightErrorMessage = true
            return 2048
        }
        
        let rounded = Int(round(Double(number) / 64.0)) * 64
        
        if (rounded != number) {
            heightErrorMessage = "Resolution must be a multiple of 64.\nResolution set automatically to multiple of 64."
            showHeightErrorMessage = true
        } else {
            showHeightErrorMessage = false
        }
        
        return rounded
    }

}
