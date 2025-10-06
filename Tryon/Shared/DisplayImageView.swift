//
//  DisplayImageView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

struct DisplayImageView: View {
    @EnvironmentObject var viewModel: ViewModel
    let imageType: ImageType
    
    var body: some View {
        if let data = viewModel.getImageData(for: imageType) {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .border(Color.accentColor, width: 2)
            }
        } else {
            Text("Error loading image")
                .font(.caption)
        }
    }
}
