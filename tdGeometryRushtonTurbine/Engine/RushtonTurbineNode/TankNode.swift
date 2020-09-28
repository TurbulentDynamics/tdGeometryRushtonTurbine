import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class TankNode: SCNNode, Bindable {
    let cylinderGeometry = SCNCylinder()
    var cancellables = Set<AnyCancellable>()
    let baffles = BindableArray<BaffleNode>()
    let transPan: TransPanMeshCenterNode
    let state: RushtonTurbineRenderState
    
    init(state: RushtonTurbineRenderState, update: AnyPublisher<Int, Never>) {
        self.state = state
        self.transPan = TransPanMeshCenterNode(state: state, update: update)
        super.init()
        name = "tank"
        
        renderingOrder = 1
        
        cylinderGeometry.firstMaterial?.diffuse.contents = Palette.metalColor
        cylinderGeometry.firstMaterial?.lightingModel = .phong
        cylinderGeometry.firstMaterial?.transparency = 0.3
        self.geometry = cylinderGeometry
        
        baffles.bind(\.index,
            to: state.turbine.baffles.$numBaffles.map { Array(0..<$0) }.eraseToAnyPublisher(),
            onInsert: { index in
                let buffleNode = BaffleNode(index: index)
                buffleNode.bind(\.boxGeometry.width, to: self.state.turbine.baffles.$thickness.map { CGFloat($0) }.eraseToAnyPublisher())
                buffleNode.bind(\.boxGeometry.height, to: self.state.turbine.$tankHeight.map({ CGFloat($0) }).eraseToAnyPublisher())
                buffleNode.bind(\.boxGeometry.length, to: Publishers.Zip(self.state.turbine.baffles.$outerRadius, self.state.turbine.baffles.$innerRadius).map { $0.0 - $0.1 }.map { CGFloat($0) }.eraseToAnyPublisher())
                
                
                buffleNode.bind2(\.simdPosition, \.simdEulerAngles, to:
                    Publishers
                        .CombineLatest4(
                            self.state.turbine.baffles.$innerRadius.map { Float($0) },
                            self.state.turbine.baffles.$outerRadius.map { Float($0) },
                            Just(index),
                            self.state.turbine.baffles.$numBaffles
                        )
                        .map { positionAndEulerAngles(innerRadius: $0.0, outerRadius: $0.1, index: $0.2, count: $0.3) }
                        .eraseToAnyPublisher()
                )
                
                self.addChildNode(buffleNode)
                return buffleNode
                
            },
            onRemove: { $0.removeFromParentNode() }
        )
        
        addChildNode(transPan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
