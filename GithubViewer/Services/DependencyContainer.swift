import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()
    private var dependencies: [String: Any] = [:]
    
    private init() {
        registerDefaultDependencies()
    }
    
    private func registerDefaultDependencies() {
        register(NetworkService() as NetworkServiceProtocol)
        register(AnalyticsService() as AnalyticsServiceProtocol)
        register(CacheService() as CacheServiceProtocol)
        register(Logger.shared as LoggerProtocol)
    }
    
    func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencies[key] as? T else {
            fatalError("No dependency registered for \(key)")
        }
        return dependency
    }
    
    func reset() {
        dependencies.removeAll()
    }
}
