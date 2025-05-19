import XCTest
import Combine
@testable import GithubViewer

final class UserDetailViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: UserDetailViewModel!
    private var mockNetworkService: MockNetworkService!
    private var cancellables: Set<AnyCancellable>!
    private let testUsername = "testUser"
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        cancellables = []
        
        sut = UserDetailViewModel(
            username: testUsername,
            networkService: mockNetworkService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_init_shouldStartFetchingUserDetails() {
        // Then
        XCTAssertTrue(mockNetworkService.fetchUserDetailsCalled)
        XCTAssertEqual(mockNetworkService.lastUsername, testUsername)
    }
    
    func test_init_shouldStartFetchingRepositories() {
        // Then
        XCTAssertTrue(mockNetworkService.fetchUserRepositoriesCalled)
        XCTAssertEqual(mockNetworkService.lastUsername, testUsername)
    }
    
    // MARK: - User Details Tests
    
    func test_fetchUserDetails_whenSuccessful_shouldUpdateUser() {
        // Given
        let expectation = XCTestExpectation(description: "User should be updated")
        let mockUser = User(
            id: 1,
            login: testUsername,
            avatarUrl: "testUrl",
            name: "Test Name",
            followers: 100,
            following: 50
        )
        mockNetworkService.mockUser = mockUser
        
        // When
        sut.$user
            .dropFirst()
            .sink { user in
                // Then
                XCTAssertNotNil(user)
                XCTAssertEqual(user?.login, mockUser.login)
                XCTAssertEqual(user?.name, mockUser.name)
                XCTAssertEqual(user?.followers, mockUser.followers)
                XCTAssertEqual(user?.following, mockUser.following)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUserDetails(username: testUsername)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUserDetails_whenError_shouldUpdateErrorState() {
        // Given
        let expectation = XCTestExpectation(description: "Error should be updated")
        let mockError = NSError(domain: "test", code: -1)
        mockNetworkService.mockError = mockError
        
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
        
        sut.fetchUserDetails(username: testUsername)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Repositories Tests
    
    func test_fetchUserRepositories_whenSuccessful_shouldUpdateRepositories() {
        // Given
        let expectation = XCTestExpectation(description: "Repositories should be updated")
        let mockRepositories = [
            Repository(
                id: 1,
                name: "repo1",
                description: "Test repo 1",
                language: "Swift",
                stargazersCount: 100,
                htmlUrl: "https://github.com/test/repo1",
                fork: false
            ),
            Repository(
                id: 2,
                name: "repo2",
                description: "Test repo 2",
                language: "Swift",
                stargazersCount: 200,
                htmlUrl: "https://github.com/test/repo2",
                fork: false
            )
        ]
        mockNetworkService.mockRepositories = mockRepositories
        
        // When
        sut.$repositories
            .dropFirst()
            .sink { repositories in
                // Then
                XCTAssertEqual(repositories.count, 2)
                XCTAssertEqual(repositories[0].name, "repo1")
                XCTAssertEqual(repositories[1].name, "repo2")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUserRepositories(username: testUsername)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUserRepositories_whenError_shouldUpdateErrorState() {
        // Given
        let expectation = XCTestExpectation(description: "Error should be updated")
        let mockError = NSError(domain: "test", code: -1)
        mockNetworkService.mockError = mockError
        
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
        
        sut.fetchUserRepositories(username: testUsername)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchUserRepositories_shouldFilterOutForkedRepositories() {
        // Given
        let expectation = XCTestExpectation(description: "Should filter out forked repositories")
        let mockRepositories = [
            Repository(
                id: 1,
                name: "repo1",
                description: "Test repo 1",
                language: "Swift",
                stargazersCount: 100,
                htmlUrl: "https://github.com/test/repo1",
                fork: false
            ),
            Repository(
                id: 2,
                name: "repo2",
                description: "Test repo 2",
                language: "Swift",
                stargazersCount: 200,
                htmlUrl: "https://github.com/test/repo2",
                fork: true
            )
        ]
        mockNetworkService.mockRepositories = mockRepositories
        
        // When
        sut.$repositories
            .dropFirst()
            .sink { repositories in
                // Then
                XCTAssertEqual(repositories.count, 1)
                XCTAssertEqual(repositories[0].name, "repo1")
                XCTAssertFalse(repositories[0].fork)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchUserRepositories(username: testUsername)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - State Management Tests
    
    func test_retry_whenError_shouldResetStateAndFetchData() {
        // Given
        let expectation = XCTestExpectation(description: "Should reset state and fetch data")
        sut.error = NetworkError.networkFailure(NSError(domain: "test", code: -1))
        mockNetworkService.mockUser = User(
            id: 1,
            login: testUsername,
            avatarUrl: "testUrl",
            name: nil,
            followers: nil,
            following: nil
        )
        mockNetworkService.mockRepositories = []
        
        // When
        sut.$error
            .dropFirst()
            .sink { error in
                // Then
                XCTAssertNil(error)
                XCTAssertTrue(self.mockNetworkService.fetchUserDetailsCalled)
                XCTAssertTrue(self.mockNetworkService.fetchUserRepositoriesCalled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.retry()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Services
private class MockNetworkService: NetworkServiceProtocol {
    var mockUser: User?
    var mockRepositories: [Repository] = []
    var mockError: Error?
    var fetchUserDetailsCalled = false
    var fetchUserRepositoriesCalled = false
    var lastUsername: String?
    
    func fetchUsers(since: Int) -> AnyPublisher<[User], Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchUserDetails(username: String) -> AnyPublisher<User, Error> {
        fetchUserDetailsCalled = true
        lastUsername = username
        
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(mockUser ?? User(
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
        fetchUserRepositoriesCalled = true
        lastUsername = username
        
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(mockRepositories)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 
