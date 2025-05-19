import XCTest
import SwiftUI
@testable import GithubViewer

final class AppCoordinatorTests: XCTestCase {
    // MARK: - Properties
    private var sut: AppCoordinator!
    private var mockNavigationController: MockNavigationController!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNavigationController = MockNavigationController()
        sut = AppCoordinator(navigationController: mockNavigationController)
    }
    
    override func tearDown() {
        sut = nil
        mockNavigationController = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_init_shouldSetNavigationController() {
        // Then
        XCTAssertEqual(sut.navigationController, mockNavigationController)
    }
    
    func test_init_shouldInitializeEmptyChildCoordinators() {
        // Then
        XCTAssertTrue(sut.childCoordinators.isEmpty)
    }
    
    func test_start_shouldAddUserListCoordinatorAsChild() {
        // When
        sut.start()
        
        // Then
        XCTAssertEqual(sut.childCoordinators.count, 1)
        let userListCoordinator = sut.childCoordinators.first as? UserListCoordinator
        XCTAssertNotNil(userListCoordinator)
        XCTAssertEqual(userListCoordinator?.navigationController, mockNavigationController)
    }
    
    // MARK: - Child Coordinator Management Tests
    
    func test_addChildCoordinator_shouldAddToChildCoordinators() {
        // Given
        let childCoordinator = UserListCoordinator(navigationController: mockNavigationController)
        
        // When
        sut.addChildCoordinator(childCoordinator)
        
        // Then
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.first === childCoordinator)
    }
    
    func test_removeChildCoordinator_shouldRemoveFromChildCoordinators() {
        // Given
        let childCoordinator = UserListCoordinator(navigationController: mockNavigationController)
        sut.addChildCoordinator(childCoordinator)
        
        // When
        sut.removeChildCoordinator(childCoordinator)
        
        // Then
        XCTAssertTrue(sut.childCoordinators.isEmpty)
    }
}

// MARK: - Mock Navigation Controller
private class MockNavigationController: UINavigationController {
    var pushedViewControllers: [UIViewController] = []
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - Mock Analytics Service
private class MockAnalyticsService: AnalyticsServiceProtocol {
    var trackedScreenViews: [String] = []
    var trackedEvents: [(name: String, parameters: [String: Any]?)] = []
    var trackedErrors: [Error] = []
    
    func trackScreenView(_ screenName: String) {
        trackedScreenViews.append(screenName)
    }
    
    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append((name: name, parameters: parameters))
    }
    
    func trackError(_ error: Error) {
        trackedErrors.append(error)
    }
} 
