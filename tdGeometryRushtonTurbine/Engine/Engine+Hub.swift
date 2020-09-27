import Foundation
import SceneKit
import tdLBGeometryRushtonTurbineLib

extension Engine {
    func createHub(impeller: Impeller, num: Int, count: Int) {
        let radius = impeller.hub.radius
        let height = impeller.hub.height

        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = Palette.metalColor
        geometry.firstMaterial?.lightingModel = .phong

        let node = SCNNode(geometry: geometry)
        node.name = "hub\(num)"
        node.position = SCNVector3(0, getImpellerPositionY(num: num, count: count), 0)
        hubs.append(node)
        scene.rootNode.addChildNode(node)
    }

    func updateHub(radius: Float, height: Float, num: Int) {
        let geometry = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        geometry.firstMaterial?.diffuse.contents = Palette.metalColor
        geometry.firstMaterial?.lightingModel = .phong

        hubs[num].geometry = geometry
    }
}
