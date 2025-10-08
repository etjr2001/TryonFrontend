//
//  WidthResolution.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 30/9/25.
//

import SwiftUI

struct WidthResolution: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var refreshTrigger: Bool
    
    @FocusState private var isWidthFocused: Bool
    
    @State private var widthErrorMessage: String = ""
    @State private var showWidthErrorMessage: Bool = false
    @State private var widthResolutionText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Image Width")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Enter width resolution (multiple of 64)", text: $widthResolutionText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(showWidthErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                )
                .focused($isWidthFocused)
                .onChange(of: widthResolutionText) {
                    let filtered = widthResolutionText.filter {
                        "1234567890,.".contains($0)}
                    if filtered != widthResolutionText {
                        widthResolutionText = filtered
                    }
                }
                .onChange(of: isWidthFocused) { oldFocusState, newFocusState in
                    if !newFocusState {
                        let widthResolution = formatWidth()
                        widthResolutionText = String(widthResolution)
                        viewModel.updateWidthResolution(to: widthResolution)
                    }
                }
                .onChange(of: refreshTrigger) {
                    widthResolutionText = String(viewModel.widthResolution)
                }
            
            InfoButton(infoTitle: "IDM-VTON Image Width", infoText: "Tryon image width. Default 768, maximum 2048. Multiple of 64.")
        }
        .padding(.vertical, 0.5)
        .onAppear {
            widthResolutionText = String(viewModel.widthResolution)
        }
        
        if (showWidthErrorMessage) {
            HStack {
                Text(widthErrorMessage)
                    .foregroundColor(Color.red)
                    .padding(4)
            }
            .padding(.vertical, 0.5)
        }
    }
    
    func formatWidth() -> Int {
        guard let number = Int(widthResolutionText.replacingOccurrences(of: ",", with: "")) else {
            widthErrorMessage = "Invalid width resolution \(widthResolutionText).\nWidth resolution set to 768 (default)."
            showWidthErrorMessage = true
            return 768
        }
        
        if (number < 64) {
            widthErrorMessage = "Resolution must be at least 64.\nResolution set automatically to 64."
            showWidthErrorMessage = true
            return 64
        }
        
        if (number > 2048) {
            widthErrorMessage = "Resolution is at most 2048.\nResolution set automatically to 2048."
            showWidthErrorMessage = true
            return 2048
        }
        
        let rounded = Int(round(Double(number) / 64.0)) * 64
        
        if (rounded != number) {
            widthErrorMessage = "Resolution must be a multiple of 64.\nResolution set automatically to multiple of 64."
            showWidthErrorMessage = true
        } else {
            showWidthErrorMessage = false
        }
        
        return rounded
    }
}
