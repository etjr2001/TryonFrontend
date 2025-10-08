//
//  UploadHumanImageView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct UploadHumanImageView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
            UploadImageView(imageType: .human)
            
            VStack {
                HStack {
                    Text("Describe what the person in the image is wearing e.g. jacket, t-shirt, dress, polo shirt, blazer")
                        .foregroundColor(.secondary)
                    InfoButton(
                        infoTitle: "Segment Anything Prompt",
                        infoText: "Description of what the person in the image is wearing e.g. jacket, t-shirt, dress, polo shirt, blazer"
                    )
                }
                HStack {
                    TextField("e.g. jacket, t-shirt, dress, polo shirt, blazer", text: $viewModel.SAMPrompt)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.accentColor, lineWidth: 0.5)
                        )
                        .frame(width: 255)
                        .onChange(of: viewModel.SAMPrompt) {
                            viewModel.updateSAMPrompt(to: viewModel.SAMPrompt)
                        }
                    Button {
                        viewModel.resetSAMPrompt()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .padding(.vertical, 0.5)
    }
}
