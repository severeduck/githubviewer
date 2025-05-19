import Foundation
import Combine

struct RetryPolicy {
    static func retry<P: Publisher>(
        _ publisher: P,
        maxRetries: Int = 3,
        backoffStrategy: @escaping (Int) -> TimeInterval = exponentialBackoff
    ) -> AnyPublisher<P.Output, P.Failure> where P.Failure == Error {
        return publisher
            .catch { error -> AnyPublisher<P.Output, P.Failure> in
                guard let networkError = error as? NetworkError,
                      shouldRetry(networkError) else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                return retryWithBackoff(
                    publisher: publisher,
                    currentAttempt: 1,
                    maxRetries: maxRetries,
                    backoffStrategy: backoffStrategy
                )
            }
            .eraseToAnyPublisher()
    }
    
    private static func shouldRetry(_ error: NetworkError) -> Bool {
        switch error {
        case .networkFailure, .invalidURL:
            return true
        default:
            return false
        }
    }
    
    private static func retryWithBackoff<P: Publisher>(
        publisher: P,
        currentAttempt: Int,
        maxRetries: Int,
        backoffStrategy: @escaping (Int) -> TimeInterval
    ) -> AnyPublisher<P.Output, P.Failure> where P.Failure == Error {
        guard currentAttempt <= maxRetries else {
            return Fail(error: NetworkError.maxRetriesExceeded).eraseToAnyPublisher()
        }
        
        let delay = backoffStrategy(currentAttempt - 1)
        log("Retrying network call. Attempt: \(currentAttempt), Delay: \(delay)s", level: .warning)
        
        return publisher
            .catch { error -> AnyPublisher<P.Output, P.Failure> in
                guard let networkError = error as? NetworkError,
                      shouldRetry(networkError) else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                return Just(())
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                    .flatMap { _ in
                        retryWithBackoff(
                            publisher: publisher,
                            currentAttempt: currentAttempt + 1,
                            maxRetries: maxRetries,
                            backoffStrategy: backoffStrategy
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // Exponential backoff with jitter
    static func exponentialBackoff(_ attempt: Int) -> TimeInterval {
        let baseDelay: TimeInterval = 1.0
        let maxDelay: TimeInterval = 30.0
        
        // Calculate exponential backoff with full jitter
        let calculatedDelay = min(
            maxDelay,
            baseDelay * pow(2.0, Double(attempt)) * (1.0 + Double.random(in: 0...1))
        )
        
        return calculatedDelay
    }
}
