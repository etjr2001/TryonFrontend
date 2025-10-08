//
//  NegativePrompt.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

// MARK: - Change to use viewModel.negativePrompt instead

import SwiftUI

struct NegativePrompt: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isFocused: Bool
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Negative Prompt")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Text description to avoid while generating images", text: $viewModel.negativePrompt)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.accentColor, lineWidth: 0.5)
                )
                .focused($isFocused)
                .onChange(of: isFocused) { oldFocusState, newFocusState in
                    if !newFocusState {
                        viewModel.updateNegativePrompt(to: viewModel.negativePrompt)
                    }
                }
            InfoButton(infoTitle: "IDM-VTON Negative Prompt", infoText: "Text description to avoid while generating images")
        }
    }
}

