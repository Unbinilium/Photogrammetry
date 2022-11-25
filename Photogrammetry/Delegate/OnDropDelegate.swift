//
//  OnDropDelegate.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/21/22.
//

import UniformTypeIdentifiers
import SwiftUI

struct OnDropDelegate: DropDelegate {
    @Binding var applicationViewState: ApplicationViewState
    @ObservedObject var photogrammetryDelegate: PhotogrammetryDelegate
    
    func validateDrop(info: DropInfo) -> Bool { return info.hasItemsConforming(to: ["public.file-url"]) }
    
    func dropEntered(info: DropInfo) { NSSound(named: "Morse")?.play() }
    
    func performDrop(info: DropInfo) -> Bool {
        NSSound(named: "Submarine")?.play()
        guard let itemProvider = info.itemProviders(for: ["public.file-url"]).first else { return false }
        DispatchQueue.main.async {
            guard let identifier = itemProvider.registeredTypeIdentifiers.first else { return }
            itemProvider.loadItem(forTypeIdentifier: identifier) { (urlData, error) in
                if let urlData = urlData as? Data {
                    let itemUrl = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                    if itemUrl.isDirectory == true {
                        photogrammetryDelegate.inputFolderUrl = itemUrl
                        applicationViewState = .onConfigurationView
                    }
                }
            }
        }
        return true
    }
}
