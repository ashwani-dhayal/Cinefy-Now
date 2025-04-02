

import UIKit
import CoreML

// MARK: - Movie Recommendation Manager
class MovieRecommendationManager {
    
    // Singleton instance
    static let shared = MovieRecommendationManager()
    
    // CoreML model
    private var model: MovieRecommender?
    
    // Dictionary to store movie ID to title mapping
    private var movieMapping: [Int: String] = [:]
    
    // Load model and movie mapping from bundle
    private init() {
        // Load CoreML model
        do {
            model = try MovieRecommender()
            print("CoreML model loaded successfully")
        } catch {
            print("Error loading CoreML model: \(error)")
        }
        
        // Load movie mapping
        if let path = Bundle.main.path(forResource: "movie_mapping", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let mapping = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            // Convert string keys to int
            for (key, value) in mapping {
                if let movieId = Int(key) {
                    movieMapping[movieId] = value
                }
            }
            print("Movie mapping loaded successfully")
        }
    }
    
    // Get movie recommendations based on user preferences
    func getRecommendations(
           artistIds: [Int],
           genreIds: [Int],
           releaseYear: Int,
           popularity: Double,
           voteAverage: Double,
           voteCount: Int
    ) -> [MovieRecommendation] {
        guard let model = model else {
            print("CoreML model not loaded")
            return []
        }
        
        // Prepare features dictionary
        var features: [String: Double] = [:]
        
        // Initialize all features to zero
        features["genre_9648"] = 0.0
        features["genre_10770"] = 0.0
        features["genre_10749"] = 0.0
        features["genre_18"] = 0.0
        features["genre_14"] = 0.0
        features["genre_10402"] = 0.0
        features["genre_12"] = 0.0
        features["genre_28"] = 0.0
        features["genre_80"] = 0.0
        features["genre_10752"] = 0.0
        features["genre_878"] = 0.0
        features["genre_35"] = 0.0
        features["genre_99"] = 0.0
        features["genre_53"] = 0.0
        features["genre_10751"] = 0.0
        features["genre_16"] = 0.0
        features["genre_27"] = 0.0
        features["genre_36"] = 0.0
        features["genre_37"] = 0.0
        features["release_year"] = 0.0
        features["popularity"] = 0.0
        features["vote_average"] = 0.0
        features["vote_count"] = 0.0
        
        // Update genre features
        for genreId in genreIds {
            let genreKey = "genre_\(genreId)"
            if features.keys.contains(genreKey) {
                features[genreKey] = 1.0
            }
        }
        
        // Set numeric features
        features["release_year"] = Double(releaseYear)
        features["popularity"] = popularity
        features["vote_average"] = voteAverage
        features["vote_count"] = Double(voteCount)
        
        do {
            // Create specific input using the generated MovieRecommenderInput class
            let modelInput = try MovieRecommenderInput(
                genre_9648: features["genre_9648"] ?? 0.0,
                genre_10770: features["genre_10770"] ?? 0.0,
                genre_10749: features["genre_10749"] ?? 0.0,
                genre_18: features["genre_18"] ?? 0.0,
                genre_14: features["genre_14"] ?? 0.0,
                genre_10402: features["genre_10402"] ?? 0.0,
                genre_12: features["genre_12"] ?? 0.0,
                genre_28: features["genre_28"] ?? 0.0,
                genre_80: features["genre_80"] ?? 0.0,
                genre_10752: features["genre_10752"] ?? 0.0,
                genre_878: features["genre_878"] ?? 0.0,
                genre_35: features["genre_35"] ?? 0.0,
                genre_99: features["genre_99"] ?? 0.0,
                genre_53: features["genre_53"] ?? 0.0,
                genre_10751: features["genre_10751"] ?? 0.0,
                genre_16: features["genre_16"] ?? 0.0,
                genre_27: features["genre_27"] ?? 0.0,
                genre_36: features["genre_36"] ?? 0.0,
                genre_37: features["genre_37"] ?? 0.0,
                release_year: features["release_year"] ?? 0.0,
                popularity: features["popularity"] ?? 0.0,
                vote_average: features["vote_average"] ?? 0.0,
                vote_count: features["vote_count"] ?? 0.0
            )
            
            // Get prediction
            let output = try model.prediction(input: modelInput)
            
            // Get the predicted movie ID (assuming the output property is named "movieId")
            let movieId = output.movie_id
            let intMovieId = Int(movieId)
            let title = movieMapping[intMovieId] ?? "Unknown Movie"
            
            return [
                MovieRecommendation(id: intMovieId, title: title, score: 0.95)
            ]
        }
       catch {
            print("Prediction error: \(error)")
        }
        
        return []
    }

    
    // Simplified recommendation method with just genre and artist IDs
    func getSimpleRecommendations(artistIds: [Int], genreIds: [Int]) -> [MovieRecommendation] {
        // Using average values for other parameters
        return getRecommendations(
            artistIds: artistIds,
            genreIds: genreIds,
            releaseYear: 2023,
            popularity: 50.0,
            voteAverage: 7.0,
            voteCount: 1000
        )
    }
    
    // Get movie title by ID
    func getMovieTitle(for movieId: Int) -> String {
        return movieMapping[movieId] ?? "Unknown Movie"
    }
}

// MARK: - Movie Recommendation Model
struct MovieRecommendation {
    let id: Int
    let title: String
    let score: Double
}

// MARK: - Movie Selection History Manager
class MovieSelectionManager {
    
    static let shared = MovieSelectionManager()
    
    // Save selected artist IDs
    func saveSelectedArtists(_ artistIds: [Int]) {
        UserDefaults.standard.set(artistIds, forKey: "SelectedArtistIds")
    }
    
    // Save selected genre IDs
    func saveSelectedGenres(_ genreIds: [Int]) {
        UserDefaults.standard.set(genreIds, forKey: "SelectedGenreIds")
    }
    
    // Get selected artist IDs
    func getSelectedArtists() -> [Int] {
        return UserDefaults.standard.array(forKey: "SelectedArtistIds") as? [Int] ?? []
    }
    
    // Get selected genre IDs
    func getSelectedGenres() -> [Int] {
        return UserDefaults.standard.array(forKey: "SelectedGenreIds") as? [Int] ?? []
    }
}
