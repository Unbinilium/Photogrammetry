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
                .onAppear { NSWindow.allowsAutomaticWindowTabbing = false }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Photogrammetry") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "Made with Love by Unbinilium, 2022.",
                                attributes: [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)])
                        ]
                    )
                }
            }
        }
    }
}
