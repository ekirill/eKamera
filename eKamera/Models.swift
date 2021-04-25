import Foundation

struct Camera: Codable, Identifiable {
    let id: String
    let caption: String
    let thumbnailUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case caption = "caption"
        case thumbnailUrl = "thumb"
    }
}

struct ApiResponse<T: Codable & Identifiable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
