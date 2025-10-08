//
//  UploadImageView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI
import PhotosUI

struct UploadImageView: View {
    @EnvironmentObject var viewModel: ViewModel
    let imageType: ImageType
    
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedData: Data?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            PhotosPicker("Select \(imageType.type) Image", selection: $pickerItem, matching: .images)
                .onChange(of: pickerItem) {
                    Task {
                        await uploadImage()
                    }
                }
                .buttonStyle(.borderedProminent)
            DisplayImageView(imageType: imageType)
        }
    }
    
    private func uploadImage() async {
        guard let item = pickerItem else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                selectedData = data
                try await viewModel.uploadImageDataAndUpdateImage(data: selectedData!, imageType: imageType)
                errorMessage = nil
            }
        } catch {
            errorMessage = "Failed to upload image: \(error.localizedDescription)"
        }
    }
}
