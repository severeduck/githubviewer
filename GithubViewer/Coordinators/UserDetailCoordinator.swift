import SwiftUI

class UserDetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let username: String
    
    init(navigationController: UINavigationController, username: String) {
        self.navigationController = navigationController
        self.username = username
    }
    
    func start() {
        let viewModel = UserDetailViewModel(username: username)
        let view = UserDetailView(viewModel: viewModel)
            .environment(\.coordinator, self)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = username
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func showRepository(url: URL) {
        let coordinator = RepositoryWebCoordinator(navigationController: navigationController, repositoryUrl: url)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
} 