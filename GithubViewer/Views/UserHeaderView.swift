import SwiftUI

struct UserHeaderView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name ?? user.login)
                    .font(.title)
                Text("@\(user.login)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Followers: \(user.followers ?? 0)")
                    Text("Following: \(user.following ?? 0)")
                }
                .font(.caption)
            }
        }
    }
}

#Preview {
    UserHeaderView(user: MockData.mockUser)
}
