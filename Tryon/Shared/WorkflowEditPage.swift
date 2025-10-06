//
//  WorkflowEditPage.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import SwiftUI

enum WorkflowEditPage {
    case uploadImage(imageType: ImageType)
    case displayImage(imageType: ImageType)
    case generateMask
    case generatePose
    case idmVton
    
    @ViewBuilder
    func view(with viewModel: ViewModel) -> some View {
        switch self {
        case .uploadImage(imageType: let imageType):
            UploadImageView(imageType: imageType)
                .environmentObject(viewModel)
        case .displayImage(imageType: let imageType):
            DisplayImageView(imageType: imageType)
                .environmentObject(viewModel)
        case .generateMask:
            GenerateMaskView()
                .environmentObject(viewModel)
        case .generatePose:
            GeneratePoseView()
                .environmentObject(viewModel)
        case .idmVton:
            IdmVtonView()
                .environmentObject(viewModel)
        }
    }
}
