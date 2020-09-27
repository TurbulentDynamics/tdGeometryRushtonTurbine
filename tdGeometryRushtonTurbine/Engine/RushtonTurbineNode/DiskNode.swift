import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class DiskNode: SCNNode, Bindable {
    let cylinderGeometry = SCNCylinder()
    var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        self.name = "disk"
        
        cylinderGeometry.firstMaterial?.diffuse.contents = Palette.metalColor
        cylinderGeometry.firstMaterial?.lightingModel = .phong
        self.geometry = cylinderGeometry
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
