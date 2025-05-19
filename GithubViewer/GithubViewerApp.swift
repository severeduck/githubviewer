import SwiftUI
import SwiftData

@main
struct GithubViewerApp: App {
    @StateObject private var appCoordinator = AppCoordinator(navigationController: UINavigationController())
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: appCoordinator)
        }
    }
}

struct CoordinatorView: UIViewControllerRepresentable {
    let coordinator: AppCoordinator
    
    func makeUIViewController(context: Context) -> UINavigationController {
        coordinator.start()
        return coordinator.navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
