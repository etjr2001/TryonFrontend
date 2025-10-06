//
//  Strength.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct Strength: View {
    @EnvironmentObject var viewModel: ViewModel
    
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
            InfoButton(infoTitle: "IDM-VTON Strength", infoText: "Tryon image strength. Determines how strongly the garment appearance is applied. Default 1.0. Maximum 2048. To 1 decimal place.")
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
        
        if (number > 2048) {
            strengthErrorMessage = "Strength is at most 2048.\nStrength set automatically to 2048."
            showStrengthErrorMessage = true
            return 2048
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
