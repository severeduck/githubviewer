import XCTest
@testable import GithubViewer

final class AnalyticsServiceTests: XCTestCase {
    // MARK: - Properties
    private var sut: AnalyticsService!
    private var mockLogger: MockLogger!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        sut = AnalyticsService(logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Screen View Tests
    
    func test_trackScreenView_shouldLogScreenView() {
        // Given
        let screenName = "TestScreen"
        
        // When
        sut.trackScreenView(screenName)
        
        // Then
        XCTAssertEqual(mockLogger.loggedMessages.count, 1)
        XCTAssertEqual(mockLogger.loggedMessages.first?.message, "Screen View: \(screenName)")
        XCTAssertEqual(mockLogger.loggedMessages.first?.level, .info)
        XCTAssertEqual(mockLogger.loggedMessages.first?.category, "Analytics")
    }
    
    // MARK: - Event Tracking Tests
    
    func test_trackEvent_withoutParameters_shouldLogEventWithoutParameters() {
        // Given
        let eventName = "test_event"
        
        // When
        sut.trackEvent(name: eventName)
        
        // Then
        XCTAssertEqual(mockLogger.loggedMessages.count, 1)
        XCTAssertEqual(mockLogger.loggedMessages.first?.message, "Event: \(eventName), Parameters: [:]")
        XCTAssertEqual(mockLogger.loggedMessages.first?.level, .info)
        XCTAssertEqual(mockLogger.loggedMessages.first?.category, "Analytics")
    }
    
    // MARK: - Error Tracking Tests
    
    func test_trackError_shouldLogError() {
        // Given
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // When
        sut.trackError(error)
        
        // Then
        XCTAssertEqual(mockLogger.loggedMessages.count, 1)
        XCTAssertEqual(mockLogger.loggedMessages.first?.message, "Tracked Error: \(error.localizedDescription)")
        XCTAssertEqual(mockLogger.loggedMessages.first?.level, .error)
        XCTAssertEqual(mockLogger.loggedMessages.first?.category, "Analytics")
    }
}

// MARK: - Mock Logger
private class MockLogger: LoggerProtocol {
    struct LoggedMessage {
        let message: String
        let level: LogLevel
        let category: String
    }
    
    var loggedMessages: [LoggedMessage] = []
    
    func log(_ message: String, level: LogLevel, category: String, file: String, function: String, line: Int) {
        loggedMessages.append(LoggedMessage(message: message, level: level, category: category))
    }
    
    func debug(_ message: String, category: String) {
        log(message, level: .debug, category: category, file: #file, function: #function, line: #line)
    }
    
    func info(_ message: String, category: String) {
        log(message, level: .info, category: category, file: #file, function: #function, line: #line)
    }
    
    func warning(_ message: String, category: String) {
        log(message, level: .warning, category: category, file: #file, function: #function, line: #line)
    }
    
    func error(_ message: String, category: String) {
        log(message, level: .error, category: category, file: #file, function: #function, line: #line)
    }
    
    func critical(_ message: String, category: String) {
        log(message, level: .critical, category: category, file: #file, function: #function, line: #line)
    }
} 
