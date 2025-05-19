import XCTest
import Combine
@testable import GithubViewer

final class UserListViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: UserListViewModel!
    private var mockNetworkService: MockNetworkService!
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockCacheService: MockCacheService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockAnalyticsService = MockAnalyticsService()
        mockCacheService = MockCacheService()
        cancellables = []
        
        sut = UserListViewModel(
            networkService: mockNetworkService,
            analyticsService: mockAnalyticsService,
            cacheService: mockCacheService,
            appConfiguration: .shared
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockAnalyticsService = nil
        mockCacheService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_init_shouldTrackScreenView() {
        // Then
        XCTAssertEqual(mockAnalyticsService.trackedEvents.count, 2)
        XCTAssertEqual(mockAnalyticsService.trackedEvents[0].name, "screen_view")
        XCTAssertEqual(mockAnalyticsService.trackedEvents[0].parameters?["screen_name"] as? String, "UserListView")
        XCTAssertEqual(mockAnalyticsService.trackedEvents[1].name, "user_list_loaded")
    }
    
    func test_init_shouldStartFetchingUsers() {
        // Then
        XCTAssertTrue(mockNetworkService.fetchUsersCalled)
    }
    
    // MARK: - Fetch Users Tests
    
    func test_fetchUsers_whenSuccessful_shouldUpdateUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Users should be updated")
        let mockUsers = [User(
            id: 1,
            login: "testUser",
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        )]
        mockNetworkService.mockUsers = mockUsers
        
        // When
        sut.$users
            .dropFirst()
            .sink { users in
                // Then
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first?.login, "testUser")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenCacheAvailable_shouldUseCachedData() {
        // Given
        let expectation = XCTestExpectation(description: "Should use cached data")
        let mockUsers = [User(
            id: 1,
            login: "cachedUser",
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        )]
        mockCacheService.mockCachedData = mockUsers
        mockNetworkService.fetchUsersCalled = false
        
        // When
        sut.$users
            .dropFirst()
            .sink { users in
                // Then
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first?.login, "cachedUser")
                XCTAssertFalse(self.mockNetworkService.fetchUsersCalled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenError_shouldUpdateErrorState() {
        // Given
        let expectation = XCTestExpectation(description: "Error should be updated")
        mockNetworkService.mockError = NSError(domain: "test", code: -1)
        
        // When
        sut.$error
            .dropFirst()
            .sink { error in
                // Then
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenError_shouldTrackError() {
        // Given
        let mockError = NSError(domain: "test", code: -1)
        mockNetworkService.mockError = mockError
        
        // When
        sut.fetchUsers()
        
        // Then
        XCTAssertEqual(mockAnalyticsService.trackedErrors.count, 1)
        XCTAssertEqual(mockAnalyticsService.trackedErrors.first as? NSError, mockError)
    }
    
    func test_fetchUsers_whenAlreadyLoading_shouldNotFetchAgain() {
        // Given
        sut.isLoading = true
        mockNetworkService.fetchUsersCalled = false
        
        // When
        sut.fetchUsers()
        
        // Then
        XCTAssertFalse(mockNetworkService.fetchUsersCalled)
    }
    
    // MARK: - Pagination Tests
    
    func test_fetchUsers_shouldIncrementPage() {
        // Given
        let expectation = XCTestExpectation(description: "Page should increment")
        mockNetworkService.mockUsers = [User(
            id: 1,
            login: "testUser",
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        )]
        mockNetworkService.lastPage = 0  // Reset lastPage
        
        // When
        sut.$users
            .dropFirst()
            .sink { _ in
                // Then
                XCTAssertEqual(self.mockNetworkService.lastPage, AppConfiguration.shared.maxUsersPerPage)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenNoMoreUsers_shouldUpdateHasMore() {
        // Given
        let expectation = XCTestExpectation(description: "HasMore should be updated")
        mockNetworkService.mockUsers = []
        
        // When
        sut.$hasMore
            .dropFirst()
            .sink { hasMore in
                // Then
                XCTAssertFalse(hasMore)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenSecondPage_shouldUseCorrectOffset() {
        // Given
        let expectation = XCTestExpectation(description: "Should use correct offset for second page")
        mockNetworkService.mockUsers = [User(
            id: 1,
            login: "testUser",
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        )]
        mockNetworkService.lastPage = 0
        sut.currentPage = 1  // Set to second page
        
        // When
        sut.$users
            .dropFirst()
            .sink { _ in
                // Then
                XCTAssertEqual(self.mockNetworkService.lastPage, AppConfiguration.shared.maxUsersPerPage)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenEmptyResponse_shouldUpdateHasMore() {
        // Given
        let expectation = XCTestExpectation(description: "Should update hasMore when empty response")
        mockNetworkService.mockUsers = []
        mockNetworkService.lastPage = 0
        
        // When
        sut.$hasMore
            .dropFirst()
            .sink { hasMore in
                // Then
                XCTAssertFalse(hasMore)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func test_fetchUsers_whenNetworkError_shouldUpdateErrorState() {
        // Given
        let expectation = XCTestExpectation(description: "Should update error state")
        let mockError = NSError(domain: "test", code: -1)
        mockNetworkService.mockError = mockError
        mockNetworkService.lastPage = 0
        
        // When
        sut.$error
            .dropFirst()
            .sink { error in
                // Then
                XCTAssertNotNil(error)
                if case .networkFailure(let networkError) = error {
                    XCTAssertEqual(networkError as NSError, mockError)
                } else {
                    XCTFail("Expected network failure error")
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUsers_whenError_shouldTrackErrorEvent() {
        // Given
        let mockError = NSError(domain: "test", code: -1)
        mockNetworkService.mockError = mockError
        mockNetworkService.lastPage = 0
        
        // When
        sut.fetchUsers()
        
        // Then
        XCTAssertEqual(mockAnalyticsService.trackedErrors.count, 1)
        XCTAssertEqual(mockAnalyticsService.trackedErrors.first as? NSError, mockError)
        
        let errorEvent = mockAnalyticsService.trackedEvents.first { $0.name == AnalyticsService.EventName.networkError }
        XCTAssertNotNil(errorEvent)
        XCTAssertEqual(errorEvent?.parameters?["error"] as? String, mockError.localizedDescription)
    }
    
    // MARK: - State Management Tests

    func test_retry_whenError_shouldResetStateAndFetchUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Should reset state and fetch users")
        sut.error = NetworkError.networkFailure(NSError(domain: "test", code: -1))
        sut.users = [User(
            id: 1,
            login: "oldUser",
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        )]
        mockNetworkService.lastPage = 0
        
        // When
        sut.$users
            .dropFirst()
            .sink { users in
                // Then
                XCTAssertTrue(users.isEmpty)
                XCTAssertNil(self.sut.error)
                XCTAssertEqual(self.mockNetworkService.lastPage, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.retry()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Services
private class MockNetworkService: NetworkServiceProtocol {
    var mockUsers: [User] = []
    var mockError: Error?
    var fetchUsersCalled = false
    var lastPage: Int = 0
    
    func fetchUsers(since: Int) -> AnyPublisher<[User], Error> {
        fetchUsersCalled = true
        lastPage = since
        
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(mockUsers)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchUserDetails(username: String) -> AnyPublisher<User, Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(User(
            id: 1,
            login: username,
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        ))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func fetchUserRepositories(username: String) -> AnyPublisher<[Repository], Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class MockAnalyticsService: AnalyticsServiceProtocol {
    var trackedEvents: [(name: String, parameters: [String: Any]?)] = []
    var trackedErrors: [Error] = []
    
    func trackScreenView(_ screenName: String) {
        trackedEvents.append((name: "screen_view", parameters: ["screen_name": screenName]))
    }
    
    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append((name: name, parameters: parameters))
    }
    
    func trackError(_ error: Error) {
        trackedErrors.append(error)
    }
}

private class MockCacheService: CacheServiceProtocol {
    var mockCachedData: Any?
    
    func cache<T>(_ data: T, forKey key: String) where T: Encodable {
        // Mock implementation
    }
    
    func retrieve<T>(forKey key: String) -> T? where T: Decodable {
        return mockCachedData as? T
    }
    
    func clear(forKey key: String) {
        mockCachedData = nil
    }
    
    func clearAll() {
        mockCachedData = nil
    }
}
