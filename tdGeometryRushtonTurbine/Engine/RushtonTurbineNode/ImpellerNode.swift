import Foundation
import Combine
import SceneKit
import tdLBGeometryRushtonTurbineLib

class ImpellerNode: SCNNode, Bindable {
    var cancellables = Set<AnyCancellable>()
    let impeller: Impeller
    
    let hub = DiskNode()
    let disk = DiskNode()
    
    let blades = BindableArray<BladeNode>()
    
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
        blades.bind(\.index,
            to: impeller.$numBlades.map { Array(0..<$0) }.eraseToAnyPublisher(),
            onInsert: { index in
                let bladeNode = BladeNode(index: index)
                bladeNode.bind(\.boxGeometry.width, to: impeller.blades.$thickness.map { CGFloat($0) }.eraseToAnyPublisher())
                
                bladeNode.bind(\.boxGeometry.height, to:
                    Publishers
                        .Zip(impeller.blades.$bottom, impeller.blades.$top)
                        .map { $0.0 - $0.1 }
                        .map { CGFloat($0) }
                        .eraseToAnyPublisher())
                
                bladeNode.bind(\.boxGeometry.length, to: Publishers.Zip(impeller.blades.$outerRadius, impeller.blades.$innerRadius).map { $0.0 - $0.1 }.map { CGFloat($0) }.eraseToAnyPublisher())
                
                bladeNode.bind2(\.simdPosition, \.simdEulerAngles, to:
                    Publishers
                        .CombineLatest4(
                            impeller.blades.$innerRadius.map { Float($0) },
                            impeller.blades.$outerRadius.map { Float($0) },
                            Just(index),
                            impeller.$numBlades
                        )
                        .map { positionAndEulerAngles(innerRadius: $0.0, outerRadius: $0.1, index: $0.2, count: $0.3) }
                        .eraseToAnyPublisher()
                )
                
                self.addChildNode(bladeNode)
                return bladeNode
                
            },
            onRemove: { $0.removeFromParentNode() }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
