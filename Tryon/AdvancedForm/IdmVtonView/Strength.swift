//
//  Strength.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct Strength: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var refreshTrigger: Bool
    
    @FocusState private var isFocused: Bool
    
    @State private var strengthErrorMessage: String = ""
    @State private var showStrengthErrorMessage: Bool = false
    @State private var strengthText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Strength")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Enter strength", text: $strengthText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(showStrengthErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                )
                .focused($isFocused)
                .onChange(of: strengthText) {
                    let filtered = strengthText.filter {
                        "1234567890.".contains($0)}
                    if filtered != strengthText {
                        strengthText = filtered
                    }
                }
                .onChange(of: isFocused) { oldFocusState, newFocusState in
                    if (!newFocusState){
                        let strength = formatStrength()
                        strengthText = String(strength)
                        viewModel.updateStrength(to: strength)
                    }
                }
                .onChange(of: refreshTrigger) {
                    strengthText = String(viewModel.strength)
                }
            InfoButton(infoTitle: "IDM-VTON Strength", infoText: "Tryon image strength. Determines how strongly the garment appearance is applied. Default 1.0. The value of strength should be between 0 to 1.0. To 1 decimal place.")
        }
        .padding(.vertical, 0.5)
        .onAppear {
            strengthText = String(viewModel.strength)
        }
        
        if (showStrengthErrorMessage) {
            HStack {
                Text(strengthErrorMessage)
                    .foregroundColor(Color.red)
                    .padding(4)
            }
            .padding(.vertical, 0.5)
        }
    }
    
    func formatStrength() -> Double {
        guard let number = Double(strengthText.replacingOccurrences(of: ",", with: "")) else {
            strengthErrorMessage = "Invalid strength \(strengthText).\nStrength set to 1.0 (default)."
            showStrengthErrorMessage = true
            return 1.0
        }
        
        if (number < 0) {
            strengthErrorMessage = "Strength must be at least 0.\nStrength set automatically to 0."
            showStrengthErrorMessage = true
            return 0
        }
        
        if (number > 1) {
            strengthErrorMessage = "Strength is at most 1.0.\nStrength set automatically to 1.0."
            showStrengthErrorMessage = true
            return 1
        }
        
        let rounded = round(number * 10) / 10
        
        if (rounded != number) {
            strengthErrorMessage = "Strength rounded to nearest 1 decimal place."
            showStrengthErrorMessage = true
        } else {
            showStrengthErrorMessage = false
        }
        
        return rounded
    }
}
