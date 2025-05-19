import SwiftUI

struct UserRowView: View {
    let user: User
    @State private var loadingFailed = false
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.avatarUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure(_):
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .animation(.default, value: loadingFailed)
            
            Text(user.login)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    UserRowView(user: MockData.mockUser)
}
