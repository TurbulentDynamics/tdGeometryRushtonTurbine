import Foundation
import SceneKit

extension Engine {
    func createTank() {
        let geometry = SCNCylinder(radius: CGFloat(state.turbine.tankDiameter) / 2, height: CGFloat(state.turbine.tankHeight))
        geometry.firstMaterial?.diffuse.contents = Palette.greyColor
        geometry.firstMaterial?.lightingModel = .phong

        tank.geometry = geometry
        tank.name = "tank"
        tank.opacity = 0.3
        tank.renderingOrder = 1 // IMPORTANT need this to have correct transparency
        scene.rootNode.addChildNode(tank)
    }

    func updateTank(tankDiameter: Int, tankHeight: Int) {
        let geometry = SCNCylinder(radius: CGFloat(tankDiameter) / 2, height: CGFloat(tankHeight))
        geometry.firstMaterial?.diffuse.contents = Palette.greyColor
        geometry.firstMaterial?.lightingModel = .phong

        tank.geometry = geometry
    }
}
