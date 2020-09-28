import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class BaffleNode: SCNNode, Bindable {
    let index: Int
    let boxGeometry = SCNBox()
    var cancellables = Set<AnyCancellable>()
    
    init(index: Int) {
        self.index = index
        
        super.init()
        self.name = "baffle\(index)"
        
        boxGeometry.firstMaterial?.diffuse.contents = Palette.metalColor
        boxGeometry.firstMaterial?.lightingModel = .phong
        self.geometry = boxGeometry
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
