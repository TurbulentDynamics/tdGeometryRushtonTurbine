import Foundation
import Combine

class BindableArray<Element: Equatable> {
    var nodes: [Element]
    var cancellables = Set<AnyCancellable>()
    
    init() {
        nodes = []
    }
    
    func bind<U: Equatable>(_ keypath: KeyPath<Element, U>, to publisher: AnyPublisher<[U], Never>, onInsert: @escaping (U) -> Element, onRemove: @escaping (Element) -> ()) {
        publisher.sink { elements in
            elements
                .difference(from: self.nodes.map { $0[keyPath: keypath] })
                .forEach {
                    switch $0 {
                    case .insert(let offset, let element, _):
                        self.nodes.insert(onInsert(element), at: offset)
                        print("Insert", offset, element)
                    case .remove(let offset, let element, _):
                        print("Remove", offset, element)
                        onRemove(self.nodes[offset])
                        self.nodes.remove(at: offset)
                    }
                }
        }
        .store(in: &cancellables)
    }
}
