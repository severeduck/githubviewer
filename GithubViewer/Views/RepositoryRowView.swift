import SwiftUI

struct RepositoryRowView: View {
    let repository: Repository
    @Environment(\.coordinator) private var coordinator
    
    var body: some View {
        Button(action: {
            if let url = URL(string: repository.htmlUrl),
               let detailCoordinator = coordinator as? UserDetailCoordinator {
                detailCoordinator.showRepository(url: url)
            }
        }) {
            VStack(alignment: .leading, spacing: 5) {
                Text(repository.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = repository.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if let language = repository.language {
                        Text(language)
                            .font(.caption)
                            .padding(4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    
                    Text("★ \(repository.stargazersCount)")
                        .font(.caption)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    RepositoryRowView(repository: MockData.mockRepository)
}
