//
//  PhotogrammetrySession.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/22/22.
//

import RealityKit

@available(macOS 12.0, *)
extension PhotogrammetrySession.Request.Detail {
    public static var allCases = ["Preview", "Reduced", "Medium", "Full", "Raw"]
    
    init(_ detail: String = String()) {
        switch detail {
        case "Preview": self = .preview
        case "Reduced": self = .reduced
        case "Medium": self = .medium
        case "Full": self = .full
        case "Raw": self = .raw
        default: self = .preview
        }
    }
}

@available(macOS 12.0, *)
extension PhotogrammetrySession.Configuration.FeatureSensitivity {
    public static var allCases = ["Normal", "High"]
    
    init(_ featureSensitivity: String = String()) {
        switch featureSensitivity {
        case "Normal": self = .normal
        case "High": self = .high
        default: self = .normal
        }
    }
}

@available(macOS 12.0, *)
extension PhotogrammetrySession.Configuration.SampleOrdering {
    public static var allCases = ["Unordered", "Sequential"]
    
    init(_ sampleOrdering: String = String()) {
        switch sampleOrdering {
        case "Unordered": self = .unordered
        case "Sequential": self = .sequential
        default: self = .unordered
        }
    }
}
