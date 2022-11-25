//
//  ExportView.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/23/22.
//

import SwiftUI
import RealityKit

struct ExportView: View {
    @Binding var applicationViewState: ApplicationViewState
    @ObservedObject var photogrammetryDelegate: PhotogrammetryDelegate
    @StateObject private var arContainerViewDelegate: ARContainerViewDelegate = ARContainerViewDelegate(frame: .zero)
    @State private var arContainerViewLoaded: Bool = false
    @State private var arContainerViewInfo: String = String()
    
    var body: some View {
        VStack (spacing: 15) {
            ZStack {
                if arContainerViewLoaded { ARContainerView(arContainerViewDelegate: arContainerViewDelegate) }
                else { Text(arContainerViewInfo) }
            }
            .frame(width: 320, height: 320)
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
            .onAppear {
                guard let modelEntityUrl = photogrammetryDelegate.outputModelUrl else {
                    arContainerViewInfo = "Missing model entity"
                    return
                }
                arContainerViewDelegate.loadModelEntity(modelEntityUrl: modelEntityUrl) { (result) in
                    if case .success(_) = result {
                        arContainerViewLoaded = true
                        arContainerViewDelegate.modelEntitySpinning = true
                    } else if case let .failure(error) = result {
                        arContainerViewInfo = error.localizedDescription
                    }
                }
            }
            .onDisappear {
                arContainerViewLoaded = false
                arContainerViewDelegate.modelEntitySpinning = false
                photogrammetryDelegate.removeOutputModel()
            }
            
            HStack {
                Button("Process Again") { applicationViewState = .onInputView }
                Spacer()
                Button("Export USDZ Model") { photogrammetryDelegate.openExportModelPanel { _ in } }
            }
            .frame(width: 320)
            .fixedSize()
        }
        .padding(.all, 20)
    }
}

// MARK: - ExportView Preview
struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(applicationViewState: Binding.constant(ApplicationViewState.onExportView),
                   photogrammetryDelegate: PhotogrammetryDelegate())
    }
}
