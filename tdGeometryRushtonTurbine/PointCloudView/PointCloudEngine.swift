import Foundation
import SceneKit
import tdLBGeometry

class PointCloudEngine: NSObject, ObservableObject {
    let pointCloud: PointCloud
    let scene: SCNScene
    let grid = SCNNode()
    let pointCloudNode: PointCloudNode
    
    init(pointCloud: PointCloud) {
        self.pointCloud = pointCloud
        self.pointCloudNode = PointCloudNode(pointCloud: pointCloud)
        self.scene = SCNScene()
        
        super.init()
        
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 10000

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.simdPosition = simd_float3(0, 500, 500)
        cameraNode.simdRotation = simd_float4(1, 0, 0, -30 * Float.pi / 180)
        scene.rootNode.addChildNode(cameraNode)
        
        createPlane()
        
        scene.rootNode.addChildNode(pointCloudNode)
    }
    
    
    func createPlane() {
        grid.geometry = createGrid(size: 1000, divisions: 50, color1: 0x444444, color2: 0x888888)
        grid.position.y = 0
        scene.rootNode.addChildNode(grid)
    }
    
    func update() {
    }
}


extension PointCloudEngine: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.update()
    }
}
