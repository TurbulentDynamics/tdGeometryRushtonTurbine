//
//  Engine.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 25.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SceneKit
import Combine

enum EngineAction {
    case pick([String], (URL) -> Void)
}

class Engine: NSObject, ObservableObject {

    private let greyColor = UIColor(red: 238.0 / 256.0, green: 238.0 / 256.0, blue: 238.0 / 256.0, alpha: 1)
    private let metalColor = UIColor.white

    var state: TurbineState
    var scene: SCNScene

    @Published var controlModel: ControlModel

    let actionSubject = PassthroughSubject<EngineAction, Never>()

    private let callback = PassthroughSubject<TurbineState, Never>()

    private let grid = SCNNode()
    private let tank = SCNNode()
    private let shaft = SCNNode()

    private var disks = [SCNNode]()
    private var hubs = [SCNNode]()
    private var blades = [[SCNNode]]()
    private var baffles = [SCNNode]()
    private var kernelAngle: Int = 0

    private var transPanMeshXY = SCNNode()
    private var transPanMeshYZ = SCNNode()
    private var transPanMeshXZ = SCNNode()
    private var transPanMeshCenter = SCNNode()

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
            self?.updateState(newState: value)
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

        createPlane()
        createTransPan(d: state.tankDiameter, h: state.tankHeight)
    }

    func loadJson() {
        actionSubject.send(.pick([], { [weak self] url in
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let object = try decoder.decode(JData.self, from: data)
                self?.updateState(newState: JData.create(object))
            } catch {
                // TODO show error
                print(error)
            }
        }))
    }

    func saveJson() {
        actionSubject.send(.pick([kUTTypeFolder as String], { [weak self] url in
            guard let state = self?.state else {
                return
            }

            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(JData.create(state))
                try data.write(to: url, options: .atomic)
            } catch {
                // TODO show error
                print(error)
            }
        }))
    }

    private func updateState(newState: TurbineState) {
        let oldState = state

        state = newState
        controlModel = ControlModel(state: newState, callback: callback)

        SCNTransaction.lock()
        if newState.impellerCount != oldState.impellerCount {
            changeImpellerCount(newValue: newState.impellerCount, oldValue: oldState.impellerCount)
        } else {
            for i in 0..<oldState.impellerCount {
                if newState.bladeCount[i] != oldState.bladeCount[i] {
                    changeBladeCount(newValue: newState.bladeCount[i], oldValue: oldState.bladeCount[i], num: i)
                }

                if newState.bladeInnerRadius[i] != oldState.bladeInnerRadius[i] ||
                    newState.bladeOuterRadius[i] != oldState.bladeOuterRadius[i] ||
                    newState.bladeWidth[i] != oldState.bladeWidth[i] ||
                    newState.bladeHeight[i] != oldState.bladeHeight[i] {
                    changeBladeGeometry(
                        innerRadius: newState.bladeInnerRadius[i],
                        outerRadius: newState.bladeOuterRadius[i],
                        width: newState.bladeWidth[i],
                        height: newState.bladeHeight[i],
                        num: i
                    )
                }

                if newState.hubRadius[i] != oldState.hubRadius[i] || newState.hubHeight[i] != oldState.hubHeight[i] {
                    updateHub(radius: newState.hubRadius[i], height: newState.hubHeight[i], num: i)
                }

                if newState.diskRadius[i] != oldState.diskRadius[i] || newState.diskHeight[i] != oldState.diskHeight[i] {
                    updateDisk(radius: newState.diskRadius[i], height: newState.diskHeight[i], num: i)
                }
            }
        }

        if newState.baffleCount != oldState.baffleCount {
            changeBaffleCount(newValue: newState.baffleCount, oldValue: oldState.baffleCount)
        }

        if newState.transPanXY != oldState.transPanXY {
            changeTransPan(type: .XY, value: Float(newState.transPanXY))
        } else if newState.transPanYZ != oldState.transPanYZ {
            changeTransPan(type: .YZ, value: Float(newState.transPanYZ))
        } else if newState.transPanXZ != oldState.transPanXZ {
            changeTransPan(type: .XZ, value: Float(newState.transPanXZ))
        } else if newState.transRotateAngle != oldState.transRotateAngle {
            changeTransPan(type: .Rotate, value: Float(newState.transRotateAngle))
        }

        if newState.transEnableXY != oldState.transEnableXY {
            changeTransEnable(type: .XY, value: newState.transEnableXY)
        } else if newState.transEnableYZ != oldState.transEnableYZ {
            changeTransEnable(type: .YZ, value: newState.transEnableYZ)
        } else if newState.transEnableXZ != oldState.transEnableXZ {
            changeTransEnable(type: .XZ, value: newState.transEnableXZ)
        } else if newState.transEnableRotate != oldState.transEnableRotate {
            changeTransEnable(type: .Rotate, value: newState.transEnableRotate)
        }

        if newState != oldState {
            updatePlane(tankHeight: newState.tankHeight)
            updateTank(tankDiameter: newState.tankDiameter, tankHeight: newState.tankHeight)
            updateShaft(shaftRadius: newState.shaftRadius, tankHeight: newState.tankHeight)

            updateTransPan(d: newState.tankDiameter, h: newState.tankHeight)

            updateBaffles(baffleInnerRadius: newState.baffleInnerRadius, baffleOuterRadius: newState.baffleOuterRadius)
        }
        SCNTransaction.unlock()
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

    private func createPlane() {
        grid.geometry = createGrid(size: 1000, divisions: 50, color1: 0x444444, color2: 0x888888)
        grid.position.y = -(state.tankHeight / 2)
        scene.rootNode.addChildNode(grid)
    }

    private func updatePlane(tankHeight: Float) {
        grid.position.y = -(tankHeight / 2);
    }

    private func createTank() {
        let geometry = SCNCylinder(radius: CGFloat(state.tankDiameter) / 2, height: CGFloat(state.tankHeight))
        geometry.firstMaterial?.diffuse.contents = greyColor
        geometry.firstMaterial?.lightingModel = .phong

        tank.geometry = geometry
        tank.name = "tank"
        tank.opacity = 0.3
        scene.rootNode.addChildNode(tank)
    }

    private func updateTank(tankDiameter: Float, tankHeight: Float) {
        let geometry = SCNCylinder(radius: CGFloat(tankDiameter) / 2, height: CGFloat(tankHeight))
        geometry.firstMaterial?.diffuse.contents = greyColor
        geometry.firstMaterial?.lightingModel = .phong

        tank.geometry = geometry
    }

    private func createShaft() {
        let geometry = SCNCylinder(radius: CGFloat(state.shaftRadius), height: CGFloat(state.tankHeight))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        shaft.geometry = geometry
        shaft.name = "shaft"
        scene.rootNode.addChildNode(shaft)
    }

    private func updateShaft(shaftRadius: Float, tankHeight: Float) {
        let geometry = SCNCylinder(radius: CGFloat(shaftRadius), height: CGFloat(tankHeight))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        shaft.geometry = geometry
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
        hubs.append(node)
        scene.rootNode.addChildNode(node)
    }

    private func updateHub(radius: Float, height: Float, num: Int) {
        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        hubs[num].geometry = geometry
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
        disks.append(node)
        scene.rootNode.addChildNode(node)
    }

    private func updateDisk(radius: Float, height: Float, num: Int) {
        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = metalColor
        geometry.firstMaterial?.lightingModel = .phong

        disks[num].geometry = geometry
    }

    private func changeBladeCount(newValue: Int, oldValue: Int, num: Int) {
        if newValue < oldValue {
            for i in stride(from: oldValue - 1, to: newValue, by: -1) {
                blades[num][i].removeFromParentNode()
                blades[num].remove(at: i)
            }
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

    private func changeBladeGeometry(innerRadius: Float, outerRadius: Float, width: Float, height: Float, num: Int) {
        for i in 0..<blades[num].count {
            let geometry = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(outerRadius - innerRadius),
                chamferRadius: 0
            )
            geometry.firstMaterial?.diffuse.contents = greyColor
            geometry.firstMaterial?.lightingModel = .phong

            blades[num][i].geometry = geometry
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

            let angle1 = (360 * j / blades[num].count + kernelAngle + state.transRotateAngle) % 360
            let radianAngle1 = 2 * Float.pi * Float(angle1) / 360

            let v2 = simd_float4(state.tankDiameter / 4, 0, 0, 1)
            let m2 = float4x4(rotationAbout: yAxis, by: radianAngle1)
            transPanMeshCenter.simdPosition = (m2 * v2).xyz

            transPanMeshCenter.simdEulerAngles = simd_float3(0, radianAngle1, 0)
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

    private func updateTransPan(d: Float, h: Float) {
        updateTranslucentPan(node: transPanMeshXY, width: d * 1.1, height: h * 1.1, depth: 2)
        updateTranslucentPan(node: transPanMeshYZ, width: 2, height: h * 1.1, depth: d * 1.1)
        updateTranslucentPan(node: transPanMeshXZ, width: d * 1.1, height: 2, depth: d * 1.1)
        updateTranslucentPan(node: transPanMeshCenter, width: d / 2, height: h, depth: 2)
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

    private func updateTranslucentPan(node: SCNNode, width: Float, height: Float, depth: Float) {
        guard let geometry = node.geometry as? SCNBox else {
            return
        }
        node.simdScale = simd_float3(
            width / Float(geometry.width),
            height / Float(geometry.height),
            depth / Float(geometry.length)
        )
    }

    private func changeImpellerCount(newValue: Int, oldValue: Int) {
        if newValue < oldValue {
            for i in stride(from: oldValue - 1, to: 0, by: -1) {
                if i < newValue {
                    let posY = getImpellerPositionY(num: i, count: newValue)
                    hubs[i].position.y = posY
                    disks[i].position.y = posY
                } else {
                    hubs[i].removeFromParentNode()
                    hubs.remove(at: i)

                    disks[i].removeFromParentNode()
                    disks.remove(at: i)

                    for j in stride(from: state.bladeCount[i] - 1, to: 0, by: -1) {
                        blades[i][j].removeFromParentNode()
                    }
                    blades.remove(at: i)
                }
            }
        } else if newValue > oldValue {
            for i in 0..<newValue {
                let posY = getImpellerPositionY(num: i, count: newValue)
                if i < oldValue {
                    hubs[i].position.y = posY
                    disks[i].position.y = posY

                    for j in 0..<state.bladeCount[i] {
                        blades[i][j].position.y = posY
                    }
                } else {
                    createHub(num: i, count: newValue)
                    createDisk(num: i, count: newValue)

                    blades.append([])
                    changeBladeCount(newValue: state.bladeCount[i], oldValue: 0, num: i)
                }
            }
        }
    }

    private func changeBaffleCount(newValue: Int, oldValue: Int) {
        if newValue < oldValue {
            for i in stride(from: oldValue - 1, to: newValue, by: -1) {
                baffles[i].removeFromParentNode()
                baffles.remove(at: i)
            }
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

    private func changeTransPan(type: PlaneType, value: Float) {
        switch type {
        case .XY:
            transPanMeshXY.position.z = value
        case .YZ:
            transPanMeshYZ.position.x = value
        case .XZ:
            transPanMeshXZ.position.y = value
        case .Rotate:
            // TODO
            break
        }
    }

    private func changeTransEnable(type: PlaneType, value: Bool) {
        switch type {
        case .XY:
            transPanMeshXY.isHidden = !value
        case .YZ:
            transPanMeshYZ.isHidden = !value
        case .XZ:
            transPanMeshXZ.isHidden = !value
        case .Rotate:
            transPanMeshCenter.isHidden = !value
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

private enum PlaneType {
    case XY, YZ, XZ, Rotate
}
