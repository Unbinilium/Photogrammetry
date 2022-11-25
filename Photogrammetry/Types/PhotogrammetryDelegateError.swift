//
//  PhotogrammetryDelegateError.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/23/22.
//

import Foundation

struct PhotogrammetryDelegateError: Error {
    enum ErrorType {
        case unsupportedHardware
        case missingInputFolderUrl
        case missingOutputModelUrl
        case failedOpenInputFolder
        case failedCreateSession
        case failedAccessSession
        case failedCompleteRequest
        case unexpectedRequestResult
    }
    
    var error: ErrorType
    var comment: String
    
    init(error: ErrorType, comment: String = String()) {
        self.error = error
        self.comment = comment
    }
}

extension PhotogrammetryDelegateError: LocalizedError {
    public var errorDescription: String? {
        switch self.error {
        case .unsupportedHardware:
            return NSLocalizedString("This Mac does not meet the hardware requirement of Photogrammetry! ", comment: self.comment)
            
        case .missingInputFolderUrl:
            return NSLocalizedString("Missing input image folder location! ", comment: self.comment)
            
        case .missingOutputModelUrl:
            return NSLocalizedString("Missing output model location! ", comment: self.comment)
            
        case .failedOpenInputFolder:
            return NSLocalizedString("Failed to get input folder location! ", comment: self.comment)
        
        case .failedCreateSession:
            return NSLocalizedString("Failed on creating session ", comment: self.comment)
            
        case .failedAccessSession:
            return NSLocalizedString("Failed on accessing an uninitialized session! ", comment: self.comment)
            
        case .failedCompleteRequest:
            return NSLocalizedString("Failed on processing 3D model request, please check the input images and photogrammetry configurations! ", comment: self.comment)
            
        case .unexpectedRequestResult:
            return NSLocalizedString("Encounter an unexpected request result! ", comment: self.comment)
        }
    }
}
