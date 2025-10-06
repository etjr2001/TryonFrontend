//
//  Seed.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct Seed: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isFocused: Bool
    
    @State private var seedErrorMessage: String = ""
    @State private var showSeedErrorMessage: Bool = false
    @State private var seedText: String = ""
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    var body: some View {
        HStack {
            Text("Seed")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            TextField("Seed for random number generation", text: $seedText)
                .keyboardType(.decimalPad)
                .frame(width: fieldWidth)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(showSeedErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                )
                .focused($isFocused)
                .onChange(of: seedText) {
                    let filtered = seedText.filter {
                        "1234567890".contains($0)}
                    if filtered != seedText {
                        seedText = filtered
                    }
                }
                .onChange(of: isFocused) { oldFocusState, newFocusState in
                    if !newFocusState {
                        let seed = formatSeed()
                        seedText = String(seed)
                        viewModel.updateSeed(to: seed)
                    }
                }
            InfoButton(infoTitle: "IDM-VTON Seed", infoText: "Tryon seed for random number generation to ensure reeproducibility. Default 42. Any integer less than Int.max.")
        }
        .onAppear {
            seedText = String(viewModel.seed)
        }
        
        if (showSeedErrorMessage) {
            HStack {
                Text(seedErrorMessage)
                    .foregroundColor(Color.red)
                    .padding(4)
            }
            .padding(.vertical, 0.5)
        }
    }
    
    func formatSeed() -> Int {
        guard let number = Int(seedText) else {
            seedErrorMessage = "Invalid seed \(seedErrorMessage).\nSeed set to 42 (default)."
            showSeedErrorMessage = true
            return 42
        }
        
        if (number < 0) {
            seedErrorMessage = "Seed must be a positive integer.\nSeed set to 0."
            showSeedErrorMessage = true
            return 0
        }
        
        if (number > Int.max) {
            seedErrorMessage = "Seed exceeds Int.max.\nSeed set to Int.max."
            showSeedErrorMessage = true
            return Int.max
        }
        
        showSeedErrorMessage = false
        
        return number
    }
}
