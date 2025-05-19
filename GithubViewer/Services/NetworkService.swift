import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchUsers(since page: Int) -> AnyPublisher<[User], Error>
    func fetchUserDetails(username: String) -> AnyPublisher<User, Error>
    func fetchUserRepositories(username: String) -> AnyPublisher<[Repository], Error>
}

protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: URLSessionProtocol {}

class NetworkService: NetworkServiceProtocol {
    private let appConfiguration: AppConfiguration
    private let session: URLSessionProtocol
    private let personalAccessToken: String?
    
    init(
        session: URLSessionProtocol = URLSession.shared, 
        personalAccessToken: String? = nil,
        appConfiguration: AppConfiguration = .shared
    ) {
        self.session = session
        self.personalAccessToken = personalAccessToken
        self.appConfiguration = appConfiguration
    }
    
    func fetchUsers(since: Int = 0) -> AnyPublisher<[User], Error> {
        let urlString = "\(appConfiguration.apiBaseURL.absoluteString)/users?since=\(since)"
        return fetchData(urlString: urlString)
    }
    
    func fetchUserDetails(username: String) -> AnyPublisher<User, Error> {
        let urlString = "\(appConfiguration.apiBaseURL.absoluteString)/users/\(username)"
        return fetchData(urlString: urlString)
    }
    
    func fetchUserRepositories(username: String) -> AnyPublisher<[Repository], Error> {
        let urlString = "\(appConfiguration.apiBaseURL.absoluteString)/users/\(username)/repos?type=owner"
        return fetchData(urlString: urlString)
    }
    
    private func fetchData<T: Decodable>(urlString: String) -> AnyPublisher<T, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = appConfiguration.requestTimeout
        
        if let token = personalAccessToken {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
