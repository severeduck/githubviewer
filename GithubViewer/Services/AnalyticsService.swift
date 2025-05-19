import Foundation

protocol AnalyticsServiceProtocol {
    func trackScreenView(_ screenName: String)
    func trackEvent(name: String, parameters: [String: Any]?)
    func trackError(_ error: Error)
}

class AnalyticsService: AnalyticsServiceProtocol {
    // In a real-world scenario, this would integrate with services like Firebase, 
    // Mixpanel, or a custom analytics backend
    
    private let logger: LoggerProtocol
    
    init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }
    
    func trackScreenView(_ screenName: String) {
        logger.info("Screen View: \(screenName)", category: "Analytics")
        // In production, send to analytics service
    }
    
    func trackEvent(name: String, parameters: [String: Any]? = nil) {
        logger.info("Event: \(name), Parameters: \(parameters ?? [:])", category: "Analytics")
        // In production, send to analytics service
    }
    
    func trackError(_ error: Error) {
        logger.error("Tracked Error: \(error.localizedDescription)", category: "Analytics")
        // In production, send to crash reporting service
    }
}

// Extension to track common app events
extension AnalyticsService {
    enum EventName {
        static let userListLoaded = "user_list_loaded"
        static let userDetailViewed = "user_detail_viewed"
        static let repositoryViewed = "repository_viewed"
        static let networkError = "network_error"
    }
}
