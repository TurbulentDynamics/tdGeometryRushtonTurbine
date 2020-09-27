import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class ImpellerNode: SCNNode, Bindable {
    var cancellables = Set<AnyCancellable>()
    let impeller: Impeller
    
    let hub = DiskNode()
    let disk = DiskNode()
    
    let blades = BindableArray<SCNNode>()
    
    init(impeller: Impeller) {
        self.impeller = impeller
        super.init()
        
        bind(\.position.y, to: impeller.$impellerPosition.map { Float($0) }.eraseToAnyPublisher())
        
        // Hub
        bind(\.hub.cylinderGeometry.radius, to: impeller.hub.$radius.map { CGFloat($0) }.eraseToAnyPublisher())
        bind(\.hub.cylinderGeometry.height, to: Publishers.Zip(impeller.hub.$bottom, impeller.hub.$top).map { $0.0 - $0.1 }.map { CGFloat($0) }.eraseToAnyPublisher())
        self.addChildNode(hub)
        
        // Disk
        bind(\.disk.cylinderGeometry.radius, to: impeller.disk.$radius.map { CGFloat($0) }.eraseToAnyPublisher())
        bind(\.disk.cylinderGeometry.height, to: Publishers.Zip(impeller.disk.$bottom, impeller.disk.$top).map { $0.0 - $0.1 }.map { CGFloat($0) }.eraseToAnyPublisher())
        self.addChildNode(disk)
        
        /// Blades
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
