//
//  NegativePrompt.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct NegativePrompt: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isFocused: Bool
    
    @State private var negativePromptText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Negative Prompt")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Text description to avoid while generating images", text: $negativePromptText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.accentColor, lineWidth: 0.5)
                )
                .focused($isFocused)
                .onChange(of: negativePromptText) {
                    let filtered = negativePromptText.replacingOccurrences(of: "[^a-zA-Z0-9 ,.]", with: "", options: .regularExpression)
                    if filtered != negativePromptText {
                        negativePromptText = filtered
                    }
                }
                .onChange(of: isFocused) { oldFocusState, newFocusState in
                    if !newFocusState {
                        viewModel.updateNegativePrompt(to: negativePromptText)
                    }
                }
            InfoButton(infoTitle: "IDM-VTON Negative Prompt", infoText: "Text description to avoid while generating images")
        }
        .onAppear {
            negativePromptText = viewModel.negativePrompt
        }
    }
}

