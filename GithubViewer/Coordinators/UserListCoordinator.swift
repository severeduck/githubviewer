import SwiftUI

class UserListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = UserListViewModel()
        let view = UserListView(viewModel: viewModel)
            .environment(\.coordinator, self)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "GitHub Users"
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    func showUserDetail(username: String) {
        let coordinator = UserDetailCoordinator(navigationController: navigationController, username: username)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
} 
