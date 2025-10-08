//
//  GeneratePoseView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 29/9/25.
//

import SwiftUI

struct GeneratePoseView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isResolutionFocused: Bool
    
    @State private var errorMessage: String = ""
    @State private var showErrorMessage: Bool = false
    
    @State private var showLoading: Bool = false
    @State private var showDensePoseImage: Bool = false
    
    @State private var densePoseResolutionText: String = ""
    
    let rawDensePoseModels: [ModelOption] = [
        ModelOption(label: "ResNet-50", value: "densepose_r50_fpn_dl.torchscript", sizeMB: 265),
        ModelOption(label: "ResNet-101", value: "densepose_r101_fpn_dl.torchscript", sizeMB: 342)
    ]
    
    var sortedDensePoseModels: [ModelOption] {
        sortAndLabel(rawDensePoseModels, smallestSizeLabel: "Fastest", largestSizeLabel: "Slowest / Highest Quality", defaultModel: "densepose_r50_fpn_dl.torchscript")
    }
    
    
    let rawCmapModels: [ModelOption] = [
        ModelOption(label: "Parula (CivitAI)", value: "Parula (CivitAI)", sizeMB: 0),
        ModelOption(label: "Viridis (MagicAnimate)", value: "Viridis (MagicAnimate)", sizeMB: 0)
    ]
    
    var sortedCmapModels: [ModelOption] {
        sortAndLabel(rawCmapModels, smallestSizeLabel: "", largestSizeLabel: "", defaultModel: "Parula (CivitAI)")
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("DensePose")
                        .foregroundColor(.secondary)
                        .frame(width: 90)
                    Picker("DensePose Model", selection: $viewModel.selectedDensePoseModel) {
                        ForEach(sortedDensePoseModels) { model in
                            Text(model.label).tag(model.value)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedDensePoseModel) {
                        viewModel.updateDensePoseModel(to: viewModel.selectedDensePoseModel)
                    }
                    .frame(width: 245)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color.accentColor, lineWidth: 0.5)
                    )
                    InfoButton(
                        infoTitle: "DensePose Model",
                        infoText: "Choose the pre-trained DensePose model to be used for dense pose estimation.\nDefault is densepose_r50_fpn_dl.torchscript."
                    )
                }
                .padding(.vertical, 0.5)
                
                HStack {
                    Text("Cmap")
                        .foregroundColor(.secondary)
                        .frame(width: 90)
                    Picker("Colour Map (cmap)", selection: $viewModel.selectedCmapModel) {
                        ForEach(sortedCmapModels) { model in
                            Text(model.label).tag(model.value)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedCmapModel) {
                        viewModel.updateCmapModel(to: viewModel.selectedCmapModel)
                    }
                    .frame(width: 245)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color.accentColor, lineWidth: 0.5)
                    )
                    InfoButton(
                        infoTitle: "Colour Map (cmap)",
                        infoText: "Choose the colour mapping used for visualising the dense pose estimation.\nDefault is Viridis."
                    )
                }
                .padding(.vertical, 0.5)
                
                HStack {
                    Text("Resolution")
                        .foregroundColor(.secondary)
                        .frame(width: 90)
                    TextField("Enter resolution (multiple of 64)", text: $densePoseResolutionText)
                        .keyboardType(.decimalPad)
                        .frame(width:245)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(showErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                        )
                        .focused($isResolutionFocused)
                        .onChange(of: densePoseResolutionText) {
                            let filtered = densePoseResolutionText.filter { "1234567890".contains($0)}
                            if filtered != densePoseResolutionText {
                                densePoseResolutionText = filtered
                            }
                        }
                        .onChange(of: isResolutionFocused) { oldFocusState, newFocusState in
                            if !newFocusState {
                                let densePoseResolution = formatDensePoseResolution()
                                densePoseResolutionText = String(densePoseResolution)
                                viewModel.updateDensePoseResolution(to: densePoseResolution)
                            }
                        }
                    InfoButton(
                        infoTitle: "Pose Resolution",
                        infoText: "Resolution must be multiple of 64. Min 64 to max 2048. Higher resolution will result in better performance but more memory usage.\nDefault 768."
                    )
                }
                .padding(.vertical, 0.5)
                
                HStack {
                    Button("Generate pose") {
                        showErrorMessage = false
                        showDensePoseImage = true
                        showLoading = true
                        Task {
                            await generatePoseAndDisplayImage()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 0.5)
                    
                    
                    Button {
                        viewModel.resetPoseParameters()
                        densePoseResolutionText = String(viewModel.densePoseResolution)
                        showErrorMessage = false
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
                if (showErrorMessage) {
                    HStack {
                        Text(errorMessage)
                            .foregroundColor(Color.red)
                            .padding(4)
                    }
                    .padding(.vertical, 0.5)
                }
                
                if showLoading {
                    Spacer()
                    ProgressView("Loading \(ImageType.pose)...")
                } else if showDensePoseImage {
                    DisplayImageView(imageType: .pose)
                }
            }
            .onAppear {
                densePoseResolutionText = String(viewModel.densePoseResolution)
                showDensePoseImage = viewModel.poseImageData != nil
            }
        }
    }
    
    func formatDensePoseResolution() -> Int {
        guard let number = Int(densePoseResolutionText) else {
            errorMessage = "Invalid resolution format \(densePoseResolutionText).\nResolution set automatically to 768 (default)."
            showErrorMessage = true
            return 768
        }
        
        if (number < 64) {
            errorMessage = "Resolution must be at least 64.\nResolution set automatically to 64."
            showErrorMessage = true
            return 64
        }
        
        if (number > 2048) {
            errorMessage = "Resolution is at most 2048.\nResolution set automatically to 2048."
            showErrorMessage = true
            return 2048
        }
        
        let rounded = Int(round(Double(number) / 64.0)) * 64
        
        if (rounded != number) {
            errorMessage = "Resolution must be a multiple of 64.\nResolution set automatically to multiple of 64."
            showErrorMessage = true
        } else {
            showErrorMessage = false
        }
        
        return rounded
    }
    
    func generatePoseAndDisplayImage() async {
        do {
            try await viewModel.generatePoseAndUpdateImage()
            showLoading = false
        } catch {
            viewModel.poseImageData = nil
            errorMessage = "Failed to generate pose: \(error.localizedDescription)"
            showErrorMessage = true
        }
    }
}
