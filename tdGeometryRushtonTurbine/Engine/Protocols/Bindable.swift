import Foundation
import Combine

protocol Bindable: class {
    var cancellables: Set<AnyCancellable> { get set }
}

extension Bindable {
    func bind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to publisher: AnyPublisher<T, Never>) {
        publisher
            .assign(to: keyPath, on: self)
            .store(in: &cancellables)
    }
}
