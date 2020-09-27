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

    let grid = SCNNode()
    let tank = SCNNode()
    let shaft = SCNNode()

    var disks = [SCNNode]()
    var hubs = [SCNNode]()
    var blades = [[SCNNode]]()
    var baffles = [SCNNode]()
    var kernelAngle: Int = 0

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
    
    let turbineNode: RushtonTurbineNode
    
    init(state: RushtonTurbineRenderState) {
        self.state = state
        self.scene = SCNScene()
        self.turbineNode = RushtonTurbineNode(turbine: state.turbine)
        super.init()
        
        scene.rootNode.addChildNode(turbineNode)
        
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 10000

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.simdPosition = simd_float3(0, Float(state.turbine.tankHeight) * 2, Float(state.turbine.tankDiameter) * 3)
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

        //createTank()
        //createShaft()
//
//        state.turbine.impeller.enumerated().forEach { (index, impeller) in
//            blades.append([])
//            createHub(impeller: impeller.value, num: index, count: state.turbine.impeller.count)
//            createDisk(impeller: impeller.value, num: index, count: state.turbine.impeller.count)
//            changeBladeCount(impeller: impeller.value, num: index, newValue: impeller.value.numBlades, oldValue: 0)
//        }
//
//        changeBaffleCount(newValue: state.turbine.baffles.numBaffles, oldValue: 0)
//        updateBaffles(baffleInnerRadius: state.turbine.baffles.innerRadius, baffleOuterRadius: state.turbine.baffles.outerRadius)

        createPlane()
        createTransPan(d: Float(state.turbine.tankDiameter), h: Float(state.turbine.tankHeight))
//        
//        /// React to tank updates
//        tankPublisher
//            .sink { [weak self] (diameter, height) in
//                self?.updateTank(tankDiameter: diameter, tankHeight: height)
//                //self?.changeImpellerCount(newValue: value, oldValue: self!.state.turbine.numImpellers)
//                //self?.updateState(newState: value)
//            }
//            .store(in: &cancellables)
//        
//        /// React to shaft updates
//        Publishers
//            .CombineLatest(state.turbine.shaft.$radius.removeDuplicates(), state.turbine.$tankHeight.removeDuplicates())
//            .sink { [weak self] (radius, height) in
//                self?.updateShaft(shaftRadius: radius, tankHeight: height)
//            }
//            .store(in: &cancellables)
//        
//        /// React to buffles updates
//        Publishers
//            .CombineLatest(state.turbine.baffles.$innerRadius.removeDuplicates(), state.turbine.baffles.$outerRadius.removeDuplicates())
//            .sink { [weak self] (innerRadius, outerRadius) in
//                self?.updateBaffles(baffleInnerRadius: innerRadius, baffleOuterRadius: outerRadius)
//            }
//            .store(in: &cancellables)
//        
//        state.turbine.baffles.$numBaffles
//            .removeDuplicates()
//            .sink { [weak self] count in
//                self?.changeBaffleCount(newValue: count, oldValue: self!.state.turbine.baffles.numBaffles)
//            }
//            .store(in: &cancellables)
        
    }



//    private func updateState(newState: TurbineState) {
//        SCNTransaction.lock()
//
//        let oldState = state
//
//        state = newState
//        controlModel = ControlModel(state: newState, stateSubject: stateSubject)
//
//        if newState.impellerCount != oldState.impellerCount {
//            changeImpellerCount(newValue: newState.impellerCount, oldValue: oldState.impellerCount)
//        } else {
//            for i in 0..<oldState.impellerCount {
//                if newState.bladeCount[i] != oldState.bladeCount[i] {
//                    changeBladeCount(
//                        newValue: newState.bladeCount[i],
//                        oldValue: oldState.bladeCount[i],
//                        num: i
//                    )
//                }
//
//                if newState.bladeInnerRadius[i] != oldState.bladeInnerRadius[i] ||
//                    newState.bladeOuterRadius[i] != oldState.bladeOuterRadius[i] ||
//                    newState.bladeWidth[i] != oldState.bladeWidth[i] ||
//                    newState.bladeHeight[i] != oldState.bladeHeight[i] {
//                    changeBladeGeometry(
//                        innerRadius: newState.bladeInnerRadius[i],
//                        outerRadius: newState.bladeOuterRadius[i],
//                        width: newState.bladeWidth[i],
//                        height: newState.bladeHeight[i],
//                        num: i
//                    )
//                }
//
//                if newState.hubRadius[i] != oldState.hubRadius[i] || newState.hubHeight[i] != oldState.hubHeight[i] {
//                    updateHub(radius: newState.hubRadius[i], height: newState.hubHeight[i], num: i)
//                }
//
//                if newState.diskRadius[i] != oldState.diskRadius[i] || newState.diskHeight[i] != oldState.diskHeight[i] {
//                    updateDisk(radius: newState.diskRadius[i], height: newState.diskHeight[i], num: i)
//                }
//            }
//        }
//
//        if newState.baffleCount != oldState.baffleCount {
//            changeBaffleCount(newValue: newState.baffleCount, oldValue: oldState.baffleCount)
//        }
//
//        if newState.transPanXY != oldState.transPanXY {
//            changeTransPan(type: .XY, value: Float(newState.transPanXY))
//        } else if newState.transPanYZ != oldState.transPanYZ {
//            changeTransPan(type: .YZ, value: Float(newState.transPanYZ))
//        } else if newState.transPanXZ != oldState.transPanXZ {
//            changeTransPan(type: .XZ, value: Float(newState.transPanXZ))
//        } else if newState.transRotateAngle != oldState.transRotateAngle {
//            changeTransPan(type: .Rotate, value: Float(newState.transRotateAngle))
//        }
//
//        if newState.transEnableXY != oldState.transEnableXY {
//            changeTransEnable(type: .XY, value: newState.transEnableXY)
//        } else if newState.transEnableYZ != oldState.transEnableYZ {
//            changeTransEnable(type: .YZ, value: newState.transEnableYZ)
//        } else if newState.transEnableXZ != oldState.transEnableXZ {
//            changeTransEnable(type: .XZ, value: newState.transEnableXZ)
//        } else if newState.transEnableRotate != oldState.transEnableRotate {
//            changeTransEnable(type: .Rotate, value: newState.transEnableRotate)
//        }
//
//        if newState != oldState {
//            updatePlane(tankHeight: newState.tankHeight)
//            updateTank(tankDiameter: newState.tankDiameter, tankHeight: newState.tankHeight)
//            updateShaft(shaftRadius: newState.shaftRadius, tankHeight: newState.tankHeight)
//
//            updateTransPan(d: newState.tankDiameter, h: newState.tankHeight)
//
//            updateBaffles(baffleInnerRadius: newState.baffleInnerRadius, baffleOuterRadius: newState.baffleOuterRadius)
//        }
//        SCNTransaction.unlock()
//    }

    private func update() {
//        switch state.kernelRotationDir {
//        case "clockwise":
//            kernelAngle = (kernelAngle + 1) % 360
//            state.turbine.impeller.enumerated().forEach { (index, impeller) in
//                updateBlades(innerRadius: Float(impeller.value.blades.innerRadius), outerRadius: Float(impeller.value.blades.outerRadius), num: index)
//            }
//        case "counter-clockwise":
//            kernelAngle = (kernelAngle - 1) % 360
//            state.turbine.impeller.enumerated().forEach { (index, impeller) in
//                updateBlades(innerRadius: Float(impeller.value.blades.innerRadius), outerRadius: Float(impeller.value.blades.outerRadius), num: index)
//            }
//        default:
//            break
//        }
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





    func getImpellerPositionY(num: Int, count: Int) -> Float {
        let tankHeight = Float(state.turbine.tankHeight)
        return tankHeight / -2 + tankHeight / Float(count + 1) * Float(num + 1)
    }



//    private func changeImpellerCount(newValue: Int, oldValue: Int) {
//        if newValue < oldValue {
//            for i in stride(from: oldValue - 1, through: 0, by: -1) {
//                if i < newValue {
//                    let posY = getImpellerPositionY(num: i, count: newValue)
//                    hubs[i].position.y = posY
//                    disks[i].position.y = posY
//                } else {
//                    hubs[i].removeFromParentNode()
//                    hubs.remove(at: i)
//
//                    disks[i].removeFromParentNode()
//                    disks.remove(at: i)
//
//                    for j in stride(from: blades[i].count - 1, through: 0, by: -1) {
//                        blades[i][j].removeFromParentNode()
//                    }
//                    blades.remove(at: i)
//                }
//            }
//        } else if newValue > oldValue {
//            for i in 0..<newValue {
//                let posY = getImpellerPositionY(num: i, count: newValue)
//                if i < oldValue {
//                    hubs[i].position.y = posY
//                    disks[i].position.y = posY
//
//                    for j in 0..<state.bladeCount[i] {
//                        blades[i][j].position.y = posY
//                    }
//                } else {
//                    createHub(num: i, count: newValue)
//                    createDisk(num: i, count: newValue)
//
//                    blades.append([])
//                    changeBladeCount(newValue: state.bladeCount[i], oldValue: 0, num: i)
//                }
//            }
//        }
//    }
}

extension Engine: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        update()
    }
}
