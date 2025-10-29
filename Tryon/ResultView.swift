//
//  ResultView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 7/10/25.
//

import SwiftUI
import PhotosUI

class ImageSaver: NSObject {
    var onSuccess: (() -> Void)?
    var onError: (() -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            onError?()
        } else {
            onSuccess?()
        }
    }
}

struct ResultView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    
    private let imageSaver = ImageSaver()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            if (viewModel.beforeImageData == nil && viewModel.afterImageData == nil) {
                VStack {
                    Spacer()
                    Text("Error loading image")
                        .font(.headline)
                    Text("Have you run the workflow yet?")
                        .font(.caption)
                    Spacer()
                }
            }
            else {
                Button("Save Image") {
                    saveImage()
                }
                .buttonStyle(.borderedProminent)
                .alert("Image saved successfully.", isPresented: $showSaveSuccessAlert) {
                    Button("OK", role: .cancel) {}
                }
                .alert("Failed to save image.", isPresented: $showSaveErrorAlert) {
                    Button("OK", role: .cancel) {}
                }
                SliderView()
            }
            Spacer()
        }
        .padding()
    }
    
    func saveImage() {
        guard let data = viewModel.afterImageData,
              let image = UIImage(data: data) else {
            showSaveSuccessAlert = true
            return
        }
        
        imageSaver.onSuccess = {
            DispatchQueue.main.async {
                showSaveSuccessAlert = true
            }
        }
        
        imageSaver.onError = {
            DispatchQueue.main.async {
                showSaveErrorAlert = true
            }
        }
        
        imageSaver.writeToPhotoAlbum(image: image)
    }
}
