import Foundation
import SceneKit
import tdLBGeometryRushtonTurbineLib

extension Engine {
    func createTransPan(d: Float, h: Float) {
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

    func updateTransPan(d: Float, h: Float) {
        updateTranslucentPan(node: transPanMeshXY, width: d * 1.1, height: h * 1.1, depth: 2)
        updateTranslucentPan(node: transPanMeshYZ, width: 2, height: h * 1.1, depth: d * 1.1)
        updateTranslucentPan(node: transPanMeshXZ, width: d * 1.1, height: 2, depth: d * 1.1)
        updateTranslucentPan(node: transPanMeshCenter, width: d / 2, height: h, depth: 2)
    }

    func createTranslucentPan(width: Float, height: Float, length: Float) -> SCNNode {
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

    func updateTranslucentPan(node: SCNNode, width: Float, height: Float, depth: Float) {
        guard let geometry = node.geometry as? SCNBox else {
            return
        }
        node.simdScale = simd_float3(
            width / Float(geometry.width),
            height / Float(geometry.height),
            depth / Float(geometry.length)
        )
    }
    
    func changeTransPan(type: PlaneType, value: Float) {
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

    func changeTransEnable(type: PlaneType, value: Bool) {
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
}

enum PlaneType {
    case XY, YZ, XZ, Rotate
}
