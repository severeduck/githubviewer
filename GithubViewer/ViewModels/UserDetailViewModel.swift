import Foundation
import Combine

class UserDetailViewModel: ObservableObject {
    @Published var user: User?
    @Published var repositories: [Repository] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    
    let username: String
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        username: String,
        networkService: NetworkServiceProtocol = DependencyContainer.shared.resolve()
    ) {
        self.username = username
        self.networkService = networkService
        
        fetchUserDetails(username: username)
        fetchUserRepositories(username: username)
    }
    
    func fetchUserDetails(username: String) {
        isLoading = true
        
        RetryPolicy.retry(
            networkService.fetchUserDetails(username: username),
            maxRetries: 3
        )
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = NetworkError.networkFailure(error)
            }
        } receiveValue: { [weak self] user in
            self?.user = user
        }
        .store(in: &cancellables)
    }
    
    func fetchUserRepositories(username: String) {
        isLoading = true
        
        RetryPolicy.retry(
            networkService.fetchUserRepositories(username: username),
            maxRetries: 3
        )
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = NetworkError.networkFailure(error)
            }
        } receiveValue: { [weak self] repositories in
            self?.repositories = repositories.filter { !$0.fork }
        }
        .store(in: &cancellables)
    }
    
    func retry() {
        error = nil
        fetchUserDetails(username: username)
        fetchUserRepositories(username: username)
    }
}
