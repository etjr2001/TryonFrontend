//
//  UploadGarmentImageView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 6/10/25.
//

import SwiftUI

struct UploadGarmentImageView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
            UploadImageView(imageType: .garment)
            
            VStack {
                HStack {
                    Text("Describe the type of clothing in the image e.g. jacket, t-shirt, dress, polo shirt, blazer")
                        .foregroundColor(.secondary)
                    InfoButton(
                        infoTitle: "Garment description",
                        infoText: "Description of the garment in the image e.g. jacket, t-shirt, dress, polo shirt, blazer"
                    )
                }
                HStack {
                    TextField("e.g. jacket, t-shirt, dress, polo shirt, blazer", text: $viewModel.garmentDescription)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.accentColor, lineWidth: 0.5)
                        )
                        .frame(width: 255)
                        .onChange(of: viewModel.garmentDescription) {
                            viewModel.updateGarmentDescription(to: viewModel.garmentDescription)
                        }
                    Button {
                        viewModel.resetGarmentDescription()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .padding(.vertical, 0.5)
    }
}
