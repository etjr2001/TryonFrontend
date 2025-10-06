//
//  GenerateMaskView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 29/9/25.
//

import SwiftUI

struct GenerateMaskView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @FocusState private var isThresholdFocused: Bool
    @State private var errorMessage: String = ""
    @State private var showErrorMessage: Bool = false
    
    @State private var showLoading: Bool = false
    @State private var showMaskImage: Bool = false
    
    @State private var thresholdText: String = ""
    
    let rawSAMModels: [ModelOption] = [
        ModelOption(label: "sam_vit_h", value: "sam_vit_h (2.56GB)", sizeMB: 2.56 * 1024),
        ModelOption(label: "sam_vit_l", value: "sam_vit_l (1.25GB)", sizeMB: 1.25 * 1024),
        ModelOption(label: "sam_vit_b", value: "sam_vit_b (375MB)", sizeMB: 375),
        ModelOption(label: "sam_hq_vit_h", value: "sam_hq_vit_h (2.57GB)", sizeMB: 2.57 * 1024),
        ModelOption(label: "sam_hq_vit_l", value: "sam_hq_vit_l (1.25GB)", sizeMB: 1.25 * 1024),
        ModelOption(label: "sam_hq_vit_b", value: "sam_hq_vit_b (379MB)", sizeMB: 379),
        // For some reason, mobile_sam(39MB) is missing a space
        ModelOption(label: "mobile_sam", value: "mobile_sam(39MB)", sizeMB: 39),
    ]
    
    var sortedSAMModels: [ModelOption] {
        sortAndLabel(rawSAMModels, smallestSizeLabel: "Fastest", largestSizeLabel: "Slowest / Highest Quality", defaultModel: "sam_hq_vit_h (2.57GB)")
    }
    
    let rawDINOModels: [ModelOption] = [
        ModelOption(label: "GroundingDINO_SwinT_OGC", value: "GroundingDINO_SwinT_OGC (694MB)", sizeMB: 694),
        ModelOption(label: "GroundingDINO_SwinB", value: "GroundingDINO_SwinB (938MB)", sizeMB: 938),
    ]
    
    var sortedDINOModels: [ModelOption] {
        sortAndLabel(rawDINOModels, smallestSizeLabel: "", largestSizeLabel: "", defaultModel: "GroundingDINO_SwinB (938MB)")
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("SAM")
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    Picker("SAM Model", selection: $viewModel.selectedSAMModel) {
                        ForEach(sortedSAMModels) { model in
                            Text(model.label).tag(model.value)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedSAMModel) {
                        viewModel.updateSAMModel(to: viewModel.selectedSAMModel)
                    }
                    .frame(width: 255)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color.accentColor, lineWidth: 0.5)
                    )
                    InfoButton(
                        infoTitle: "Segment Anything Model (SAM)",
                        infoText: "Choose SAM model to generate mask"
                    )
                }
                .padding(.vertical, 0.5)
                
                HStack {
                    Text("Grounding")
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    Picker("DINO Model", selection: $viewModel.selectedDINOModel) {
                        ForEach(sortedDINOModels) { model in
                            Text(model.label).tag(model.value)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedDINOModel) {
                        viewModel.updateDINOModel(to: viewModel.selectedDINOModel)
                    }
                    .frame(width: 255)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color.accentColor, lineWidth: 0.5)
                    )
                    InfoButton(
                        infoTitle: "Grounding DINO Model",
                        infoText: "Choose grounding model to generate mask"
                    )
                }
                .padding(.vertical, 0.5)
                
                HStack {
                    Text("Prompt")
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    TextField("Enter prompt for segment anything", text: $viewModel.SAMPrompt)
                        .frame(width: 255)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.accentColor, lineWidth: 0.5)
                        )
                        .onChange(of: viewModel.SAMPrompt) {
                            viewModel.updateSAMPrompt(to: viewModel.SAMPrompt)
                        }
                    
                    InfoButton(
                        infoTitle: "Segment Anything Prompt",
                        infoText: "Describe what the person in the image is wearing e.g. shirt"
                    )
                }
                .padding(.vertical, 0.5)
                
                HStack {
                    Text("Threshold")
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    TextField("Enter threshold (0.0 to 1.0)", text: $thresholdText)
                        .keyboardType(.decimalPad)
                        .frame(width: 255)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(showErrorMessage ? Color.red : Color.accentColor, lineWidth: 0.5)
                        )
                        .focused($isThresholdFocused)
                        .onChange(of: thresholdText) {
                            let filtered = thresholdText.filter { ("0123456789,.").contains($0) }
                            if filtered != thresholdText {
                                thresholdText = filtered
                            }
                        }
                        .onChange(of: isThresholdFocused) { oldFocusState, newFocusState in
                            if !newFocusState {
                                let threshold = formatThreshold()
                                thresholdText = String(threshold)
                                viewModel.updateSAMThreshold(to: threshold)
                            }
                        }
                    InfoButton(
                        infoTitle: "Segment Anything Threshold",
                        infoText: "Set threshold from 0 (cannot be 0) to 1.0 (highest) for segment anything model output.\nLower values will result in more detailed masks but more noise.\nHigher values will result in less detailed masks but less noise."
                    )
                }
                .padding(.vertical, 0.5)
                
                Button("Generate mask") {
                    showMaskImage = true
                    showLoading = true
                    showErrorMessage = false
                    Task {
                        await generateMaskAndDisplayImage()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical, 0.5)
                
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
                    ProgressView("Loading \(ImageType.mask.type) Image...")
                } else if showMaskImage {
                    DisplayImageView(imageType: .mask)
                }
            }
        }
        .onAppear {
            thresholdText = String(viewModel.SAMThreshold)
            showMaskImage = viewModel.maskImageData != nil
        }
    }
    
    func formatThreshold() -> Double {
        guard let thresholdValue = Double(thresholdText.replacingOccurrences(of: ",", with: "")) else {
            errorMessage = "Invalid threshold \(thresholdText). Threshold must be between 0.0 and 1.0.\nThreshold set automatically to 0.3 (default)."
            showErrorMessage = true
            return 0.3
        }
        if thresholdValue <= 0.0 {
            errorMessage = "Invalid threshold \(thresholdText). Threshold must be greater than 0.\nThreshold set automatically to 0.1."
            showErrorMessage = true
            return 0.1
        }
        if thresholdValue > 1.0 {
            errorMessage = "Invalid threshold \(thresholdText). Threshold must be between 0.0 and 1.0.\nThreshold set automatically to 1.0."
            showErrorMessage = true
            return 1.0
        }
        showErrorMessage = false
        let rounded = Double(String(format: "%.2f", thresholdValue)) ?? thresholdValue
        return rounded
    }
    
    func generateMaskAndDisplayImage() async {
        do {
            try await viewModel.generateMaskAndUpdateImage()
            showLoading = false
        } catch {
            viewModel.maskImageData = nil
            errorMessage = "Failed to generate mask: \(error.localizedDescription)"
            showErrorMessage = true
        }
    }
}

//#Preview {
//    let mockVM = ViewModel()
//
//    GenerateMaskView()
//        .environmentObject(mockVM)
//}
