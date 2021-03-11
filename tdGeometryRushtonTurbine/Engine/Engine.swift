//
//  Engine.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 25.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SceneKit
import Combine
import tdLBGeometryRushtonTurbineLib


enum EngineAction {
    case pick([String], (URL) -> Void)
}

class Engine: NSObject, ObservableObject {
    var state: RushtonTurbineRenderState
    var scene: SCNScene

    let actionSubject = PassthroughSubject<EngineAction, Never>()

    @Published var kernelAngle: Int = 0
    
    let grid = SCNNode()
    let tank = SCNNode()
    let shaft = SCNNode()

    var disks = [SCNNode]()
    var hubs = [SCNNode]()
    var blades = [[SCNNode]]()
    var baffles = [SCNNode]()
    

    var transPanMeshXY = SCNNode()
    var transPanMeshYZ = SCNNode()
    var transPanMeshXZ = SCNNode()
    
    var transPanMeshCenter = SCNNode()

    var cancellables = Set<AnyCancellable>()

    private var tankPublisher: AnyPublisher<(Int, Int), Never> {
        Publishers
            .CombineLatest(
                state.turbine.$tankDiameter.removeDuplicates(),
                state.turbine.$tankHeight.removeDuplicates()
            )
            .eraseToAnyPublisher()
    }
    
    var turbineNode: RushtonTurbineNode?
    
    init(state: RushtonTurbineRenderState) {
        self.state = state
        self.scene = SCNScene()
        
        super.init()
        
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 10000

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.simdPosition = simd_float3(0, Float(state.turbine.tankHeight) * 1.8, Float(state.turbine.tankDiameter) * 3)
        cameraNode.simdRotation = simd_float4(1, 0, 0, -30 * Float.pi / 180)
        scene.rootNode.addChildNode(cameraNode)

        let light = SCNLight()
        light.type = .spot
        light.intensity = 500
        light.color = UIColor.white

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.simdPosition = simd_float3(0, 0, Float(state.turbine.tankDiameter) * 3)
        scene.rootNode.addChildNode(lightNode)

        createShadowLight(x: 0, y: 0, z: 1)
        createShadowLight(x: 0, y: 1, z: 0)
        createShadowLight(x: 1, y: 0, z: 0)

        
        createPlane()
        
        self.turbineNode = RushtonTurbineNode(state: state, update: self.$kernelAngle.eraseToAnyPublisher())
        scene.rootNode.addChildNode(turbineNode!)
    }
    
    func createPlane() {
        grid.geometry = createGrid(size: 1000, divisions: 50, color1: 0x444444, color2: 0x888888)
        grid.position.y = 0
        scene.rootNode.addChildNode(grid)
    }
    
    func update() {
        switch state.kernelRotationDir {
        case "clockwise":
            kernelAngle = (kernelAngle + 1) % 360
        case "counter-clockwise":
            kernelAngle = (kernelAngle - 1) % 360
        default:
            break
        }
    }

    private func createShadowLight(x: Float, y: Float, z: Float) {
        let light = SCNLight()
        light.type = .directional
        light.intensity = 1
        light.color = UIColor(red: 85.0 / 256.0, green: 80.0 / 256.0, blue: 90.0 / 256.0, alpha: 1)
        light.castsShadow = true
        light.zNear = 1
        light.zFar = 9000
        light.shadowMapSize = CGSize(width: 1024, height: 1024)

        let lightNode = SCNNode()
        lightNode.light = light
        let distance: Float = 3000
        lightNode.simdPosition = simd_float3(x, y, z) * distance
        scene.rootNode.addChildNode(lightNode)
    }
}

extension Engine: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.update()
    }
}
