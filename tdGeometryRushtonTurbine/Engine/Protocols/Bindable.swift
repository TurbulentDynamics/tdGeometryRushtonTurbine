import Foundation
import Combine
import SceneKit

protocol Bindable: class {
    var cancellables: Set<AnyCancellable> { get set }
}

extension Bindable {
    func bind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to publisher: AnyPublisher<T, Never>) {
        publisher
            .assign(to: keyPath, on: self)
            .store(in: &cancellables)
    }
    
    func bind2<T, U>(_ keyPath1: ReferenceWritableKeyPath<Self, T>, _ keyPath2: ReferenceWritableKeyPath<Self, U>, to publisher: AnyPublisher<(T, U), Never>) {
        publisher
            .sink { (first, second) in
                self[keyPath: keyPath1] = first
                self[keyPath: keyPath2] = second
            }
            .store(in: &cancellables)
    }
}
