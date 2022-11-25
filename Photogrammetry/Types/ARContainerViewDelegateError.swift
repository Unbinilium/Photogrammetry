//
//  ARContainerViewDelegateError.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/24/22.
//

import Foundation

struct ARContainerViewDelegateError: Error {
    enum ErrorType {
        case failedLoadingEntity
    }
    
    var error: ErrorType
    var comment: String
    
    init(error: ErrorType, comment: String = String()) {
        self.error = error
        self.comment = comment
    }
}

extension ARContainerViewDelegateError: LocalizedError {
    public var errorDescription: String? {
        switch self.error {
        case .failedLoadingEntity:
            return NSLocalizedString("Failed on loading AR model entity! ", comment: self.comment)
        }
    }
}
