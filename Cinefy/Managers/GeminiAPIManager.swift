
import Foundation

class GeminiAPIManager {
    static let shared = GeminiAPIManager()
    
    private let apiKey = "AIzaSyAkSqkhs7RhtM-0bBP71oeC5MVZ87ybYxA" // 🔴 Replace this with your Gemini API Key
    
    // Using the basic text model endpoint which should be available to all API keys
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key="
    
    func fetchMoviesInSameUniverse(movieTitle: String, completion: @escaping ([String]?) -> Void) {
        let prompt = """
        For the movie "\(movieTitle)", please:
        1. Identify which cinematic universe it belongs to
        2. List ALL movies in that same cinematic universe in STRICT CHRONOLOGICAL ORDER according to the in-universe timeline (not release date)
        3. Format your response ONLY as a comma-separated list of movie titles in chronological order
        4. If multiple timeline orders exist (like parallel universes), follow the main canonical timeline
        5. Do not include any explanations, just the comma-separated list
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["role": "user", "parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.1,  // Lower temperature for more deterministic results
                "maxOutputTokens": 2048  // Increased token limit for larger universes
            ]
        ]
        
        guard let url = URL(string: endpoint + apiKey) else {
            print("❌ Invalid API URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            // Debug the request body
            if let requestBodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request Body: \(requestBodyString)")
            }
        } catch {
            print("❌ Failed to encode request body:", error.localizedDescription)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❌ API returned non-200 status code: \(httpResponse.statusCode)")
                }
            }

            guard let data = data, !data.isEmpty else {
                print("❌ No data received")
                completion(nil)
                return
            }
            
            print("📦 Data received: \(data.count) bytes")

            do {
                // Debug: Print full JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 API Response: \(jsonString)")
                }

                // First try to parse error response to get meaningful error messages
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    if let errorDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorInfo = errorDict["error"] as? [String: Any],
                       let errorMessage = errorInfo["message"] as? String {
                        print("❌ API Error: \(errorMessage)")
                        completion(nil)
                        return
                    }
                }

                // Parse JSON more cautiously with JSONSerialization first
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let text = firstPart["text"] as? String {
                    
                    let movieList = text.components(separatedBy: ",").map {
                        $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    }.filter { !$0.isEmpty }
                    
                    print("🎬 Movies in chronological order: \(movieList)")
                    completion(movieList)
                } else {
                    print("❌ Could not extract text from response")
                    completion(nil)
                }
            } catch {
                print("❌ JSON Parsing error:", error.localizedDescription)
                completion(nil)
            }
        }

        task.resume()
    }
    
    // Function to list available models to help diagnose API issues
    func listAvailableModels(completion: @escaping ([String]?) -> Void) {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(apiKey)") else {
            print("❌ Invalid API URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error listing models:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ No data received when listing models")
                completion(nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let models = jsonResponse["models"] as? [[String: Any]] {
                    
                    let modelNames = models.compactMap { $0["name"] as? String }
                    print("📋 Available models: \(modelNames)")
                    completion(modelNames)
                } else {
                    print("❌ Invalid response format for models list")
                    completion(nil)
                }
            } catch {
                print("❌ Error parsing models response:", error.localizedDescription)
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // New function to get detailed information about movies in a universe
    func fetchDetailedUniverseInfo(movieTitle: String, completion: @escaping (UniverseInfo?) -> Void) {
        let prompt = """
        For the movie "\(movieTitle)":
        1. Identify which cinematic universe it belongs to
        2. Provide the following JSON structure:
        {
          "universeName": "Name of the cinematic universe",
          "totalMovies": number of movies in the universe,
          "movies": [
            {
              "title": "Movie title",
              "releaseYear": year of release,
              "chronologicalOrder": position in the timeline,
              "description": "Brief 1-sentence description"
            },
            ... (all movies in chronological order by in-universe timeline)
          ]
        }
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["role": "user", "parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "maxOutputTokens": 4096
            ]
        ]
        
        guard let url = URL(string: endpoint + apiKey) else {
            print("❌ Invalid API URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to encode request body:", error.localizedDescription)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let text = firstPart["text"] as? String {
                    
                    // Extract JSON object from the text
                    if let jsonStartIndex = text.firstIndex(of: "{"),
                       let jsonEndIndex = text.lastIndex(of: "}") {
                        let jsonSubstring = text[jsonStartIndex...jsonEndIndex]
                        let jsonData = Data(jsonSubstring.utf8)
                        
                        let decoder = JSONDecoder()
                        let universeInfo = try decoder.decode(UniverseInfo.self, from: jsonData)
                        completion(universeInfo)
                    } else {
                        print("❌ Could not find JSON in response")
                        completion(nil)
                    }
                } else {
                    print("❌ Could not extract text from response")
                    completion(nil)
                }
            } catch {
                print("❌ JSON Parsing error:", error.localizedDescription)
                completion(nil)
            }
        }

        task.resume()
    }
}

// MARK: - Data Models
struct UniverseInfo: Codable {
    let universeName: String
    let totalMovies: Int
    let movies: [MovieInfo]
}

struct MovieInfo: Codable {
    let title: String
    let releaseYear: Int
    let chronologicalOrder: Int
    let description: String
}
