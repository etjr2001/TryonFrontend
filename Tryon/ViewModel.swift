//
//  ViewModel.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 26/9/25.
//

import Foundation

@MainActor
class ViewModel: ObservableObject {
    @Published var defaultWorkflow: Workflow?
    @Published var maskWorkflow: Workflow?
    @Published var poseWorkflow: Workflow?
    @Published var pipelineWorkflow: Workflow?
    
    @Published var humanImageData: Data?
    @Published var garmentImageData: Data?
    @Published var maskImageData: Data?
    @Published var poseImageData: Data?
    @Published var tryonImageData: Data?
    
    @Published var tryonImageUUID: String?
    
    @Published var selectedSAMModel: String = "sam_hq_vit_h (2.57GB)"
    @Published var selectedDINOModel: String = "GroundingDINO_SwinB (938MB)"
    @Published var SAMPrompt: String = "shirt"
    @Published var SAMThreshold: Double = 0.3
    @Published var selectedDensePoseModel: String = "densepose_r50_fpn_dl.torchscript"
    @Published var selectedCmapModel: String = "Parula (CivitAI)"
    @Published var densePoseResolution: Int = 768
    @Published var weightDType: String = "float16"
    @Published var widthResolution: Int = 768
    @Published var heightResolution: Int = 1024
    @Published var numInferenceSteps: Int = 30
    @Published var guidance_scale: Double = 2.0
    @Published var strength: Double = 1.0
    @Published var seed: Int = 42
    @Published var garmentDescription: String = "shirt"
    @Published var negativePrompt: String = "monochrome, lowres, bad anatomy, worst quality, low quality"
    
    @Published var errorMessage: String?
    
    private let baseURL = "http://10.91.205.242:8000"
    
    init() {
        resetAllParameters()
    }
    
    func resetAllParameters() {
        resetMaskParameters()
        resetPoseParameters()
        resetPipelineParameters()
    }
    
    func resetMaskParameters() {
        updateSAMModel(to: "sam_hq_vit_h (2.57GB)")
        updateDINOModel(to: "GroundingDINO_SwinB (938MB)")
        updateSAMPrompt(to: "shirt")
        updateSAMThreshold(to: 0.3)
    }
    
    func resetPoseParameters() {
        updateDensePoseModel(to: "densepose_r50_fpn_dl.torchscript")
        updateCmapModel(to: "Parula (CivitAI)")
        updateDensePoseResolution(to: 768)
    }
    
    func resetPipelineParameters() {
        updateWeightDType(to: "float16")
        updateGarmentDescription(to: "shirt")
        updateNegativePrompt(to: "monochrome, lowres, bad anatomy, worst quality, low quality")
        updateWidthResolution(to: 768)
        updateHeightResolution(to: 1024)
        updateNumInferenceSteps(to: 30)
        updateGuidanceScale(to: 2.0)
        updateStrength(to: 1.0)
        updateSeed(to: 42)
    }
    
    func fetchWorkflows() async {
        if defaultWorkflow == nil {
            await self.loadWorkflow(name: "default")
        }
        if maskWorkflow == nil {
            await self.loadWorkflow(name: "mask")
        }
        if poseWorkflow == nil {
            await self.loadWorkflow(name: "pose")
        }
        if pipelineWorkflow == nil {
            await self.loadWorkflow(name: "pipeline")
        }
    }
    
    private func loadWorkflow(name: String) async {
        do {
            let workflow = try await fetchWorkflow(named: name)
            switch name {
            case "mask":
                self.maskWorkflow = workflow
            case "pose":
                self.poseWorkflow = workflow
            case "pipeline":
                self.pipelineWorkflow = workflow
            default:
                self.defaultWorkflow = workflow
            }
        } catch {
            self.errorMessage = "Failed to fetch workflow: \(error.localizedDescription)"
        }
    }
    
    private func fetchWorkflow(named workflow: String) async throws -> Workflow {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        components.path += "/workflows"
        
        components.queryItems = [URLQueryItem(name: "workflow", value: workflow)]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode(Workflow.self, from: data)
    }
    
    
    func fetchHumanImageSample() async {
        guard humanImageData == nil else { return }
        
        do {
            let humanData = try await fetchImage(uuid: "sample_human")
            humanImageData = humanData
        } catch {
            self.errorMessage = "Failed to fetch human image sample: \(error.localizedDescription)"
        }
    }
    
    func fetchGarmentImageSample() async {
        guard garmentImageData == nil else { return }
        
        do {
            let garmentData = try await fetchImage(uuid: "sample_garment")
            garmentImageData = garmentData
        } catch {
            self.errorMessage = "Failed to fetch garment image sample: \(error.localizedDescription)"
        }
    }
    
    func fetchSampleImages() async {
        await fetchHumanImageSample()
        await fetchGarmentImageSample()
    }
    
    
    func fetchImage(uuid: String) async throws -> Data {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        components.path += "/images/\(uuid)"
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return data
    }
    
    func getImageData(for type: ImageType) -> Data? {
        switch type {
        case .human: return humanImageData
        case .garment: return garmentImageData
        case .mask: return maskImageData
        case .pose: return poseImageData
        case .tryon: return tryonImageData
        }
    }
    
    func uploadImageDataAndUpdateImage(data: Data, imageType: ImageType) async throws {
        do {
            let uuid = try await uploadImage(data: data)
            updateImage(uuid, for: imageType, data: data)
            
            // Try-on image is the output, hence not loaded in the workflow
            if imageType == .tryon {
                tryonImageUUID = uuid
            } else {
                let nodeMetaTitle = "Load \(imageType.type.capitalized) Image"
                updateImageUUIDForAllWorkflows(nodeMetaTitle: nodeMetaTitle, uuid: uuid)
            }
        } catch {
            errorMessage = "Upload image failed: \(error.localizedDescription)"
        }
    }
    
    func updateImage(_ uuid: String, for type: ImageType, data: Data) {
        switch type {
        case .human:
            humanImageData = data
        case .garment:
            garmentImageData = data
        case .mask:
            maskImageData = data
        case .pose:
            poseImageData = data
        case .tryon:
            tryonImageData = data
        }
    }
    
    func updateImageUUIDForAllWorkflows(nodeMetaTitle: String, uuid: String) {
        updateImageUUID(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, uuid: uuid)
        updateImageUUID(workflow: &maskWorkflow, nodeMetaTitle: nodeMetaTitle, uuid: uuid)
        updateImageUUID(workflow: &poseWorkflow, nodeMetaTitle: nodeMetaTitle, uuid: uuid)
        updateImageUUID(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, uuid: uuid)
    }
    
    func updateImageUUID(workflow: inout Workflow?, nodeMetaTitle: String, uuid: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .loadImage(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.image = uuid
                    modifiedWorkflow.workflow[key] = AnyNode(node: .loadImage(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func uploadImage(data: Data) async throws -> String {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        components.path += "/images"
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload_human_image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let dict = try decoder.decode([String: String].self, from: responseData)
        if let imageUuid = dict["image_uuid"] {
            return imageUuid
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    func updateSAMModel(to modelValue: String) {
        selectedSAMModel = modelValue
        
        let nodeMetaTitle = "SAMModelLoader (segment anything)"
        updateSAMModelName(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, SAMModelName: modelValue)
        updateSAMModelName(workflow: &maskWorkflow, nodeMetaTitle: nodeMetaTitle, SAMModelName: modelValue)
    }
    
    func updateSAMModelName(workflow: inout Workflow?, nodeMetaTitle: String, SAMModelName: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .samModelLoader(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.modelName = SAMModelName
                    modifiedWorkflow.workflow[key] = AnyNode(node: .samModelLoader(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateDINOModel(to modelValue: String) {
        selectedDINOModel = modelValue
        
        let nodeMetaTitle = "GroundingDinoModelLoader (segment anything)"
        updateDINOModelName(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, DINOModelName: modelValue)
        updateDINOModelName(workflow: &maskWorkflow, nodeMetaTitle: nodeMetaTitle, DINOModelName: modelValue)
    }
    
    func updateDINOModelName(workflow: inout Workflow?, nodeMetaTitle: String, DINOModelName: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .groundingDinoModelLoader(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.modelName = DINOModelName
                    modifiedWorkflow.workflow[key] = AnyNode(node: .groundingDinoModelLoader(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateSAMPrompt(to promptValue: String) {
        SAMPrompt = promptValue
        
        let nodeMetaTitle = "GroundingDinoSAMSegment (segment anything)"
        updateSAMPrompt(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, SAMPrompt: promptValue)
        updateSAMPrompt(workflow: &maskWorkflow, nodeMetaTitle: nodeMetaTitle, SAMPrompt: promptValue)
    }
    
    func updateSAMPrompt(workflow: inout Workflow?, nodeMetaTitle: String, SAMPrompt: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .groundingDinoSAMSegment(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.prompt = SAMPrompt
                    modifiedWorkflow.workflow[key] = AnyNode(node: .groundingDinoSAMSegment(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateSAMThreshold(to threshold: Double) {
        SAMThreshold = threshold
        
        let nodeMetaTitle = "GroundingDinoSAMSegment (segment anything)"
        updateSAMThreshold(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, SAMThreshold: threshold)
        updateSAMThreshold(workflow: &maskWorkflow, nodeMetaTitle: nodeMetaTitle, SAMThreshold: threshold)
    }
    
    func updateSAMThreshold(workflow: inout Workflow?, nodeMetaTitle: String, SAMThreshold: Double) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .groundingDinoSAMSegment(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.threshold = SAMThreshold
                    modifiedWorkflow.workflow[key] = AnyNode(node: .groundingDinoSAMSegment(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func generateMaskAndUpdateImage() async throws {
        let uuid = try await run(workflowType: "mask")
        let maskData = try await fetchImage(uuid: uuid)
        
        updateImage(uuid, for: .mask, data: maskData)
        
        let nodeMetaTitle = "Load Mask Image"
        updateImageUUIDForAllWorkflows(nodeMetaTitle: nodeMetaTitle, uuid: uuid)
    }
    
    func run(workflowType: String) async throws -> String {
        let workflowToRun: Workflow?
        switch workflowType {
        case "mask":
            workflowToRun = self.maskWorkflow
        case "pose":
            workflowToRun = self.poseWorkflow
        case "pipeline":
            workflowToRun = self.pipelineWorkflow
        default:
            workflowToRun = self.defaultWorkflow
        }
        
        let uuid = try await runWorkflow(workflow: workflowToRun!)
        return uuid
    }
    
    func runWorkflow(workflow: Workflow) async throws -> String {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        components.path += "/run"
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(workflow)
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let dict = try decoder.decode([String: String].self, from: responseData)
        if let imageUuid = dict["image_uuid"] {
            return imageUuid
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    func updateDensePoseModel(to modelValue: String) {
        selectedDensePoseModel = modelValue
        
        let nodeMetaTitle = "DensePose Estimator"
        updateDensePoseModelName(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, densePoseModelName: modelValue)
        updateDensePoseModelName(workflow: &poseWorkflow, nodeMetaTitle: nodeMetaTitle, densePoseModelName: modelValue)
    }
    
    func updateDensePoseModelName(workflow: inout Workflow?, nodeMetaTitle: String, densePoseModelName: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .densePosePreprocessor(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.model = densePoseModelName
                    modifiedWorkflow.workflow[key] = AnyNode(node: .densePosePreprocessor(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateCmapModel(to modelValue: String) {
        selectedCmapModel = modelValue
        
        let nodeMetaTitle = "DensePose Estimator"
        updateCmapModelName(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, cmapModelName: modelValue)
        updateCmapModelName(workflow: &poseWorkflow, nodeMetaTitle: nodeMetaTitle, cmapModelName: modelValue)
    }
    
    func updateCmapModelName(workflow: inout Workflow?, nodeMetaTitle: String, cmapModelName: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .densePosePreprocessor(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.cmap = cmapModelName
                    modifiedWorkflow.workflow[key] = AnyNode(node: .densePosePreprocessor(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func generatePoseAndUpdateImage() async throws {
        let uuid = try await run(workflowType: "pose")
        let poseData = try await fetchImage(uuid: uuid)
        
        updateImage(uuid, for: .pose, data: poseData)
        
        let nodeMetaTitle = "DensePose Estimator"
        updateImageUUIDForAllWorkflows(nodeMetaTitle: nodeMetaTitle, uuid: uuid)
    }
    
    func updateDensePoseResolution(to resolution: Int) {
        self.densePoseResolution = resolution
        let nodeMetaTitle = "DensePose Estimator"
        updateDensePoseResolution(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, resolution: resolution)
        updateDensePoseResolution(workflow: &poseWorkflow, nodeMetaTitle: nodeMetaTitle, resolution: resolution)
    }
    
    func updateDensePoseResolution(workflow: inout Workflow?, nodeMetaTitle: String, resolution: Int) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .densePosePreprocessor(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.resolution = resolution
                    modifiedWorkflow.workflow[key] = AnyNode(node: .densePosePreprocessor(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateWeightDType(to weightDType: String) {
        self.weightDType = weightDType
        let nodeMetaTitle = "Load IDM-VTON Pipeline"
        updateWeightDType(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, weightDType: weightDType)
        updateWeightDType(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, weightDType: weightDType)
    }
    
    func updateWeightDType(workflow: inout Workflow?, nodeMetaTitle: String, weightDType: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .pipelineLoader(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.weightDtype = weightDType
                    modifiedWorkflow.workflow[key] = AnyNode(node: .pipelineLoader(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateWidthResolution(to resolution: Int) {
        self.widthResolution = resolution
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateWidthResolution(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, resolution: resolution)
        updateWidthResolution(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, resolution: resolution)
    }
    
    func updateWidthResolution(workflow: inout Workflow?, nodeMetaTitle: String, resolution: Int) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.width = resolution
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateHeightResolution(to resolution: Int) {
        self.heightResolution = resolution
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateHeightResolution(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, resolution: resolution)
        updateHeightResolution(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, resolution: resolution)
    }
    
    func updateHeightResolution(workflow: inout Workflow?, nodeMetaTitle: String, resolution: Int) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.height = resolution
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateNumInferenceSteps(to steps: Int) {
        self.numInferenceSteps = steps
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateNumInferenceSteps(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, steps: steps)
        updateNumInferenceSteps(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, steps: steps)
    }
    
    func updateNumInferenceSteps(workflow: inout Workflow?, nodeMetaTitle: String, steps: Int) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.numInferenceSteps = steps
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateGuidanceScale(to guidance_scale: Double) {
        self.guidance_scale = guidance_scale
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateGuidanceScale(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, guidance_scale: guidance_scale)
        updateGuidanceScale(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, guidance_scale: guidance_scale)
    }
    
    func updateGuidanceScale(workflow: inout Workflow?, nodeMetaTitle: String, guidance_scale: Double) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.guidanceScale = guidance_scale
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateStrength(to strength: Double) {
        self.strength = strength
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateStrength(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, strength: strength)
        updateStrength(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, strength: strength)
    }
    
    func updateStrength(workflow: inout Workflow?, nodeMetaTitle: String, strength: Double) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.strength = strength
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateSeed(to seed: Int) {
        self.seed = seed
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateSeed(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, seed: seed)
        updateSeed(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, seed: seed)
    }
    
    func updateSeed(workflow: inout Workflow?, nodeMetaTitle: String, seed: Int) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.seed = seed
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateGarmentDescription(to garmentDescription: String) {
        self.garmentDescription = garmentDescription
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateGarmentDescription(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, garmentDescription: garmentDescription)
        updateGarmentDescription(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, garmentDescription: garmentDescription)
    }
    
    func updateGarmentDescription(workflow: inout Workflow?, nodeMetaTitle: String, garmentDescription: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.garmentDescription = garmentDescription
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
    
    func updateNegativePrompt(to negativePrompt: String) {
        self.negativePrompt = negativePrompt
        let nodeMetaTitle = "Run IDM-VTON Inference"
        updateNegativePrompt(workflow: &defaultWorkflow, nodeMetaTitle: nodeMetaTitle, negativePrompt: negativePrompt)
        updateNegativePrompt(workflow: &pipelineWorkflow, nodeMetaTitle: nodeMetaTitle, negativePrompt: negativePrompt)
    }
    
    func updateNegativePrompt(workflow: inout Workflow?, nodeMetaTitle: String, negativePrompt: String) {
        guard var modifiedWorkflow = workflow else { return }
        
        for (key, anyNode) in modifiedWorkflow.workflow {
            switch anyNode.node {
            case .idmVTON(var node):
                if node.meta.title == nodeMetaTitle {
                    node.inputs.negativePrompt = negativePrompt
                    modifiedWorkflow.workflow[key] = AnyNode(node: .idmVTON(node))
                }
            default:
                continue
            }
        }
        
        workflow = modifiedWorkflow
    }
}

enum WorkflowError: Error {
    case noWorkflowLoaded(String)
}
