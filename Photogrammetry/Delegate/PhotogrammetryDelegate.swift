//
//  PhotogrammetryDelegate.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/22/22.
//

import os
import Foundation
import UniformTypeIdentifiers
import AppKit
import RealityKit

class PhotogrammetryDelegate: ObservableObject {
    @Published var sessionRequestDetail: PhotogrammetrySession.Request.Detail = PhotogrammetrySession.Request.Detail()
    @Published var sessionConfiguration: PhotogrammetrySession.Configuration = PhotogrammetrySession.Configuration()
    @Published var sessionProgress: Double = 0
    @Published var sessionInfo: String = String()
    private var session: PhotogrammetrySession?
    private var logger: Logger = Logger(subsystem: "com.unbinilium.photogrammetry", category: "Photogrammetry")
    private var fileManager: FileManager = FileManager()
    public var outputModelUrl: URL?
    public var inputFolderUrl: URL? {
        didSet {
            guard let inputFolderUrl = inputFolderUrl else { return }
            let outputModelName = inputFolderUrl.lastPathComponent.appendingFormat(".usdz")
            let temporaryDirectoryUrl = fileManager.temporaryDirectory
            outputModelUrl = temporaryDirectoryUrl.appending(component: outputModelName)
        }
    }
    
    // MARK: - Helper Function
    public func checkAvailability() throws {
        if !PhotogrammetrySession.isSupported { throw PhotogrammetryDelegateError(error: .unsupportedHardware) }
    }
    
    public func cancelGeneratingModel() {
        if let session = session, session.isProcessing { self.session?.cancel() }
    }
    
    public func removeOutputModel() {
        guard let outputModelUrl = outputModelUrl else { return }
        DispatchQueue.global(qos: .background).async {
            do {
                self.logger.log("Removing output model: \(outputModelUrl.absoluteString)")
                try self.fileManager.removeItem(at: outputModelUrl)
            } catch { self.logger.error("\(String(describing: error))") }
        }
    }
    
    public func openInputFolderPanel(completion: @escaping (_ result: Result<URL, Error>) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowedContentTypes = [UTType.folder]
        panel.begin { (result) in
            if result == .OK {
                guard let folderUrl = panel.urls.first else { return completion(.failure(PhotogrammetryDelegateError(error: .failedOpenInputFolder))) }
                completion(.success(folderUrl))
            }
        }
    }
    
    public func openExportModelPanel(completion: @escaping (_ result: Result<URL, Error>) -> ()) {
        guard let outputModelUrl = outputModelUrl else {
            logger.error("\(PhotogrammetryDelegateError(error: .missingOutputModelUrl).localizedDescription)")
            return
        }
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = outputModelUrl.lastPathComponent
        panel.isExtensionHidden = true
        panel.showsTagField = true
        panel.allowedContentTypes = [.usdz]
        let response = panel.runModal()
        guard response == .OK, let exportFolderURL = panel.url else { return }
        DispatchQueue.global(qos: .background).async {
            do {
                try self.fileManager.copyItem(at: outputModelUrl, to: exportFolderURL)
                completion(.success(outputModelUrl))
            } catch {
                self.logger.error("\(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Generate Model
    public func generateModel(completion: @escaping (_ result: Result<URL, Error>) -> ()) {
        DispatchQueue.main.async {
            self.sessionProgress = 0
            self.sessionInfo = "Generating 3D Model..."
        }
        do {
            try self.checkAvailability()
            self.session = try createSession()
            guard let session = session else { throw PhotogrammetryDelegateError(error: .failedAccessSession) }
            let waiter = Task {
                do {
                    for try await output in session.outputs {
                        switch output {
                        case .processingComplete:
                            self.logger.log("Processing is complete")
                            DispatchQueue.main.async { self.sessionInfo = "Processing is complete" }
                            
                        case .requestError(let request, let error):
                            self.logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                            completion(.failure(PhotogrammetryDelegateError(error: .failedCompleteRequest)))
                            
                        case .requestComplete(let request, let result):
                            self.logger.log("Request \(String(describing: request)) had a result: \(String(describing: result))")
                            switch result {
                            case .modelFile(let url):
                                completion(.success(url))
                            default:
                                completion(.failure(PhotogrammetryDelegateError(error: .unexpectedRequestResult, comment: String(describing: result))))
                            }

                        case .requestProgress(let request, let fractionComplete):
                            self.logger.log("Progress(request = \(String(describing: request)) = \(fractionComplete)")
                            DispatchQueue.main.async { self.sessionProgress = fractionComplete }
                            
                        case .inputComplete:
                            self.logger.log("Data ingestion is complete, beginning processing...")
                            DispatchQueue.main.async { self.sessionInfo = "Data ingestion is complete, beginning processing..." }
                            
                        case .invalidSample(let id, let reason):
                            self.logger.warning("Invalid Sample, id=\(id) reason=\"\(reason)\"")
                            
                        case .skippedSample(let id):
                            self.logger.warning("Sample id=\(id) was skipped by processing")
                            
                        case .automaticDownsampling:
                            self.logger.warning("Automatic downsampling was applied")
                            DispatchQueue.main.async { self.sessionInfo = "Automatic downsampling was applied" }
                            
                        case .processingCancelled:
                            self.logger.warning("Request of the session request was cancelled")
                            DispatchQueue.main.async { self.sessionInfo = "Request of the session request was cancelled" }
                            
                        @unknown default:
                            self.logger.warning("Unhandled output message: \(String(describing: output))")
                        }
                    }
                } catch { completion(.failure(error)) }
            }
            withExtendedLifetime((session, waiter)) {
                do {
                    let request = try self.createRequest()
                    try session.process(requests: [request])
                } catch { completion(.failure(error)) }
            }
        } catch { completion(.failure(error)) }
    }
    
    // MARK: - Object Create Function
    private func createSession() throws -> PhotogrammetrySession {
        guard let inputFolderUrl = inputFolderUrl else { throw PhotogrammetryDelegateError(error: .missingInputFolderUrl) }
        do { return try PhotogrammetrySession(input: inputFolderUrl, configuration: sessionConfiguration) }
        catch { throw PhotogrammetryDelegateError(error: .failedCreateSession, comment: String(describing: error)) }
    }
    
    private func createRequest() throws -> PhotogrammetrySession.Request {
        guard let outputModelUrl = outputModelUrl else { throw PhotogrammetryDelegateError(error: .missingOutputModelUrl) }
        return PhotogrammetrySession.Request.modelFile(url: outputModelUrl, detail: self.sessionRequestDetail)
    }
}
