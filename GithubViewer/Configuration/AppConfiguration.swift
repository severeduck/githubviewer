import Foundation

struct AppConfiguration {
    enum Environment {
        case development
        case staging
        case production
    }
    
    static let shared = AppConfiguration()
    
    let environment: Environment
    let apiBaseURL: URL
    let requestTimeout: TimeInterval
    let maxUsersPerPage: Int
    
    private init() {
        #if DEBUG
        self.environment = .development
        self.apiBaseURL = URL(string: "https://api.github.com")!
        self.requestTimeout = 30.0
        self.maxUsersPerPage = 30
        #elseif STAGING
        self.environment = .staging
        self.apiBaseURL = URL(string: "https://api.github.com")!
        self.requestTimeout = 20.0
        self.maxUsersPerPage = 25
        #else
        self.environment = .production
        self.apiBaseURL = URL(string: "https://api.github.com")!
        self.requestTimeout = 15.0
        self.maxUsersPerPage = 20
        #endif
    }
    
    var isDebug: Bool {
        return environment == .development
    }
}
