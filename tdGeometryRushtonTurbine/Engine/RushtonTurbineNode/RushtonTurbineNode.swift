import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class RushtonTurbineNode: SCNNode {
    let state: RushtonTurbineRenderState
    let tank: TankNode
    let shaft = ShaftNode()
    let impellers = BindableArray<ImpellerNode>()
    let baffles = BindableArray<BaffleNode>()
    
    init(state: RushtonTurbineRenderState, update: AnyPublisher<Int, Never>) {
        self.state = state
        self.tank = TankNode(state: state, update: update)
        super.init()
        
        tank.bind(\.cylinderGeometry.radius, to: state.turbine.$tankDiameter.map({ CGFloat($0 / 2) }).eraseToAnyPublisher())
        tank.bind(\.cylinderGeometry.height, to: state.turbine.$tankHeight.map({ CGFloat($0) }).eraseToAnyPublisher())
        tank.bind(\.position.y, to: state.turbine.$tankHeight.map({ Float($0 / 2) }).eraseToAnyPublisher())
        self.addChildNode(tank)
        
        shaft.bind(\.cylinderGeometry.radius, to: state.turbine.shaft.$radius.map({ CGFloat($0) }).eraseToAnyPublisher())
        shaft.bind(\.cylinderGeometry.height, to: state.turbine.$tankHeight.map({ CGFloat($0) }).eraseToAnyPublisher())
        shaft.bind(\.position.y, to: state.turbine.$tankHeight.map({ Float($0 / 2) }).eraseToAnyPublisher())
        self.addChildNode(shaft)
        
        impellers.bind(\.impeller, to: state.turbine.$impeller.map { $0.map { $0.value } }.eraseToAnyPublisher(), onInsert: {
            let impellerNode = ImpellerNode(impeller: $0)
            impellerNode.bind(\.simdEulerAngles, to: update.map { simdEulerAngle(angle: $0) }.eraseToAnyPublisher())
            self.addChildNode(impellerNode)
            return impellerNode
        }, onRemove: {
            $0.removeFromParentNode()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func simdEulerAngle(angle: Int) -> simd_float3 {
    let radianAngle = 2 * Float.pi * Float(angle % 360) / 360
    return simd_float3(0, radianAngle, 0)
}

func positionAndEulerAngles(innerRadius: Float, outerRadius: Float, index: Int, count: Int) -> (simd_float3, simd_float3) {
    let distance = (innerRadius + outerRadius) / 2
    let yAxis = simd_float3(0, 1, 0)
    let angle = count == 0 ? 0 : (360 * index / count) % 360
    let radianAngle = 2 * Float.pi * Float(angle) / 360

    let v1 = simd_float4(0, 0, distance, 1)
    let m1 = float4x4(rotationAbout: yAxis, by: radianAngle)
    let simdPosition = (m1 * v1).xyz

    let simdEulerAngles = simd_float3(0, radianAngle, 0)
    
    return (simdPosition, simdEulerAngles)
}
