//
//  Workflow.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 17/9/25.
//

import Foundation

// MARK: - Structure to contain whole workflow
struct Workflow: Codable {
    var workflow: [String: AnyNode]
    var meta: Meta?
    
    enum CodingKeys: String, CodingKey {
        case workflow = "workflow"
        case meta = "_meta"
    }
}

// MARK: - A wrapper for any node type
struct AnyNode: Codable {
    var node: WorkflowNodeType
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let classType = try container.decode(String.self, forKey: .classType)
        
        switch classType {
        case let str where str.contains("SAMModelLoader"):
            node = .samModelLoader(try SAMModelLoader(from: decoder))
        case let str where str.contains("GroundingDinoModelLoader"):
            node = .groundingDinoModelLoader(try GroundingDinoModelLoader(from: decoder))
        case let str where str.contains("GroundingDinoSAMSegment"):
            node = .groundingDinoSAMSegment(try GroundingDinoSAMSegment(from: decoder))
        case "LoadImage":
            node = .loadImage(try LoadImage(from: decoder))
        case "DensePosePreprocessor":
            node = .densePosePreprocessor(try DensePosePreprocessor(from: decoder))
        case "MaskToImage":
            node = .maskToImage(try MaskToImage(from: decoder))
        case "PreviewImage":
            node = .previewImage(try PreviewImage(from: decoder))
        case "IDM-VTON":
            node = .idmVTON(try IDMVTON(from: decoder))
        case "PipelineLoader":
            // You need to add PipelineLoader struct and enum case
            node = .pipelineLoader(try PipelineLoader(from: decoder))
        case "SaveImage":
            node = .saveImage(try SaveImage(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .classType, in: container, debugDescription: "Unknown class_type \(classType)")
            
        }
    }
    
    init(node: WorkflowNodeType) {
        self.node = node
    }
    
    func encode(to encoder: Encoder) throws {
        try node.encode(to: encoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case classType = "class_type"
    }
}


// MARK: - Enum
enum WorkflowNodeType: Codable {
    case samModelLoader(SAMModelLoader)
    case groundingDinoModelLoader(GroundingDinoModelLoader)
    case groundingDinoSAMSegment(GroundingDinoSAMSegment)
    case loadImage(LoadImage)
    case densePosePreprocessor(DensePosePreprocessor)
    case maskToImage(MaskToImage)
    case previewImage(PreviewImage)
    case idmVTON(IDMVTON)
    case pipelineLoader(PipelineLoader)
    case saveImage(SaveImage)
}


extension WorkflowNodeType {
    var meta: Meta {
        switch self {
        case .samModelLoader(let node): return node.meta
        case .groundingDinoModelLoader(let node): return node.meta
        case .groundingDinoSAMSegment(let node): return node.meta
        case .loadImage(let node): return node.meta
        case .densePosePreprocessor(let node): return node.meta
        case .maskToImage(let node): return node.meta
        case .previewImage(let node): return node.meta
        case .idmVTON(let node): return node.meta
        case .pipelineLoader(let node): return node.meta
        case .saveImage(let node): return node.meta
        }
    }
    
    var firstInput: String? {
        switch self {
        case .samModelLoader(let node):
            return node.inputs.modelName
        case .groundingDinoModelLoader(let node):
            return node.inputs.modelName
        case .groundingDinoSAMSegment(let node):
            return node.inputs.prompt
        case .densePosePreprocessor(let node):
            return node.inputs.cmap
        case .idmVTON(let node):
            return node.inputs.garmentDescription
        case .pipelineLoader(let node):
            return node.inputs.weightDtype
        default:
            return nil
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        switch self {
        case .samModelLoader(let node):
            try node.encode(to: encoder)
        case .groundingDinoModelLoader(let node):
            try node.encode(to: encoder)
        case .groundingDinoSAMSegment(let node):
            try node.encode(to: encoder)
        case .loadImage(let node):
            try node.encode(to: encoder)
        case .densePosePreprocessor(let node):
            try node.encode(to: encoder)
        case .maskToImage(let node):
            try node.encode(to: encoder)
        case .previewImage(let node):
            try node.encode(to: encoder)
        case .idmVTON(let node):
            try node.encode(to: encoder)
        case .pipelineLoader(let node):
            try node.encode(to: encoder)
        case .saveImage(let node):
            try node.encode(to: encoder)
        }
    }
}

// MARK: - Node for SAMModelLoader (segment anything)
struct SAMModelLoader: Codable {
    var inputs: SAMModelLoaderInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct SAMModelLoaderInputs: Codable {
    var modelName: String = "sam_hq_vit_h (2.57GB)"
    enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(modelName, forKey: .modelName)
    }
}

// MARK: - Node for GroundingDinoModelLoader (segment anything)
struct GroundingDinoModelLoader: Codable {
    var inputs: GroundingDinoModelLoaderInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct GroundingDinoModelLoaderInputs: Codable {
    var modelName: String = "GroundingDINO_SwinB (938MB)"
    enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(modelName, forKey: .modelName)
    }
}

// MARK: - Node for GroundinDinoSAMSegment (segment anything)
struct GroundingDinoSAMSegment: Codable {
    var inputs: GroundingDinoSAMSegmentInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct GroundingDinoSAMSegmentInputs: Codable {
    var prompt: String
    var threshold: Double = 0.3
    var samModel: [Mapping]
    var groundingDinoModel: [Mapping]
    var image: [Mapping]
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case threshold
        case samModel = "sam_model"
        case groundingDinoModel = "grounding_dino_model"
        case image
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(threshold, forKey: .threshold)
        try container.encode(samModel, forKey: .samModel)
        try container.encode(groundingDinoModel, forKey: .groundingDinoModel)
        try container.encode(image, forKey: .image)
    }
}

// MARK: - Node for loading image (both human image and garment image)
struct LoadImage: Codable {
    var inputs: LoadImageInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct LoadImageInputs: Codable {
    var image: String
}

// MARK: - Node for DensePosePreprocessor
struct DensePosePreprocessor: Codable {
    var inputs: DensePosePreprocessorInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct DensePosePreprocessorInputs: Codable {
    var model: String = "densepose_r50_fpn_dl.torchscript"
    var cmap: String = "Parula (CivitAI)"
    var resolution: Int = 768
    var image: [Mapping]
}

// MARK: - Node for MaskToImage
struct MaskToImage: Codable {
    var inputs: MaskToImageInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct MaskToImageInputs: Codable {
    var mask: [Mapping]
}

// MARK: - Node for PreviewImage
struct PreviewImage: Codable {
    var inputs: PreviewImageInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct PreviewImageInputs: Codable {
    var images: [Mapping]
}

// MARK: - Node for IDM-VTON
struct IDMVTON: Codable {
    var inputs: IDMVTONInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct IDMVTONInputs: Codable {
    var garmentDescription: String
    var negativePrompt: String = "monochrome, lowres, bad anatomy, worst quality, low quality"
    var width: Int = 768
    var height: Int = 1024
    var numInferenceSteps: Int = 30
    var guidanceScale: Double = 2.0
    var strength: Double = 1.0
    var seed: Int = 42
    var pipeline: [Mapping]
    var humanImg: [Mapping]
    var poseImg: [Mapping]
    var maskImg: [Mapping]
    var garmentImage: [Mapping]
    
    enum CodingKeys: String, CodingKey {
        case garmentDescription = "garment_description"
        case negativePrompt = "negative_prompt"
        case width
        case height
        case numInferenceSteps = "num_inference_steps"
        case guidanceScale = "guidance_scale"
        case strength
        case seed
        case pipeline
        case humanImg = "human_img"
        case poseImg = "pose_img"
        case maskImg = "mask_img"
        case garmentImage = "garment_img"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(garmentDescription, forKey: .garmentDescription)
        try container.encode(negativePrompt, forKey: .negativePrompt)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(numInferenceSteps, forKey: .numInferenceSteps)
        try container.encode(guidanceScale, forKey: .guidanceScale)
        try container.encode(strength, forKey: .strength)
        try container.encode(seed, forKey: .seed)
        try container.encode(pipeline, forKey: .pipeline)
        try container.encode(humanImg, forKey: .humanImg)
        try container.encode(poseImg, forKey: .poseImg)
        try container.encode(maskImg, forKey: .maskImg)
        try container.encode(garmentImage, forKey: .garmentImage)
    }
}

// MARK: - Node for PipelineLoader
struct PipelineLoader: Codable {
    var inputs: PipelineLoaderInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct PipelineLoaderInputs: Codable {
    var weightDtype: String = "float16"
    
    enum CodingKeys: String, CodingKey {
        case weightDtype = "weight_dtype"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(weightDtype, forKey: .weightDtype)
    }
}

// MARK: - Node for SaveImage
struct SaveImage: Codable {
    var inputs: SaveImageInputs
    var classType: String
    var meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case classType = "class_type"
        case meta = "_meta"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(classType, forKey: .classType)
        try container.encode(meta, forKey: .meta)
    }
}

struct SaveImageInputs: Codable {
    var filenamePrefix: String
    var images: [Mapping]
    
    enum CodingKeys: String, CodingKey {
        case filenamePrefix = "filename_prefix"
        case images
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filenamePrefix, forKey: .filenamePrefix)
        try container.encode(images, forKey: .images)
    }
}

// MARK: - Mapping between nodes: [String, Integer]
enum Mapping: Codable {
    case string(String)
    case integer(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        throw DecodingError.typeMismatch(Mapping.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Mapping"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .integer(let x):
            try container.encode(x)
        }
    }
}

struct Meta: Codable {
    var title: String
}
