import Foundation

enum NetworkError: Error {
    case invalidURL
    case maxRetriesExceeded
    case networkFailure(Error)
    case decodingFailure(Error)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .maxRetriesExceeded:
            return "Max retries exceeded."
        case .networkFailure(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingFailure(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

extension NetworkError: Identifiable {
    var id: String {
        switch self {
        case .invalidURL: return "invalid_url"
        case .maxRetriesExceeded: return "max_retries_exceeded"
        case .networkFailure: return "network_failure"
        case .decodingFailure: return "decoding_failure"
        case .unknownError: return "unknown_error"
        }
    }
}
