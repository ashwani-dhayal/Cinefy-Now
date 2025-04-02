import Foundation

struct TrendingTitleResponse: Codable {
    let results: [Title]
}

struct TitleResponse: Codable {
    let results: [Title]
}



struct TitleViewModel {
    let titleName: String
    let posterURL: String
    let releaseYear: String
    let overview: String
    let movieType: String
}

struct Title: Codable {
    let id: Int
    let media_type: String? 
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int
    let release_date: String?
    let first_air_date: String?
    let vote_average: Double
    let popularity: Double?
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement Equatable (required by Hashable)
    static func == (lhs: Title, rhs: Title) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Genre {
    let id: Int
    let name: String
    let image: String
}



struct TitlePreviewViewModel {
    let title: String
   
    let youtubeView: VideoElement
    let titleOverview: String
}


//MOvie DIscussion
struct Discussion {
    var id: String?
    var username: String
    var comment: String
    var replies: [Reply]
}

struct FanTheory {
    var id: String?
    var username: String
    var theory: String
    var comments: [Reply]
}

struct Reply {
    let id: String
    let username: String
    let comment: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString, username: String, comment: String, timestamp: Date = Date()) {
        self.id = id
        self.username = username
        self.comment = comment
        self.timestamp = timestamp
    }
}

struct ArtistMovieCredits: Codable {
    let cast: [Title]
    let crew: [Title]  // If you also want crew credits
    let id: Int       // The person/artist ID
}

//DIFF GENRE
struct GenreResponse: Codable {
    let genres: [TMDBGenre]
}

struct TMDBGenre: Codable {
    let id: Int
    let name: String
}

//YOUTUBE
struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}


struct VideoElement: Codable {
    let id: IdVideoElement
}


struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}

