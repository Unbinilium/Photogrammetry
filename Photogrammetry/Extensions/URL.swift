//
//  URL.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/22/22.
//

import Foundation
import AppKit

extension URL {
    var isDirectory: Bool? {
        do {
            return try resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
