import SwiftUI

class RepositoryWebCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let repositoryUrl: URL
    
    init(navigationController: UINavigationController, repositoryUrl: URL) {
        self.navigationController = navigationController
        self.repositoryUrl = repositoryUrl
    }
    
    func start() {
        let view = RepositoryWebView(url: repositoryUrl)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Repository"
        navigationController.pushViewController(hostingController, animated: true)
    }
} 