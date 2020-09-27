import Foundation
import SceneKit
import tdLBGeometryRushtonTurbineLib

extension Engine {
    func changeBladeCount(impeller: Impeller, num: Int, newValue: Int, oldValue: Int) {
        if newValue < oldValue {
            for i in stride(from: oldValue - 1, through: newValue, by: -1) {
                blades[num][i].removeFromParentNode()
                blades[num].remove(at: i)
            }
        } else if newValue > oldValue {
            for _ in oldValue..<newValue {
                let geometry = SCNBox(
                    width: CGFloat(impeller.blades.thickness),
                    height: CGFloat(impeller.blades.height),
                    length: CGFloat(impeller.blades.outerRadius - impeller.blades.innerRadius),
                    chamferRadius: 0
                )
                geometry.firstMaterial?.diffuse.contents = Palette.greyColor
                geometry.firstMaterial?.lightingModel = .phong

                let node = SCNNode(geometry: geometry)
                node.name = "blade\(num)"
                blades[num].append(node)
                scene.rootNode.addChildNode(node)
            }
        }
    }

    func changeBladeGeometry(innerRadius: Float, outerRadius: Float, width: Float, height: Float, num: Int) {
        for i in 0..<blades[num].count {
            let geometry = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(outerRadius - innerRadius),
                chamferRadius: 0
            )
            geometry.firstMaterial?.diffuse.contents = Palette.greyColor
            geometry.firstMaterial?.lightingModel = .phong

            blades[num][i].geometry = geometry
        }
    }

    func updateBlades(innerRadius: Float, outerRadius: Float, num: Int) {
        let distance = (innerRadius + outerRadius) / 2
        let yAxis = simd_float3(0, 1, 0)

        let count = state.turbine.impeller.count
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

            let v2 = simd_float4(Float(state.turbine.tankDiameter) / 4, 0, 0, 1)
            let m2 = float4x4(rotationAbout: yAxis, by: radianAngle1)
            transPanMeshCenter.simdPosition = (m2 * v2).xyz

            transPanMeshCenter.simdEulerAngles = simd_float3(0, radianAngle1, 0)
        }
    }
}
