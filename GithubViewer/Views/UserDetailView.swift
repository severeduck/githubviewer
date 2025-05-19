import SwiftUI

struct UserDetailView: View {
    @ObservedObject var viewModel: UserDetailViewModel
    
    init(viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if let user = viewModel.user {
                    UserHeaderView(user: user)
                    
                    Text("Repositories")
                        .font(.title2)
                        .padding(.top)
                    
                    ForEach(viewModel.repositories) { repo in
                        RepositoryRowView(repository: repo)
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.username)
        .overlay(
            Group {
                if let error = viewModel.error {
                    ErrorView(error: error, retryAction: viewModel.retry)
                        .background(Color(.systemBackground).opacity(0.9))
                        .cornerRadius(20)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        )
    }
}
