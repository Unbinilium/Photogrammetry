//
//  ARContainerViewDelegate.swift
//  Photogrammetry
//
//  Created by Unbinilium on 11/24/22.
//

import AppKit
import Foundation
import RealityKit
import CoreGraphics

class ARContainerViewDelegate: ARView, ObservableObject {
    private var screen: NSScreen = NSScreen()
    private var cameraEntity: PerspectiveCamera = PerspectiveCamera()
    private var cameraAnchor: AnchorEntity = AnchorEntity(world: .zero)
    private var modelEntity: Entity = Entity()
    private var modelAnchor: AnchorEntity = AnchorEntity(world: .zero)
    private var modelRadius: Float = 0 { didSet { self.updateCamera() } }
    public var modelEntitySpinning: Bool = false { didSet { self.spinModelEntity() } }
    public var modelEntityRotationAngle: Float = 0 { didSet { self.updateCamera() } }
    
    public required init(frame: NSRect) {
        super.init(frame: frame)
        self.environment.background = .color(.clear)
        self.cameraEntity.camera.fieldOfViewInDegrees = 80
        self.cameraAnchor.addChild(self.cameraEntity)
        self.modelAnchor.addChild(self.modelEntity)
        self.scene.anchors.append(self.cameraAnchor)
        self.scene.anchors.append(self.modelAnchor)
        self.updateCamera()
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update Camera
    @MainActor private func updateCamera() {
        let translationTransform = Transform(scale: .one, rotation: simd_quatf(), translation: SIMD3<Float>(0, 0, self.modelRadius))
        let rotationTransform = Transform(pitch: 0, yaw: modelEntityRotationAngle, roll: 0)
        let computedTransform = matrix_identity_float4x4 * rotationTransform.matrix * translationTransform.matrix
        self.cameraAnchor.transform = Transform(matrix: computedTransform)
    }
    
    // MARK: - Load Model Entity
    @MainActor public func loadModelEntity(modelEntityUrl: URL, completion: @escaping (_ result: Result<Entity, Error>) -> ()) {
        do {
            self.scene.anchors.remove(self.modelAnchor)
            self.modelAnchor.removeChild(self.modelEntity)
            self.modelEntity = try Entity.load(contentsOf: modelEntityUrl)
            let modelEntityBounds = self.modelEntity.visualBounds(relativeTo: nil)
            let modelEntityBoundSize = max(modelEntityBounds.max.x, modelEntityBounds.max.y, modelEntityBounds.max.z)
            self.modelRadius = modelEntityBoundSize * 1.8
            self.modelAnchor.addChild(self.modelEntity)
            self.scene.anchors.append(self.modelAnchor)
            completion(.success(self.modelEntity))
        } catch { completion(.failure(ARContainerViewDelegateError(error: .failedLoadingEntity, comment: String(describing: error)))) }
    }
    
    // MARK: - Spin Model Entity
    private func spinModelEntity() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + screen.minimumRefreshInterval) {
            self.modelEntityRotationAngle += Float(self.screen.minimumRefreshInterval) * 2.0
            if self.modelEntitySpinning { self.spinModelEntity() }
        }
    }
}