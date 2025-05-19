import SwiftUI

struct UserListView: View {
    @ObservedObject var viewModel: UserListViewModel
    @Environment(\.coordinator) private var coordinator
    
    var body: some View {
        List {
            ForEach(viewModel.users) { user in
                Button(action: {
                    if let listCoordinator = coordinator as? UserListCoordinator {
                        listCoordinator.showUserDetail(username: user.login)
                    }
                }) {
                    UserRowView(user: user)
                }
                .accessibilityIdentifier("userCell_\(user.login)")
            }
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityIdentifier("loadingIndicator")
            } else if viewModel.hasMore {
                Button(action: viewModel.fetchUsers) {
                    Text("Load More")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityIdentifier("loadMoreButton")
            }
        }
        .accessibilityIdentifier("userList")
        .navigationTitle("GitHub Users")
        .overlay(
            Group {
                if let error = viewModel.error {
                    ErrorView(error: error, retryAction: viewModel.retry)
                        .background(Color(.systemBackground).opacity(0.9))
                        .cornerRadius(20)
                        .transition(.opacity)
                        .zIndex(1)
                        .accessibilityIdentifier("errorView")
                }
            }
        )
    }
}


