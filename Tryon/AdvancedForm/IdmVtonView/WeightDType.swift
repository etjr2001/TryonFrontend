//
//  WeightDType.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 30/9/25.
//

import SwiftUI

struct WeightDType: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var labelWidth: CGFloat
    var fieldWidth: CGFloat
    
    let rawWeightDType: [ModelOption] = [
        ModelOption(label: "float16", value: "float16", sizeMB: 0),
        ModelOption(label: "float32", value: "float32", sizeMB: 1),
        ModelOption(label: "bfloat16", value: "bfloat16", sizeMB: 2)
    ]
    
    var sortedWeightDType: [ModelOption] {
        sortAndLabel(rawWeightDType, smallestSizeLabel: "", largestSizeLabel: "", defaultModel: "float16")
    }
    
    var body: some View {
        HStack {
            Text("Weight Dtype")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            Picker("Weight Dtype", selection: $viewModel.weightDType) {
                ForEach(sortedWeightDType) { model in Text(model.label).tag(model.value)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.weightDType) {
                viewModel.updateWeightDType(to: viewModel.weightDType)
            }
            .frame(width: fieldWidth)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(Color.accentColor, lineWidth: 0.5)
            )
            InfoButton(infoTitle: "IDM-VTON Pipeline Weight Data Type", infoText: "float16: Low precision but fast\nfloat32: High precision but slow\nbfloat16: Mixed precision but more range")
        }
        .padding(.vertical, 0.5)
    }
}
