//
//  Engine.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 25.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SceneKit
import Combine

class Engine: NSObject, ObservableObject {

    private let greyColor = UIColor(red: 238.0 / 256.0, green: 238.0 / 256.0, blue: 238.0 / 256.0, alpha: 1)
    private let metalColor = UIColor.white

    var state: TurbineState
    var scene: SCNScene

    @Published var controlModel: ControlModel
    
    private let callback = PassthroughSubject<TurbineState, Never>()

    private var blades = [[SCNNode]]()
    private var baffles = [SCNNode]()
    private var kernelAngle: Int = 0

    private var transPanMeshXY = SCNNode()
    private var transPanMeshYZ = SCNNode()
    private var transPanMeshXZ = SCNNode()
    private var transPanMeshCenter = SCNNode()

    private let semaphore = DispatchSemaphore(value: 1)

    private var s: AnyCancellable?

    override init() {
        let unit: Float = 300
        self.state = TurbineState(
            canvasWidth: 50,
            canvasHeight: 50,
            tankDiameter: unit,
            tankHeight: unit,
            shaftRadius: unit * 2 / 75,
            kernelAutoRotation: true,
            kernelRotationDir: "clockwise",
            baffleCount: 4,
            baffleInnerRadius: unit * 2 / 5,
            baffleOuterRadius: unit / 2,
            baffleWidth: unit / 75,
            impellerCount: 3,
            hubRadius: [unit * 4 / 75, unit * 4 / 75, unit * 4 / 75],
            hubHeight: [unit / 15, unit / 15, unit / 15],
            diskRadius: [unit / 8, unit / 8, unit / 8],
            diskHeight: [unit / 75, unit / 75, unit / 75],
            bladeCount: [6, 6, 6],
            bladeInnerRadius: [unit / 12, unit / 12, unit / 12],
            bladeOuterRadius: [unit / 6, unit / 6, unit / 6],
            bladeWidth: [unit / 75, unit / 75, unit / 75],
            bladeHeight: [unit / 15, unit / 15, unit / 15],
            transPanXY: 0,
            transPanYZ: 0,
            transPanXZ: 0,
            transRotateAngle: 0,
            transEnableXY: false,
            transEnableYZ: false,
            transEnableXZ: false,
            transEnableImpeller: false,
            transEnableRotate: false
        )

        self.scene = SCNScene()
        self.controlModel = ControlModel(state: self.state, callback: callback)
        
        super.init()
        
        s = callback.sink { [weak self] value in
            if let this = self {
                this.controlModel = ControlModel(state: value, callback: this.callback)
                this.state = value
                this.createScene()
            }
        }

        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 10000

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.simdPosition = simd_float3(0, state.tankHeight * 2, state.tankDiameter * 3)
        cameraNode.simdRotation = simd_float4(1, 0, 0, -30 * Float.pi / 180)
        scene.rootNode.addChildNode(cameraNode)

        let light = SCNLight()
        light.type = .spot
        light.intensity = 500
        light.color = UIColor.white

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.simdPosition = simd_float3(0, 0, state.tankDiameter * 3)
        scene.rootNode.addChildNode(lightNode)

        createShadowLight(x: 0, y: 0, z: 1)
        createShadowLight(x: 0, y: 1, z: 0)
        createShadowLight(x: 1, y: 0, z: 0)
        
        createScene()
    }

    private func update() {
        switch state.kernelRotationDir {
        case "clockwise":
            kernelAngle = (kernelAngle + 1) % 360
            for i in 0..<state.impellerCount {
                updateBlades(innerRadius: state.bladeInnerRadius[i], outerRadius: state.bladeOuterRadius[i], num: i);
            }
        case "counter-clockwise":
            kernelAngle = (kernelAngle - 1) % 360
            for i in 0..<state.impellerCount {
                updateBlades(innerRadius: state.bladeInnerRadius[i], outerRadius: state.bladeOuterRadius[i], num: i)
            }
        default:
            break
        }
    }
    
    private func createScene() {
        SCNTransaction.lock()

        let array = scene.rootNode.childNodes
        // camera, light, shadow light #1, shadow light #2, shadow light #3
        for i in 5..<array.count {
            array[i].removeFromParentNode()
        }
        
        blades.removeAll()
        baffles.removeAll()
        
        createTank()
        createShaft()

        for i in 0..<state.impellerCount {
            blades.append([])
            createHub(num: i, count: state.impellerCount)
            createDisk(num: i, count: state.impellerCount)
            changeBladeCount(newValue: state.bladeCount[i], oldValue: 0, num: i)
        }

        changeBaffleCount(newValue: state.baffleCount, oldValue: 0)
        updateBaffles(baffleInnerRadius: state.baffleInnerRadius, baffleOuterRadius: state.baffleOuterRadius)

        createTransPan(d: state.tankDiameter, h: state.tankHeight)

        SCNTransaction.unlock()
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

    private func createTank() {
        let geometry = SCNCylinder(radius: CGFloat(state.tankDiameter) / 2, height: CGFloat(state.tankHeight))
        geometry.firstMaterial?.diffuse.contents = greyColor
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "tank"
        node.opacity = 0.3
        scene.rootNode.addChildNode(node)
    }

    private func createShaft() {
        let geometry = SCNCylinder(radius: CGFloat(state.shaftRadius), height: CGFloat(state.tankHeight))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "shaft"
        scene.rootNode.addChildNode(node)
    }

    private func createHub(num: Int, count: Int) {
        let radius = state.hubRadius[num]
        let height = state.hubHeight[num]

        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "hub\(num)"
        node.position = SCNVector3(0, getImpellerPositionY(num: num, count: count), 0)
        scene.rootNode.addChildNode(node)
    }

    private func createDisk(num: Int, count: Int) {
        let radius = state.diskRadius[num]
        let height = state.diskHeight[num]

        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "disk\(num)"
        node.position = SCNVector3(0, getImpellerPositionY(num: num, count: count), 0)
        scene.rootNode.addChildNode(node)
    }

    private func changeBladeCount(newValue: Int, oldValue: Int, num: Int) {
        if newValue < oldValue {
            // TODO
        } else if newValue > oldValue {
            for _ in oldValue..<newValue {
                let geometry = SCNBox(
                    width: CGFloat(state.bladeWidth[num]),
                    height: CGFloat(state.bladeHeight[num]),
                    length: CGFloat(state.bladeOuterRadius[num] - state.bladeInnerRadius[num]),
                    chamferRadius: 0
                )
                geometry.firstMaterial?.diffuse.contents = greyColor
                geometry.firstMaterial?.lightingModel = .phong

                let node = SCNNode(geometry: geometry)
                node.name = "blade\(num)"
                blades[num].append(node)
                scene.rootNode.addChildNode(node)
            }
        }
    }

    private func updateBlades(innerRadius: Float, outerRadius: Float, num: Int) {
        let distance = (innerRadius + outerRadius) / 2
        let yAxis = simd_float3(0, 1, 0)

        let count = state.impellerCount
        let offset = simd_float3(0, getImpellerPositionY(num: num, count: count), 0)
        for j in 0..<blades[num].count {
            let angle = (360 * j / blades[num].count + kernelAngle) % 360
            let radianAngle = 2 * Float.pi * Float(angle) / 360

            let v1 = simd_float4(0, 0, distance, 1)
            let m1 = float4x4(rotationAbout: yAxis, by: radianAngle)
            blades[num][j].simdPosition = (m1 * v1).xyz + offset

            blades[num][j].simdEulerAngles = simd_float3(0, radianAngle, 0)
        }
    }

    private func getImpellerPositionY(num: Int, count: Int) -> Float {
        let tankHeight = state.tankHeight
        return tankHeight / -2 + tankHeight / Float(count + 1) * Float(num + 1)
    }

    private func createTransPan(d: Float, h: Float) {
        let thickness: Float = 2
        transPanMeshXY = createTranslucentPan(width: d * 1.1, height: h * 1.1, length: thickness)
        transPanMeshYZ = createTranslucentPan(width: thickness, height: h * 1.1, length: d * 1.1)
        transPanMeshXZ = createTranslucentPan(width: d * 1.1, height: thickness, length: d * 1.1)
        transPanMeshCenter = createTranslucentPan(width: d / 2, height: h, length: thickness)

        scene.rootNode.addChildNode(transPanMeshXY)
        scene.rootNode.addChildNode(transPanMeshYZ)
        scene.rootNode.addChildNode(transPanMeshXZ)
        transPanMeshCenter.position.x = d / 4

        scene.rootNode.addChildNode(transPanMeshCenter)
    }

    private func createTranslucentPan(width: Float, height: Float, length: Float) -> SCNNode {
        let geometry = SCNBox(
            width: CGFloat(width),
            height: CGFloat(height),
            length: CGFloat(length),
            chamferRadius: 0
        )
        geometry.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "transPan"
        node.opacity = 0.8
        node.isHidden = true
        return node
    }

    private func changeBaffleCount(newValue: Int, oldValue: Int) {
        if newValue < oldValue {
            // TODO
        } else if newValue > oldValue {
            for _ in oldValue..<newValue {
                let geometry = SCNBox(
                    width: CGFloat(state.baffleWidth),
                    height: CGFloat(state.tankHeight),
                    length: CGFloat(state.baffleOuterRadius - state.baffleInnerRadius),
                    chamferRadius: 0
                )
                geometry.firstMaterial?.diffuse.contents = greyColor
                geometry.firstMaterial?.lightingModel = .phong

                let node = SCNNode(geometry: geometry)
                node.name = "baffle"
                baffles.append(node)
                scene.rootNode.addChildNode(node)
            }
        }
    }

    private func updateBaffles(baffleInnerRadius: Float, baffleOuterRadius: Float) {
        let distance = (baffleInnerRadius + baffleOuterRadius) / 2
        let yAxis = simd_float3(0, 1, 0)
        for i in 0..<baffles.count {
            let angle = 2 * Float.pi * Float(i) / Float(baffles.count)

            let v1 = simd_float4(0, 0, distance, 1)
            let m1 = float4x4(rotationAbout: yAxis, by: angle)
            baffles[i].simdPosition = (m1 * v1).xyz

            baffles[i].simdEulerAngles = simd_float3(0, angle, 0)
        }
    }
}

extension Engine: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        update()
    }
}

struct TurbineState {
    var canvasWidth: Float
    var canvasHeight: Float
    var tankDiameter: Float
    var tankHeight: Float
    var shaftRadius: Float
    var kernelAutoRotation: Bool
    var kernelRotationDir: String
    var baffleCount: Int
    var baffleInnerRadius: Float
    var baffleOuterRadius: Float
    var baffleWidth: Float

    var impellerCount: Int
    var hubRadius: [Float]
    var hubHeight: [Float]
    var diskRadius: [Float]
    var diskHeight: [Float]
    var bladeCount: [Int]
    var bladeInnerRadius: [Float]
    var bladeOuterRadius: [Float]
    var bladeWidth: [Float]
    var bladeHeight: [Float]

    var transPanXY: Float
    var transPanYZ: Float
    var transPanXZ: Float
    var transRotateAngle: Int
    var transEnableXY: Bool
    var transEnableYZ: Bool
    var transEnableXZ: Bool
    var transEnableImpeller: Bool
    var transEnableRotate: Bool
    
    func changeValues(tankDiameter: Float? = nil, tankHeight: Float? = nil, shaftRadius: Float? = nil, impellerCount: Int? = nil) -> TurbineState {
        return TurbineState(
            canvasWidth: self.canvasWidth,
            canvasHeight: self.canvasHeight,
            tankDiameter: tankDiameter ?? self.tankDiameter,
            tankHeight: tankHeight ?? self.tankHeight,
            shaftRadius: shaftRadius ?? self.shaftRadius,
            kernelAutoRotation: self.kernelAutoRotation,
            kernelRotationDir: self.kernelRotationDir,
            baffleCount: self.baffleCount,
            baffleInnerRadius: self.baffleInnerRadius,
            baffleOuterRadius: self.baffleOuterRadius,
            baffleWidth: self.baffleWidth,
            impellerCount: impellerCount ?? self.impellerCount,
            hubRadius: update(newCount: impellerCount, array: self.hubRadius),
            hubHeight: update(newCount: impellerCount, array: self.hubHeight),
            diskRadius: update(newCount: impellerCount, array: self.diskRadius),
            diskHeight: update(newCount: impellerCount, array: self.diskHeight),
            bladeCount: update(newCount: impellerCount, array: self.bladeCount),
            bladeInnerRadius: update(newCount: impellerCount, array: self.bladeInnerRadius),
            bladeOuterRadius: update(newCount: impellerCount, array: self.bladeOuterRadius),
            bladeWidth: update(newCount: impellerCount, array: self.bladeWidth),
            bladeHeight: update(newCount: impellerCount, array: self.bladeHeight),
            transPanXY: 0,
            transPanYZ: 0,
            transPanXZ: 0,
            transRotateAngle: 0,
            transEnableXY: false,
            transEnableYZ: false,
            transEnableXZ: false,
            transEnableImpeller: false,
            transEnableRotate: false
        )
    }
}

private func update<T>(newCount: Int?, array: [T]) -> [T] {
    if let value = newCount {
        if value < array.count {
            return Array<T>(array.prefix(value))
        } else if value > array.count {
            return array + Array<T>(repeating: array[0], count: value - array.count)
        }

        return array
    } else {
        return array
    }
}
