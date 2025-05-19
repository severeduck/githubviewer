import Foundation
import Combine

class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var hasMore = true
    
    private let networkService: NetworkServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let logger: LoggerProtocol
    private var cancellables = Set<AnyCancellable>()
    var currentPage = 0
    private let appConfiguration: AppConfiguration

    init(
        networkService: NetworkServiceProtocol = DependencyContainer.shared.resolve(),
        analyticsService: AnalyticsServiceProtocol = DependencyContainer.shared.resolve(),
        cacheService: CacheServiceProtocol = DependencyContainer.shared.resolve(),
        logger: LoggerProtocol = Logger.shared,
        appConfiguration: AppConfiguration = .shared
    ) {
        self.networkService = networkService
        self.analyticsService = analyticsService
        self.cacheService = cacheService
        self.logger = logger
        self.appConfiguration = appConfiguration

        // Track screen view
        analyticsService.trackScreenView("UserListView")
        logger.info("UserListViewModel initialized", category: "UserList")
        
        fetchUsers()
    }
    
    func fetchUsers() {
        guard !isLoading else { return }
        isLoading = true
        logger.debug("Fetching users for page \(currentPage)", category: "UserList")
        
        // Check cache first
        if let cachedUsers: [User] = cacheService.retrieve(forKey: "users_page_\(currentPage)") {
            self.users.append(contentsOf: cachedUsers)
            self.currentPage += 1
            self.isLoading = false
            
            logger.info("Loaded \(cachedUsers.count) users from cache", category: "UserList")
            
            // Track cached data event
            analyticsService.trackEvent(
                name: "cached_users_loaded",
                parameters: ["page": currentPage, "user_count": cachedUsers.count]
            )
            return
        }
        
        RetryPolicy.retry(
            networkService.fetchUsers(since: currentPage * appConfiguration.maxUsersPerPage),
            maxRetries: 3
        )
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = NetworkError.networkFailure(error)
                
                self?.logger.error("Failed to fetch users: \(error.localizedDescription)", category: "UserList")
                
                // Track network error
                self?.analyticsService.trackError(error)
                self?.analyticsService.trackEvent(
                    name: AnalyticsService.EventName.networkError,
                    parameters: ["error": error.localizedDescription, "page": self?.currentPage ?? 0]
                )
            }
        } receiveValue: { [weak self] users in
            guard let self = self else { return }
            
            self.users.append(contentsOf: users)
            self.currentPage += 1
            self.hasMore = users.count >= self.appConfiguration.maxUsersPerPage
            
            // Cache the results
            self.cacheService.cache(users, forKey: "users_page_\(self.currentPage - 1)")
            
            self.logger.info("Loaded \(users.count) users", category: "UserList")
            
            // Track successful load event
            self.analyticsService.trackEvent(
                name: AnalyticsService.EventName.userListLoaded,
                parameters: ["page": self.currentPage - 1, "user_count": users.count]
            )
        }
        .store(in: &cancellables)
    }
    
    func retry() {
        error = nil
        currentPage = 0
        users = []
        fetchUsers()
    }
}
