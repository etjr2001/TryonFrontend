//
//  GarmentDescription.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct GarmentDescription: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isFocused: Bool
    
    @State private var garmentDescriptionText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Garment Description")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Text description of the garment", text: $garmentDescriptionText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.accentColor, lineWidth: 0.5)
                )
                .focused($isFocused)
                .onChange(of: garmentDescriptionText) {
                    let filtered = garmentDescriptionText.replacingOccurrences(of: "[^a-zA-Z0-9 ,.]", with: "", options: .regularExpression)
                    if filtered != garmentDescriptionText {
                        garmentDescriptionText = filtered
                    }
                }
                .onChange(of: isFocused) { oldFocusState, newFocusState in
                    if !newFocusState {
                        viewModel.updateGarmentDescription(to: garmentDescriptionText)
                    }
                }
            InfoButton(infoTitle: "IDM-VTON Garment Description", infoText: "Text description of the garment")
        }
        .onAppear {
            garmentDescriptionText = viewModel.garmentDescription
        }
    }
}
