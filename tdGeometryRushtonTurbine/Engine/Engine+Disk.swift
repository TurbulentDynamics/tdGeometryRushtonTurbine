import Foundation
import SceneKit
import tdLBGeometryRushtonTurbineLib

extension Engine {
    func createDisk(impeller: Impeller, num: Int, count: Int) {
        let radius = impeller.disk.radius
        let height = impeller.disk.height

        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = Palette.metalColor
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "disk\(num)"
        node.position = SCNVector3(0, getImpellerPositionY(num: num, count: count), 0)
        disks.append(node)
        scene.rootNode.addChildNode(node)
    }

    func updateDisk(radius: Float, height: Float, num: Int) {
        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = Palette.metalColor
        geometry.firstMaterial?.lightingModel = .phong

        disks[num].geometry = geometry
    }
}
