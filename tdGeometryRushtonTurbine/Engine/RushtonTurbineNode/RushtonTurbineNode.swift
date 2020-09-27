import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class RushtonTurbineNode: SCNNode {
    let turbine: RushtonTurbine
    let shaft = ShaftNode()
    let impellers = BindableArray<ImpellerNode>()
    
    init(turbine: RushtonTurbine) {
        self.turbine = turbine
        super.init()
        bindShaft()
        bindImpellers()
    }
    
    func bindShaft() {
        shaft.bind(\.cylinderGeometry.radius, to: turbine.shaft.$radius.map({ CGFloat($0) }).eraseToAnyPublisher())
        shaft.bind(\.cylinderGeometry.height, to: turbine.$tankHeight.map({ CGFloat($0) }).eraseToAnyPublisher())
        self.addChildNode(shaft)
    }
    
    func bindImpellers() {
        impellers.bind(\.impeller, to: turbine.$impeller.map { $0.map { $0.value } }.eraseToAnyPublisher(), onInsert: {
            let impellerNode = ImpellerNode(impeller: $0)
            self.addChildNode(impellerNode)
            return impellerNode
        }, onRemove: {
            $0.removeFromParentNode()
        })
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






