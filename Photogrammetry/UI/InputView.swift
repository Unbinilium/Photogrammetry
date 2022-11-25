//
//  InputView.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/19/22.
//

import SwiftUI

struct InputView: View {
    @Binding var applicationViewState: ApplicationViewState
    @ObservedObject var photogrammetryDelegate: PhotogrammetryDelegate
    @State private var openFolderAlert: Bool = false
    @State private var openFolderAlertInfo: String = String()
    
    var body: some View {
        VStack() {
            VStack (spacing: 5) {
                Text("Drag and drop Image Folder")
                Text("(A folder with 20~60 images is recommend)").font(.footnote)
            }
            .frame(width: 320, height: 280)
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
            .onDrop(of: ["public.file-url"], delegate: OnDropDelegate(
                applicationViewState: $applicationViewState,
                photogrammetryDelegate: photogrammetryDelegate))
            
            Text("or") .italic()
            
            Button("Open Image Folder") {
                photogrammetryDelegate.openInputFolderPanel { (result) in
                    if case let .success(folderUrl) = result {
                        photogrammetryDelegate.inputFolderUrl = folderUrl
                        applicationViewState = .onConfigurationView
                    } else if case let .failure(error) = result {
                        openFolderAlertInfo = error.localizedDescription
                        openFolderAlert = true
                    }
                }
            }
        }
        .padding(.all, 20)
        .alert(openFolderAlertInfo, isPresented: $openFolderAlert) { Button("OK", role: .cancel) { } }
    }
}

// MARK: - InputView Preview
struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(
            applicationViewState: Binding.constant(ApplicationViewState.onInputView),
            photogrammetryDelegate: PhotogrammetryDelegate())
    }
}
