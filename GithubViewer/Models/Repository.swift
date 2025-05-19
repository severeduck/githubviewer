import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let htmlUrl: String
    let fork: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case language
        case stargazersCount = "stargazers_count"
        case htmlUrl = "html_url"
        case fork
    }
}
