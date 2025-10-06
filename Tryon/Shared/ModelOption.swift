//
//  ModelOption.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 29/9/25.
//

import SwiftUI

protocol SizedModel: Identifiable {
    var id: UUID { get }
    var label: String { get set }
    var value: String { get }
    var sizeMB: Double { get }
}

struct ModelOption: SizedModel {
    let id = UUID()
    var label: String
    let value: String
    let sizeMB: Double
}

func sortAndLabel<T: SizedModel> (_ models: [T], smallestSizeLabel: String, largestSizeLabel: String, defaultModel: String? = nil) -> [T] {
    guard !models.isEmpty else { return models }
    
    let sorted = models.sorted { $0.sizeMB < $1.sizeMB }
    return sorted.enumerated().map { index, model in
        var updatedModel = model
        if index == 0 && !smallestSizeLabel.isEmpty {
            updatedModel.label += " (\(smallestSizeLabel))"
        } else if index == sorted.count - 1 && !largestSizeLabel.isEmpty {
            updatedModel.label += " (\(largestSizeLabel))"
        }
        if updatedModel.value == defaultModel {
            updatedModel.label = "(Default) " + updatedModel.label
        }
        return updatedModel
    }
}
