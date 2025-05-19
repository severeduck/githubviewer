import Foundation
import Combine

protocol CacheServiceProtocol {
    func cache<T: Codable>(_ item: T, forKey key: String)
    func retrieve<T: Codable>(forKey key: String) -> T?
    func clear(forKey key: String)
    func clearAll()
}

class CacheService: CacheServiceProtocol {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func cache<T: Codable>(_ item: T, forKey key: String) {
        do {
            let data = try encoder.encode(item)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Error caching item: \(error)")
        }
    }
    
    func retrieve<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error retrieving cached item: \(error)")
            return nil
        }
    }
    
    func clear(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }
    }
}
