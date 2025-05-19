import Foundation

enum MockData {
    static let mockUser = User(
        id: 1,
        login: "octocat",
        avatarUrl: "https://avatars.githubusercontent.com/u/583231?v=4",
        name: "The Octocat",
        followers: 4000,
        following: 9
    )
    
    static let mockRepository = Repository(
        id: 1296269,
        name: "Hello-World",
        description: "This is your first repo!",
        language: "Swift",
        stargazersCount: 1000,
        htmlUrl: "https://github.com/octocat/Hello-World",
        fork: false
    )
}
