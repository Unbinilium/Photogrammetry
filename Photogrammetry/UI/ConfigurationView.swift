//
//  ConfigurationView.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/22/22.
//

import SwiftUI
import RealityKit

struct ConfigurationView: View {
    @Binding var applicationViewState: ApplicationViewState
    @ObservedObject var photogrammetryDelegate: PhotogrammetryDelegate
    
    var body: some View {
        VStack (alignment: .center, spacing: 15) {
            VStack (alignment: .leading, spacing: 5) {
                Spacer()
                Picker("Model Detail", selection: $photogrammetryDelegate.sessionRequestDetail) {
                    ForEach(PhotogrammetrySession.Request.Detail.allCases, id: \.self) {
                        Text($0).tag(PhotogrammetrySession.Request.Detail.init($0))
                    }
                }
                .pickerStyle(.menu)
                .padding([.leading, .trailing], 15)
                Text("Detail of output model in terms of mesh size and texture size")
                    .font(.footnote)
                    .padding([.leading, .trailing], 15)
                Spacer()
            }
            .frame(width: 320)
            .fixedSize()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            VStack (alignment: .leading, spacing: 5) {
                Spacer()
                HStack {
                    Text("Object Masking")
                    Spacer()
                    Toggle("Object Masking", isOn: $photogrammetryDelegate.sessionConfiguration.isObjectMaskingEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                .padding([.leading, .trailing], 15)
                Text("Whether RealityKit uses the provided masks to separate the foreground object from the background")
                    .font(.footnote)
                    .padding([.leading, .trailing], 15)
                
                Spacer()
                Picker("Feature Sensitivity", selection: $photogrammetryDelegate.sessionConfiguration.featureSensitivity) {
                    ForEach(PhotogrammetrySession.Configuration.FeatureSensitivity.allCases, id: \.self) {
                        Text($0).tag(PhotogrammetrySession.Configuration.FeatureSensitivity.init($0))
                    }
                }
                .padding([.leading, .trailing], 15)
                Text("Set to high if the scanned object does not contain a lot of discernible structures, edges or textures")
                    .font(.footnote)
                    .padding([.leading, .trailing], 15)
                
                Spacer()
                Picker("Sample Ordering", selection: $photogrammetryDelegate.sessionConfiguration.sampleOrdering) {
                    ForEach(PhotogrammetrySession.Configuration.SampleOrdering.allCases, id: \.self) {
                        Text($0).tag(PhotogrammetrySession.Configuration.SampleOrdering.init($0))
                    }
                }
                .padding([.leading, .trailing], 15)
                Text("Setting to sequential may speed up computation if images are captured in a spatially sequential pattern")
                    .font(.footnote)
                    .padding([.leading, .trailing], 15)
                Spacer()
            }
            .pickerStyle(.segmented)
            .frame(width: 320)
            .fixedSize()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            HStack {
                Button("Back") {
                    applicationViewState = ApplicationViewState.onInputView
                }
                Spacer()
                Button("Generate 3D Model") {
                    applicationViewState = ApplicationViewState.onProcessingView
                }
            }
            .frame(width: 320)
            .fixedSize()
        }
        .padding(.all, 20)
    }
}

// MARK: - ConfigurationView Preview
struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(
            applicationViewState: Binding.constant(ApplicationViewState.onConfigurationView),
            photogrammetryDelegate: PhotogrammetryDelegate())
    }
}
