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
    
    let weightDType: [String] = [
        "float16",
        "float32",
        "bfloat16"
    ]
    
    var body: some View {
        HStack {
            Text("Weight Dtype")
                .foregroundColor(.secondary)
                .frame(width: labelWidth)
            Picker("Weight Dtype", selection: $viewModel.weightDType) {
                ForEach(weightDType, id: \.self) { dtype in Text(dtype).tag(dtype)
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
