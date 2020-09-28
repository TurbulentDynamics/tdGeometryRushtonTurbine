import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class TransPanNode: SCNNode, Bindable {
    let boxGeometry = SCNBox()
    var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        name = "transPan"
        opacity = 0.8
        isHidden = false
        
        boxGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        boxGeometry.firstMaterial?.lightingModel = .phong
        geometry = boxGeometry
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
