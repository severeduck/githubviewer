import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    let name: String?
    let followers: Int?
    let following: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case name
        case followers
        case following
    }
}
