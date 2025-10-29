//
//  BeforeAfterView.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 13/10/25.
//

import SwiftUI

struct BeforeAfterView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var sliderPosition: CGFloat = 0.5
    @State private var imageHeight: CGFloat = 0
    
    var body: some View {
        if let beforeImageData = viewModel.beforeImageData,
           let afterImageData = viewModel.afterImageData,
           let beforeUIImage = UIImage(data: beforeImageData),
           let afterUIImage = UIImage(data: afterImageData) {
            VStack {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    
                    ZStack {
                        Image(uiImage: beforeUIImage)
                            .resizable()
                            .scaledToFit()
                            .overlay(
                                GeometryReader { imageGeometry in
                                    Color.clear
                                        .onAppear {
                                            imageHeight = imageGeometry.size.height
                                        }
                                }
                            )
                        
                        Image(uiImage: afterUIImage)
                            .resizable()
                            .scaledToFit()
                            .mask {
                                HStack {
                                    Rectangle()
                                        .frame(width: width * sliderPosition)
                                    Spacer()
                                }
                            }
                    }
                }
                
                Text("Try the slider to see the difference between the images!")
                    .padding()
                
                HStack {
                    Text("Before")
                    Spacer()
                    Text("After")
                }
                
                Slider(value: $sliderPosition, in: 0...1)
                    .padding()
            }
        }
    }
}
