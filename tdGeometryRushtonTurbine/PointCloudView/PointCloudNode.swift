import Foundation
import Combine
import SceneKit
import tdLBGeometry

class PointCloudNode: SCNNode {
    let pointCloud: PointCloud
    var pointGeometrySource: SCNGeometrySource
    let pointGeometry: SCNGeometry
    
    
    init(pointCloud: PointCloud) {
        self.pointCloud = pointCloud
        pointGeometrySource = SCNGeometrySource(vertices: pointCloud.vertices.map { $0.scnVector3 })
        
        let pointCloudElement = SCNGeometryElement(indices: Array(0..<pointCloud.vertices.count), primitiveType: .point)
        pointCloudElement.pointSize = 3
        pointCloudElement.minimumPointScreenSpaceRadius = 1
        pointCloudElement.maximumPointScreenSpaceRadius = 6
        
        pointGeometry = SCNGeometry(sources: [pointGeometrySource], elements: [pointCloudElement])
        
        super.init()
        self.name = "pointCloud"
        self.geometry = pointGeometry

        self.simdPosition = simd_float3(x: -298/2, y: 0, z: -298/2)
    }
    
    func updatePoints() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PointCloudVertex {
    var scnVector3: SCNVector3 {
        .init(self.i, self.j, self.k)
    }
}
