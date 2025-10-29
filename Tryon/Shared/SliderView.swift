//
//  SliderView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 13/10/25.
//

import SwiftUI
import MoSlider

struct SliderView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        if let beforeImageData = viewModel.beforeImageData,
           let afterImageData = viewModel.afterImageData,
           let beforeUIImage = UIImage(data: beforeImageData),
           let afterUIImage = UIImage(data: afterImageData) {
            BeforeAfterSlider {
                Image(uiImage: beforeUIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } afterContent: {
                Image(uiImage: afterUIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .sliderWidth(6)
            .handleSize(50)
        }
    }
}
