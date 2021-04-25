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

struct Event: Codable, Identifiable {
    let id: String
    let startTime: String
    let endTime: String
    let duration: Int
    let videoUrl: String
    let thumbnailUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case startTime = "start_time"
        case endTime = "end_time"
        case duration = "duration"
        case videoUrl = "video"
        case thumbnailUrl = "thumb"
    }
}

struct ApiResponse<T: Codable & Identifiable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
