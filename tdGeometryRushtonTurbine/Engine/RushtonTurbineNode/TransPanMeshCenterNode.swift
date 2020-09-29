import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class TransPanMeshCenterNode: SCNNode, Bindable {
    var meshXY = TransPanNode()
    var meshYZ = TransPanNode()
    var meshXZ = TransPanNode()
    var cancellables = Set<AnyCancellable>()
    let state: RushtonTurbineRenderState
    
    init(state: RushtonTurbineRenderState) {
        self.state = state
        super.init()
        self.name = "transPanCenterMesh"
        
        meshXY.bind(\.boxGeometry.width, to: self.state.turbine.$tankDiameter.map { CGFloat($0) * 1.1 }.eraseToAnyPublisher())
        meshXY.bind(\.boxGeometry.height, to: self.state.turbine.$tankHeight.map { CGFloat($0) * 1.1 }.eraseToAnyPublisher())
        meshXY.bind(\.boxGeometry.length, to: Just(2).eraseToAnyPublisher())
        meshXY.bind(\.isHidden, to: self.state.$transEnableXY.map { !$0 }.eraseToAnyPublisher())
        addChildNode(meshXY)
        
        meshYZ.bind(\.boxGeometry.width, to: Just(2).eraseToAnyPublisher())
        meshYZ.bind(\.boxGeometry.height, to: self.state.turbine.$tankHeight.map { CGFloat($0) * 1.1 }.eraseToAnyPublisher())
        meshYZ.bind(\.boxGeometry.length, to: self.state.turbine.$tankDiameter.map { CGFloat($0) * 1.1 }.eraseToAnyPublisher())
        meshYZ.bind(\.isHidden, to: self.state.$transEnableYZ.map { !$0 }.eraseToAnyPublisher())
        addChildNode(meshYZ)
        
        meshXZ.bind(\.boxGeometry.width, to: self.state.turbine.$tankDiameter.map { CGFloat($0) * 1.1 }.eraseToAnyPublisher())
        meshXZ.bind(\.boxGeometry.height, to: Just(2).eraseToAnyPublisher())
        meshXZ.bind(\.boxGeometry.length, to: self.state.turbine.$tankDiameter.map { CGFloat($0) * 1.1 }.eraseToAnyPublisher())
        meshXZ.bind(\.isHidden, to: self.state.$transEnableXZ.map { !$0 }.eraseToAnyPublisher())
        addChildNode(meshXZ)
        
        //self.bind(\.simdEulerAngles, to: update.map { simdEulerAngle(angle: $0) }.eraseToAnyPublisher())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
