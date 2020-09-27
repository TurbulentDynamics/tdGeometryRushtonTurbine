import Foundation
import SceneKit

extension Engine {
    func changeBaffleCount(newValue: Int, oldValue: Int) {
        if newValue < oldValue {
            for i in stride(from: oldValue - 1, through: newValue, by: -1) {
                baffles[i].removeFromParentNode()
                baffles.remove(at: i)
            }
        } else if newValue > oldValue {
            for _ in oldValue..<newValue {
                let geometry = SCNBox(
                    width: CGFloat(state.turbine.baffles.thickness),
                    height: CGFloat(state.turbine.tankHeight),
                    length: CGFloat(state.turbine.baffles.outerRadius - state.turbine.baffles.innerRadius),
                    chamferRadius: 0
                )
                geometry.firstMaterial?.diffuse.contents = Palette.greyColor
                geometry.firstMaterial?.lightingModel = .phong

                let node = SCNNode(geometry: geometry)
                node.name = "baffle"
                baffles.append(node)
                scene.rootNode.addChildNode(node)
            }
        }
    }
    
    func updateBaffles(baffleInnerRadius: Int, baffleOuterRadius: Int) {
        let distance = Float(baffleInnerRadius + baffleOuterRadius) / 2
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
