import Foundation

extension Engine {
    func createPlane() {
        grid.geometry = createGrid(size: 1000, divisions: 50, color1: 0x444444, color2: 0x888888)
        grid.position.y = -(Float(state.turbine.tankHeight) / 2)
        scene.rootNode.addChildNode(grid)
    }

    func updatePlane(tankHeight: Float) {
        grid.position.y = -(tankHeight / 2);
    }
}
