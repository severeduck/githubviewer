import Foundation
import os.log

enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case critical
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }
}

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, category: String, file: String, function: String, line: Int)
    
    // Convenience methods
    func debug(_ message: String, category: String)
    func info(_ message: String, category: String)
    func warning(_ message: String, category: String)
    func error(_ message: String, category: String)
    func critical(_ message: String, category: String)
}

final class Logger: LoggerProtocol {
    static let shared = Logger()
    private let osLog: OSLog
    
    private init() {
        osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.githubviewer", category: "default")
    }
    
    func log(_ message: String, level: LogLevel, category: String, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(category)] \(message) (\(fileName):\(line))"
        
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        
        #if DEBUG
        print("[\(level.rawValue.uppercased())] \(logMessage)")
        #endif
    }
    
    // MARK: - Convenience Methods
    func debug(_ message: String, category: String = "default") {
        log(message, level: .debug, category: category, file: #file, function: #function, line: #line)
    }
    
    func info(_ message: String, category: String = "default") {
        log(message, level: .info, category: category, file: #file, function: #function, line: #line)
    }
    
    func warning(_ message: String, category: String = "default") {
        log(message, level: .warning, category: category, file: #file, function: #function, line: #line)
    }
    
    func error(_ message: String, category: String = "default") {
        log(message, level: .error, category: category, file: #file, function: #function, line: #line)
    }
    
    func critical(_ message: String, category: String = "default") {
        log(message, level: .critical, category: category, file: #file, function: #function, line: #line)
    }
}

// MARK: - Global Convenience Function
func log(_ message: String, 
         level: LogLevel = .info, 
         category: String = "default",
         file: String = #file, 
         function: String = #function, 
         line: Int = #line) {
    Logger.shared.log(message, level: level, category: category, file: file, function: function, line: line)
} 