import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class ShaftNode: SCNNode, Bindable {
    let cylinderGeometry = SCNCylinder()
    var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        self.name = "shaft"
        
        cylinderGeometry.firstMaterial?.diffuse.contents = Palette.metalColor
        cylinderGeometry.firstMaterial?.lightingModel = .phong
        self.geometry = cylinderGeometry
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
