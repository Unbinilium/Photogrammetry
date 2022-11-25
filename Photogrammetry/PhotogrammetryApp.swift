//
//  PhotogrammetryApp.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/19/22.
//

import SwiftUI

@main
struct PhotogrammetryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(VibrancyView().ignoresSafeArea())
                .fixedSize()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
