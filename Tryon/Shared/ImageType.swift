//
//  ImageType.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

enum ImageType: String, CaseIterable {
    case human
    case garment
    case mask
    case pose
    case tryon
    
    var type: String {
        switch self {
        case .human: return "Human"
        case .garment: return "Garment"
        case .mask: return "Mask"
        case .pose: return "Pose"
        case .tryon: return "Try-On"
        }
    }
}
