//
//import UIKit
//import Foundation
//import Firebase
//import FirebaseFirestore
//import FirebaseAuth
//import FirebaseStorage
//
//
//struct UserProfile {
//    let fullName: String
//    let email: String
//    let role: String
//    let profileImageURL: String?
//    
//    init(data: [String: Any]) {
//        self.fullName = data["Full Name"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.role = data["role"] as? String ?? "Movie Enthusiast"
//        self.profileImageURL = data["profileImageURL"] as? String
//    }
//}
//
//class WatchlistManager {
//    static let shared = WatchlistManager()
//    
//    private var watchlist: [Title] = []
//    private let db = Firestore.firestore()
//    private var documentIDs: [Int: String] = [:]
//    
//    private init() {}
//    
//    func addMovieToWatchlist(movie: Title) {
//        if !watchlist.contains(where: { $0.id == movie.id }) {
//            watchlist.append(movie)
//            saveMovieToFirestore(movie: movie)
//        }
//    }
//    
//    func getWatchlist() -> [Title] {
//        return watchlist
//    }
//    
//    func removeMovie(movie: Title) {
//        if let index = watchlist.firstIndex(where: { $0.id == movie.id }) {
//            watchlist.remove(at: index)
//            removeMovieFromFirestore(movie: movie)
//        }
//    }
//    
//    func setWatchlist(movies: [Title]) {
//        watchlist = movies
//    }
//    
//    private func saveMovieToFirestore(movie: Title) {
//        print("Saving movie to Firestore: \(movie.original_title ?? movie.original_name ?? "Unknown")")
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        // Check if this movie already exists in Firestore
//        db.collection("watchlist")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("movieID", isEqualTo: movie.id)
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error checking movie: \(error.localizedDescription)")
//                    return
//                }
//                
//                // If no documents found, then add the movie
//                if let documents = snapshot?.documents, documents.isEmpty {
//                    let movieData: [String: Any] = [
//                        "userEmail": userEmail,
//                        "movieID": movie.id,
//                        "title": movie.original_title ?? movie.original_name ?? "Unknown",
//                        "posterPath": movie.poster_path ?? "",
//                        "mediaType": movie.media_type ?? "movie",
//                        "addedDate": Date()
//                    ]
//                    
//                    self?.db.collection("watchlist").addDocument(data: movieData) { error in
//                        if let error = error {
//                            print("Error saving movie to Firestore: \(error.localizedDescription)")
//                        } else {
//                            print("Movie saved successfully to watchlist")
//                        }
//                    }
//                } else {
//                    print("Movie already exists in watchlist Firestore, skipping save")
//                }
//            }
//    }
//    
//    func removeMovieFromFirestore(movie: Title) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        db.collection("watchlist")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("movieID", isEqualTo: movie.id)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching watchlist movie: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No watchlist movie found")
//                    return
//                }
//                
//                for document in documents {
//                    document.reference.delete()
//                }
//            }
//    }
//    
//    var listener: ListenerRegistration?
//    
//    func fetchWatchlistFromFirestore(completion: @escaping ([Title]) -> Void) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            completion([])
//            return
//        }
//        
//        // Remove existing listener before adding a new one
//        listener?.remove()
//        
//        // Clear existing data before fetching
//        self.watchlist.removeAll()
//        self.documentIDs.removeAll()
//        
//        listener = db.collection("watchlist")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .addSnapshotListener { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error fetching watchlist: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No watchlist movies found")
//                    completion([])
//                    return
//                }
//                
//                var fetchedMovies: [Title] = []
//                var processedMovieIDs = Set<Int>()
//                
//                for document in documents {
//                    let data = document.data()
//                    
//                    if let id = data["movieID"] as? Int,
//                       let title = data["title"] as? String {
//                        // Skip if we've already processed this movie ID
//                        if processedMovieIDs.contains(id) {
//                            continue
//                        }
//                        
//                        processedMovieIDs.insert(id)
//                        let posterPath = data["posterPath"] as? String
//                        let mediaType = data["mediaType"] as? String ?? "movie"
//                        
//                        let movie = Title(
//                            id: id,
//                            media_type: mediaType,
//                            original_name: mediaType == "tv" ? title : nil,
//                            original_title: mediaType == "movie" ? title : nil,
//                            poster_path: posterPath,
//                            overview: nil,
//                            vote_count: 0,
//                            release_date: nil,
//                            first_air_date: nil,  // Add this parameter
//                            vote_average: 0.0,
//                            popularity: 0.0
//                            
//                        )
//                        
//                        fetchedMovies.append(movie)
//                        
//                        // Store document ID for later use
//                        self?.documentIDs[id] = document.documentID
//                    }
//                }
//                
//                self?.watchlist = fetchedMovies
//                completion(fetchedMovies)
//            }
//    }
//    
//    func cleanupListener() {
//        listener?.remove()
//        listener = nil
//    }
//}
//
//class FavoritesManager {
//    static let shared = FavoritesManager()
//    
//    private var favorites: [Title] = []
//    private let db = Firestore.firestore()
//    private var documentIDs: [Int: String] = [:] // Store document IDs for each title
//    
//    private init() {}
//    
//    func addMovieToFavorites(movie: Title) {
//        if !favorites.contains(where: { $0.id == movie.id }) {
//            favorites.append(movie)
//            saveMovieToFirestore(movie: movie)
//        }
//    }
//    
//    func getFavorites() -> [Title] {
//        return favorites
//    }
//    
//    func removeMovie(movie: Title) {
//        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
//            favorites.remove(at: index)
//            removeMovieFromFirestore(movie: movie)
//        }
//    }
//    
//    func setFavorites(movies: [Title]) {
//        favorites = movies
//    }
//    
//    private func saveMovieToFirestore(movie: Title) {
//        print("Saving movie to Firestore favorites: \(movie.original_title ?? movie.original_name ?? "Unknown")")
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        // Check if this movie already exists in Firestore
//        db.collection("favorites")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("movieID", isEqualTo: movie.id)
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error checking favorite movie: \(error.localizedDescription)")
//                    return
//                }
//                
//                // If no documents found, then add the movie
//                if let documents = snapshot?.documents, documents.isEmpty {
//                    let movieData: [String: Any] = [
//                        "userEmail": userEmail,
//                        "movieID": movie.id,
//                        "title": movie.original_title ?? movie.original_name ?? "Unknown",
//                        "posterPath": movie.poster_path ?? "",
//                        "mediaType": movie.media_type ?? "movie",
//                        "addedDate": Date()
//                    ]
//                    
//                    self?.db.collection("favorites").addDocument(data: movieData) { error in
//                        if let error = error {
//                            print("Error saving movie to Firestore favorites: \(error.localizedDescription)")
//                        } else {
//                            print("Movie saved successfully to favorites")
//                        }
//                    }
//                } else {
//                    print("Movie already exists in favorites Firestore, skipping save")
//                }
//            }
//    }
//    
//    func removeMovieFromFirestore(movie: Title) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        db.collection("favorites")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("movieID", isEqualTo: movie.id)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching favorite movie: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No favorite movie found")
//                    return
//                }
//                
//                for document in documents {
//                    document.reference.delete()
//                }
//            }
//    }
//    
//    var listener: ListenerRegistration?
//    
//    func fetchFavoritesFromFirestore(completion: @escaping ([Title]) -> Void) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            completion([])
//            return
//        }
//        
//        // Remove existing listener before adding a new one
//        listener?.remove()
//        
//        // Clear existing data before fetching
//        self.favorites.removeAll()
//        self.documentIDs.removeAll()
//        
//        listener = db.collection("favorites")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .addSnapshotListener { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error fetching favorites: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No favorite movies found")
//                    completion([])
//                    return
//                }
//                
//                var fetchedMovies: [Title] = []
//                var processedMovieIDs = Set<Int>()
//                
//                for document in documents {
//                    let data = document.data()
//                    
//                    if let id = data["movieID"] as? Int,
//                       let title = data["title"] as? String {
//                        // Skip if we've already processed this movie ID
//                        if processedMovieIDs.contains(id) {
//                            continue
//                        }
//                        
//                        processedMovieIDs.insert(id)
//                        let posterPath = data["posterPath"] as? String
//                        let mediaType = data["mediaType"] as? String ?? "movie"
//                        
//                        let movie = Title(
//                            id: id,
//                            media_type: mediaType,
//                            original_name: mediaType == "tv" ? title : nil,
//                            original_title: mediaType == "movie" ? title : nil,
//                            poster_path: posterPath,
//                            overview: nil,
//                            vote_count: 0,
//                            release_date: nil,
//                            first_air_date: nil,  // Add this parameter
//                            vote_average: 0.0,
//                            popularity: 0.0
//                        )
//                        
//                        fetchedMovies.append(movie)
//                        
//                        // Store document ID for later use
//                        self?.documentIDs[id] = document.documentID
//                    }
//                }
//                
//                self?.favorites = fetchedMovies
//                completion(fetchedMovies)
//            }
//    }
//    
//    func cleanupListener() {
//        listener?.remove()
//        listener = nil
//    }
//}
//
//
//
//class FavoriteArtistsManager {
//    static let shared = FavoriteArtistsManager()
//    
//    private var favoriteArtists: [Artist] = []
//    private let db = Firestore.firestore()
//    private var documentIDs: [Int: String] = [:] // Store document IDs for each artist
//    
//    private init() {}
//    
//    func addArtist(artist: Artist) {
//        // Check if artist already exists by ID
//        if !favoriteArtists.contains(where: { $0.id == artist.id }) {
//            favoriteArtists.append(artist)
//            saveArtistToFirestore(artist: artist)
//        }
//    }
//    
//    func getFavoriteArtists() -> [Artist] {
//        return favoriteArtists
//    }
//    
//    func removeArtist(artist: Artist) {
//        // Make a local copy of the artist to ensure we have all needed data
//        let artistToRemove = artist
//        
//        // First remove from local array
//        if let index = favoriteArtists.firstIndex(where: { $0.id == artistToRemove.id }) {
//            favoriteArtists.remove(at: index)
//        }
//        
//        // Then remove from Firebase
//        removeArtistFromFirestore(artist: artistToRemove)
//    }
//    
//    func setFavoriteArtists(artists: [Artist]) {
//        favoriteArtists = artists
//    }
//    
//    private func saveArtistToFirestore(artist: Artist) {
//        print("Saving artist to Firestore: \(artist.name)")
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        // Check if this artist already exists in Firestore
//        db.collection("artistFavorite")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("artistID", isEqualTo: artist.id)
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error checking artist: \(error.localizedDescription)")
//                    return
//                }
//                
//                // If no documents found, then add the artist
//                if let documents = snapshot?.documents, documents.isEmpty {
//                    let artistData: [String: Any] = [
//                        "userEmail": userEmail,
//                        "artistID": artist.id,
//                        "artistName": artist.name,
//                        "profilePath": artist.profilePath ?? "",
//                        "timestamp": FieldValue.serverTimestamp() // Add timestamp field
//                    ]
//                    
//                    self?.db.collection("artistFavorite").addDocument(data: artistData) { error in
//                        if let error = error {
//                            print("Error saving artist to Firestore: \(error.localizedDescription)")
//                        } else {
//                            print("Artist saved successfully")
//                            // Refresh the list to ensure everything is in sync
//                            self?.fetchFavoriteArtistsFromFirestore(completion: { _ in })
//                        }
//                    }
//                } else {
//                    print("Artist already exists in Firestore, skipping save")
//                }
//            }
//    }
//    
//    func removeArtistFromFirestore(artist: Artist) {
//        print("⬇️⬇️⬇️ STARTING REMOVAL PROCESS ⬇️⬇️⬇️")
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        print("Attempting to remove artist: \(artist.name) with ID: \(artist.id)")
//        
//        // Use a direct query with no chaining to ensure it works consistently
//        let query = db.collection("artistFavorite")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("artistID", isEqualTo: artist.id)
//        
//        query.getDocuments { [weak self] snapshot, error in
//            if let error = error {
//                print("Error fetching favorite artist: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let documents = snapshot?.documents else {
//                print("No documents found in the snapshot")
//                return
//            }
//            
//            if documents.isEmpty {
//                print("No documents found for artist ID: \(artist.id)")
//                return
//            }
//            
//            print("Found \(documents.count) documents to delete for artist ID: \(artist.id)")
//            
//            for document in documents {
//                print("Document data: \(document.data())")
//                print("Deleting document with ID: \(document.documentID)")
//                
//                // Use a separate delete operation for each document
//                self?.db.collection("artistFavorite").document(document.documentID).delete { error in
//                    if let error = error {
//                        print("❌ Error deleting document \(document.documentID): \(error.localizedDescription)")
//                    } else {
//                        print("✅ Successfully deleted document: \(document.documentID)")
//                        // Remove from our document tracking
//                        if let artistID = document.data()["artistID"] as? Int {
//                            self?.documentIDs.removeValue(forKey: artistID)
//                        }
//                    }
//                }
//            }
//            
//            // Force a refetch after deletion to ensure everything is synced
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self?.fetchFavoriteArtistsFromFirestore(completion: { _ in
//                    print("Refetched artists after deletion")
//                })
//            }
//        }
//        print("⬆️⬆️⬆️ REMOVAL PROCESS INITIATED ⬆️⬆️⬆️")
//    }
//    
//    var listener: ListenerRegistration?
//    
//    func fetchFavoriteArtistsFromFirestore(completion: @escaping ([Artist]) -> Void) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            completion([])
//            return
//        }
//        
//        // Remove existing listener before adding a new one
//        listener?.remove()
//        
//        // Clear existing data before fetching
//        self.favoriteArtists.removeAll()
//        self.documentIDs.removeAll()
//        
//        print("Starting fetch of favorite artists for user: \(userEmail)")
//        
//        listener = db.collection("artistFavorite")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .addSnapshotListener { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error fetching favorite artists: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No favorite artists found")
//                    completion([])
//                    return
//                }
//                
//                print("Fetched \(documents.count) favorite artist documents")
//                
//                var fetchedArtists: [Artist] = []
//                var processedArtistIDs = Set<Int>()
//                
//                for document in documents {
//                    let data = document.data()
//                    print("Document data: \(data)")
//                    
//                    if let id = data["artistID"] as? Int,
//                       let name = data["artistName"] as? String {
//                        // Skip if we've already processed this artist ID
//                        if processedArtistIDs.contains(id) {
//                            continue
//                        }
//                        
//                        processedArtistIDs.insert(id)
//                        let profilePath = data["profilePath"] as? String
//                        
//                        let artist = Artist(id: id, name: name, profilePath: profilePath)
//                        fetchedArtists.append(artist)
//                        
//                        // Store document ID for later use
//                        self?.documentIDs[id] = document.documentID
//                        print("Stored document ID \(document.documentID) for artist ID: \(id)")
//                    }
//                }
//                
//                print("Processed \(fetchedArtists.count) unique artists")
//                self?.favoriteArtists = fetchedArtists
//                completion(fetchedArtists)
//            }
//    }
//    
//    func cleanupListener() {
//        listener?.remove()
//        listener = nil
//    }
//}
//
//
//
//class GenreFavoritesManager {
//    static let shared = GenreFavoritesManager()
//    
//    private var favoriteGenres: [Genre] = []
//    private let db = Firestore.firestore()
//    private var documentIDs: [Int: String] = [:]
//    
//    private init() {}
//    
//    func addGenre(genre: Genre) {
//        if !favoriteGenres.contains(where: { $0.id == genre.id }) {
//            favoriteGenres.append(genre)
//            saveGenreToFirestore(genre: genre)
//        }
//    }
//    
//    func getFavoriteGenres() -> [Genre] {
//        return favoriteGenres
//    }
//    
//    func removeGenre(genre: Genre) {
//        if let index = favoriteGenres.firstIndex(where: { $0.id == genre.id }) {
//            favoriteGenres.remove(at: index)
//            removeGenreFromFirestore(genre: genre)
//        }
//    }
//    
//    func setFavoriteGenres(genres: [Genre]) {
//        favoriteGenres = genres
//    }
//    
//    private func saveGenreToFirestore(genre: Genre) {
//        print("Saving genre to Firestore: \(genre.name)")
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        // Check if this genre already exists in Firestore
//        db.collection("genreFav")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("genreID", isEqualTo: genre.id)
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error checking genre: \(error.localizedDescription)")
//                    return
//                }
//                
//                // If no documents found, then add the genre
//                if let documents = snapshot?.documents, documents.isEmpty {
//                    let genreData: [String: Any] = [
//                        "userEmail": userEmail,
//                        "genreID": genre.id,
//                        "genreName": genre.name,
//                        "timestamp": Date()
//                    ]
//                    
//                    self?.db.collection("genreFav").addDocument(data: genreData) { error in
//                        if let error = error {
//                            print("Error saving genre to Firestore: \(error.localizedDescription)")
//                        } else {
//                            print("Genre saved successfully")
//                        }
//                    }
//                } else {
//                    print("Genre already exists in Firestore, skipping save")
//                }
//            }
//    }
//    
//    func removeGenreFromFirestore(genre: Genre) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            return
//        }
//        
//        db.collection("genreFav")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .whereField("genreID", isEqualTo: genre.id)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching favorite genre: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No favorite genre found")
//                    return
//                }
//                
//                // Make sure we're actually deleting documents here
//                print("Deleting \(documents.count) genre document(s)")
//                
//                for document in documents {
//                    document.reference.delete { error in
//                        if let error = error {
//                            print("Error deleting genre document: \(error.localizedDescription)")
//                        } else {
//                            print("Successfully deleted genre document")
//                        }
//                    }
//                }
//            }
//    }
//    
//    var listener: ListenerRegistration?
//    
//    func fetchFavoriteGenresFromFirestore(completion: @escaping ([Genre]) -> Void) {
//        guard let userEmail = Auth.auth().currentUser?.email else {
//            print("No authenticated user found")
//            completion([])
//            return
//        }
//        // Remove existing listener before adding a new one
//        listener?.remove()
//        
//        // Clear existing data before fetching
//        self.favoriteGenres.removeAll()
//        self.documentIDs.removeAll()
//        
//        listener = db.collection("genreFav")
//            .whereField("userEmail", isEqualTo: userEmail)
//            .addSnapshotListener { [weak self] snapshot, error in
//                if let error = error {
//                    print("Error fetching favorite genres: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No favorite genres found")
//                    completion([])
//                    return
//                }
//                
//                var fetchedGenres: [Genre] = []
//                var processedGenreIDs = Set<Int>()
//                
//                for document in documents {
//                    let data = document.data()
//                    
//                    if let id = data["genreID"] as? Int,
//                       let name = data["genreName"] as? String {
//                        // Skip if we've already processed this genre ID
//                        if processedGenreIDs.contains(id) {
//                            continue
//                        }
//                        
//                        processedGenreIDs.insert(id)
//                        
//                        let genre = Genre(id: id, name: name, image: "")
//                        fetchedGenres.append(genre)
//                        
//                        // Store document ID for later use
//                        self?.documentIDs[id] = document.documentID
//                    }
//                }
//                
//                self?.favoriteGenres = fetchedGenres
//                completion(fetchedGenres)
//            }
//    }
//    
//    func cleanupListener() {
//        listener?.remove()
//        listener = nil
//    }
//}
//
//@objc protocol MediaCellDelegate {
//    func removeArtist(_ sender: UIButton)
//    func removeFromWatchlist(_ sender: UIButton)
//    func removeFromFavorites(_ sender: UIButton)
//}
// 
//@objc protocol ArtistCellDelegate {
//    func removeArtist(_ sender: UIButton)
//}
//@objc protocol GenreCellDelegate {
//    func removeGenre(_ sender: UIButton)
//}
//
//   
//
//
//
//class DownloadsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ArtistCellDelegate, MediaCellDelegate, GenreCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func removeGenre(_ sender: UIButton) {
//        let index = sender.tag
//        guard index < favoriteGenres.count else { return }
//        let genre = favoriteGenres[index]
//        // Remove genre from manager
//        GenreFavoritesManager.shared.removeGenre(genre: genre)
//        // Remove genre from local array and update UI
//        favoriteGenres.remove(at: index)
//        // Animate the deletion
//        favoriteGenresCollectionView.performBatchUpdates({
//            self.favoriteGenresCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//        }) { [weak self] _ in
//            // Reload to ensure indices are up to date
//            self?.favoriteGenresCollectionView.reloadData()
//            self?.updateScrollViewContentSize()
//        }
//    }
//    func removeArtist(_ sender: UIButton) {
//        let index = sender.tag
//        guard index < favoriteArtists.count else { return }
//        let artist = favoriteArtists[index]
//        
//        // Remove artist from local array
//        favoriteArtists.remove(at: index)
//        
//        // Remove artist from manager
//        FavoriteArtistsManager.shared.removeArtist(artist: artist)
//        // Animate the deletion
//        favoriteArtistsCollectionView.performBatchUpdates({
//            self.favoriteArtistsCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//        }) { [weak self] _ in
//            // Reload to ensure indices are up to date
//            self?.favoriteArtistsCollectionView.reloadData()
//        }
//
//    }
//    
//    func removeFromWatchlist(_ sender: UIButton) {
//        let index = sender.tag
//                guard index < watchlistMovies.count else { return }
//                let movie = watchlistMovies[index]
//                // Remove movie from local array
//                watchlistMovies.remove(at: index)
//                // Remove movie from manager
//                WatchlistManager.shared.removeMovie(movie: movie)
//                // Animate the deletion
//                watchlistCollectionView.performBatchUpdates({
//                    self.watchlistCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//                }) { [weak self] _ in
//                    // Reload to ensure indices are up to date
//                    self?.watchlistCollectionView.reloadData()
//                }
//    }
//    
//    func removeFromFavorites(_ sender: UIButton) {
//        let index = sender.tag
//                guard index < favoriteMovies.count else { return }
//                
//                let movie = favoriteMovies[index]
//                
//                // Remove movie from local array
//                favoriteMovies.remove(at: index)
//                
//                // Remove movie from manager
//                FavoritesManager.shared.removeMovie(movie: movie)
//                
//                // Animate the deletion
//                favouritesCollectionView.performBatchUpdates({
//                    self.favouritesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//                }) { [weak self] _ in
//                    // Reload to ensure indices are up to date
//                    self?.favouritesCollectionView.reloadData()
//                }
//            }
//    
//    private var watchlistCollectionView: UICollectionView!
//    private var favouritesCollectionView: UICollectionView!
//    private var favoriteArtistsCollectionView: UICollectionView!
//    private var watchlistMovies: [Title] = []
//    private var favoriteMovies: [Title] = []
//    private var favoriteArtists: [Artist] = []
//    private var currentUser: UserProfile?
//    private let db = Firestore.firestore()
//    private var favoriteGenresCollectionView: UICollectionView!
//    private var favoriteGenres: [Genre] = []
//    
//    private var tableView: UITableView!
//    
//    // Main scroll view to contain all content
//    private lazy var scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.showsVerticalScrollIndicator = true
//        scrollView.indicatorStyle = .white
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//    private func showAlert(message: String) {
//        let alert = UIAlertController(
//            title: "Alert",
//            message: message,
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    // Content view inside scroll view to hold all subviews
//    private lazy var contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    // UI Elements
//    private lazy var profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.backgroundColor = UIColor.darkGray
//        imageView.layer.cornerRadius = 40
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFill
//        
//        // Add tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(tapGesture)
//        
//        return imageView
//    }()
//    private lazy var removePhotoButton: UIButton = {
//            let button = UIButton(type: .system)
//            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//            button.tintColor = .white
//            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//            button.layer.cornerRadius = 12
//            button.isHidden = true // Initially hidden
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.addTarget(self, action: #selector(removePhotoButtonTapped), for: .touchUpInside)
//            return button
//        }()
//    
//    private lazy var onlineIndicator: UIView = {
//        let view = UIView()
//        view.backgroundColor = .green
//        view.layer.cornerRadius = 7
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var nameLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private lazy var roleLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .lightGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let storage = Storage.storage().reference()
//    
//    override func viewDidLoad() {
//            super.viewDidLoad()
//            view.backgroundColor = .black
//            setupUI()
//            setupLogoutButton()
//            fetchUserProfile()
//            loadData()
//        }
//    private func setupLogoutButton() {
//        let logoutButton = UIBarButtonItem(title: "Logout",
//                                          style: .plain,
//                                          target: self,
//                                          action: #selector(logoutButtonTapped))
//        logoutButton.tintColor = .white
//        navigationItem.rightBarButtonItem = logoutButton
//    }
//    @objc private func logoutButtonTapped() {
//        // Create an alert to confirm logout
//        let alert = UIAlertController(title: "Logout",
//                                     message: "Are you sure you want to logout?",
//                                     preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
//            // Sign out from Firebase
//            do {
//                try Auth.auth().signOut()
//                
//                // Clean up any listeners or local data
//                FavoriteArtistsManager.shared.cleanupListener()
//                WatchlistManager.shared.cleanupListener()
//                FavoritesManager.shared.cleanupListener()
//                GenreFavoritesManager.shared.cleanupListener()
//                
//                // Navigate to LoginViewController
//                let loginVC = LoginViewController()
//                let navController = UINavigationController(rootViewController: loginVC)
//                navController.modalPresentationStyle = .fullScreen
//                self?.present(navController, animated: true)
//            } catch {
//                self?.showAlert(message: "Failed to log out: \(error.localizedDescription)")
//            }
//        })
//        
//        present(alert, animated: true)
//        }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchUserProfile()
//        loadData()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        // Clean up listener when view disappears
//        FavoriteArtistsManager.shared.cleanupListener()
//        WatchlistManager.shared.cleanupListener()
//        FavoritesManager.shared.cleanupListener()
//        GenreFavoritesManager.shared.cleanupListener()
//    }
//    
//    private func loadData() {
//        // Load all data from Firebase
//        fetchFavoriteArtists { [weak self] _ in
//            self?.fetchWatchlist { [weak self] _ in
//                self?.fetchFavorites { [weak self] _ in
//                    self?.fetchFavoriteGenres { [weak self] _ in
//                        self?.updateScrollViewContentSize()
//                    }
//                }
//            }
//        }
//    }
//    private func fetchWatchlist(completion: @escaping ([Title]) -> Void) {
//        WatchlistManager.shared.fetchWatchlistFromFirestore { [weak self] movies in
//            DispatchQueue.main.async {
//                self?.watchlistMovies = movies
//                self?.watchlistCollectionView.reloadData()
//                completion(movies)
//            }
//        }
//    }
//    private func fetchFavoriteGenres(completion: @escaping ([Genre]) -> Void) {
//        GenreFavoritesManager.shared.fetchFavoriteGenresFromFirestore { [weak self] genres in
//            DispatchQueue.main.async {
//                self?.favoriteGenres = genres
//                self?.favoriteGenresCollectionView.reloadData()
//                completion(genres)
//            }
//        }
//    }
//    
//    private func fetchFavorites(completion: @escaping ([Title]) -> Void) {
//        FavoritesManager.shared.fetchFavoritesFromFirestore { [weak self] movies in
//            DispatchQueue.main.async {
//                self?.favoriteMovies = movies
//                self?.favouritesCollectionView.reloadData()
//                completion(movies)
//            }
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        updateScrollViewContentSize()
//    }
//    
//    
//    private func fetchUserProfile() {
//           guard let userEmail = Auth.auth().currentUser?.email else {
//               print("No user is currently logged in")
//               return
//           }
//           
//           db.collection("users")
//               .whereField("email", isEqualTo: userEmail)
//               .getDocuments { [weak self] (snapshot, error) in
//                   if let error = error {
//                       print("Error fetching user data: \(error)")
//                       return
//                   }
//                   
//                   guard let documents = snapshot?.documents, !documents.isEmpty else {
//                       print("No user document found")
//                       return
//                   }
//                   
//                   let userData = documents[0].data()
//                   self?.currentUser = UserProfile(data: userData)
//                   
//                   // Load profile image if available
//                   if let imageURLString = userData["profileImageURL"] as? String,
//                      let imageURL = URL(string: imageURLString) {
//                       self?.loadProfileImage(from: imageURL)
//                   }
//                   
//                   DispatchQueue.main.async {
//                       self?.updateUI()
//                   }
//               }
//       }
//       
//       private func loadProfileImage(from url: URL) {
//           // Using SDWebImage to load and cache the image
//           DispatchQueue.main.async { [weak self] in
//               self?.profileImageView.sd_setImage(with: url) { [weak self] (image, error, _, _) in
//                   if let image = image {
//                       self?.profileImageView.backgroundColor = .clear
//                       self?.removePhotoButton.isHidden = false
//                   } else if let error = error {
//                       print("Error loading profile image: \(error.localizedDescription)")
//                   }
//               }
//           }
//       }
//    
//    private func fetchFavoriteArtists(completion: @escaping ([Artist]) -> Void) {
//        FavoriteArtistsManager.shared.fetchFavoriteArtistsFromFirestore { [weak self] artists in
//            DispatchQueue.main.async {
//                self?.favoriteArtists = artists
//                self?.favoriteArtistsCollectionView.reloadData()
//                completion(artists)
//            }
//        }
//    }
//    
//    private func loadWatchlist() {
//        watchlistMovies = WatchlistManager.shared.getWatchlist()
//        print("Watch List Loaded: ", watchlistMovies)
//        watchlistCollectionView.reloadData()
//    }
//    
//    private func loadFavorites() {
//        favoriteMovies = FavoritesManager.shared.getFavorites()
//        print("fav movie Loaded: ", favoriteMovies)
//        favouritesCollectionView.reloadData()
//    }
//    
//    private func updateUI() {
//        guard let user = currentUser else { return }
//        nameLabel.text = user.fullName
//        roleLabel.text = user.role
//        updateInfoLabels(fullName: user.fullName, email: user.email)
//        //updateInfoLabels(fullName: user.fullName, email: user.email, phone: user.phoneNumber)
//    }
//    
//    private func updateInfoLabels(fullName: String, email: String) {
//   // private func updateInfoLabels(fullName: String, email: String, phone: String) {
//        if let usernameStack = contentView.subviews.first(where: { ($0 as? UIStackView)?.arrangedSubviews.last?.accessibilityIdentifier == "usernameLabel" }) as? UIStackView,
//           let usernameLabel = usernameStack.arrangedSubviews.last as? UILabel {
//            usernameLabel.text = fullName
//        }
//        
//        if let emailStack = contentView.subviews.first(where: { ($0 as? UIStackView)?.arrangedSubviews.last?.accessibilityIdentifier == "emailLabel" }) as? UIStackView,
//           let emailLabel = emailStack.arrangedSubviews.last as? UILabel {
//            emailLabel.text = email
//        }
//    }
// 
//    private func setupUI() {
//        // Add scroll view to main view
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        
//        // Setup scroll view constraints
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            // This will be updated after adding all subviews
//        ])
//        
//        // Add all UI elements to the content view
//        contentView.addSubview(profileImageView)
//        contentView.addSubview(removePhotoButton)
//        contentView.addSubview(onlineIndicator)
//        contentView.addSubview(nameLabel)
//        contentView.addSubview(roleLabel)
//        
//        let usernameLabel = createInfoLabel(icon: "person.circle", text: "", identifier: "usernameLabel")
//        let emailLabel = createInfoLabel(icon: "envelope.circle", text: "", identifier: "emailLabel")
//        
//        contentView.addSubview(usernameLabel)
//        contentView.addSubview(emailLabel)
//        
//        let watchlistLabel = createSectionHeader(title: "Watchlist")
//        contentView.addSubview(watchlistLabel)
//        
//        watchlistCollectionView = createCollectionView()
//        contentView.addSubview(watchlistCollectionView)
//        
//        let favouritesLabel = createSectionHeader(title: "My Favourites")
//        contentView.addSubview(favouritesLabel)
//        
//        favouritesCollectionView = createCollectionView()
//        contentView.addSubview(favouritesCollectionView)
//        
//        let favoriteArtistsLabel = createSectionHeader(title: "My Favorite Artists")
//        contentView.addSubview(favoriteArtistsLabel)
//        
//        let modifyButton = UIButton(type: .system)
//        modifyButton.setTitle("Modify", for: .normal)
//        modifyButton.setTitleColor(.systemBlue, for: .normal)
//        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
//        modifyButton.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(modifyButton)
//        
//        favoriteArtistsCollectionView = createCollectionView()
//        contentView.addSubview(favoriteArtistsCollectionView)
//        
//        let favoriteGenresLabel = createSectionHeader(title: "My Favorite Genres")
//            contentView.addSubview(favoriteGenresLabel)
//            
//            let modifyGenresButton = UIButton(type: .system)
//            modifyGenresButton.setTitle("Modify", for: .normal)
//            modifyGenresButton.setTitleColor(.systemBlue, for: .normal)
//            modifyGenresButton.addTarget(self, action: #selector(modifyGenresButtonTapped), for: .touchUpInside)
//            modifyGenresButton.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview(modifyGenresButton)
//            
//            favoriteGenresCollectionView = createCollectionView()
//            contentView.addSubview(favoriteGenresCollectionView)
//            
//            favoriteArtistsCollectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: "WatchlistCell")
//            favoriteGenresCollectionView.register(GenreCell.self, forCellWithReuseIdentifier: "GenreCell")
//        
//        setupConstraints(
//            usernameLabel: usernameLabel,
//            emailLabel: emailLabel,
//            watchlistLabel: watchlistLabel,
//            favouritesLabel: favouritesLabel,
//            favoriteArtistsLabel: favoriteArtistsLabel,
//            modifyButton: modifyButton,
//            favoriteGenresLabel: favoriteGenresLabel,
//            modifyGenresButton: modifyGenresButton
//        )
//    }
//    @objc private func modifyGenresButtonTapped() {
//        // Navigate to the genre selection view controller
//        let genreSelectionVC = MovieGenreSelectionViewController()
//        navigationController?.pushViewController(genreSelectionVC, animated: true)
//    }
//    @objc private func profileImageTapped() {
//            let actionSheet = UIAlertController(title: "Profile Picture",
//                                              message: "Choose an option",
//                                              preferredStyle: .actionSheet)
//            
//            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
//                self?.presentImagePicker(sourceType: .camera)
//            }))
//            
//            actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
//                self?.presentImagePicker(sourceType: .photoLibrary)
//            }))
//            
//            if profileImageView.image != nil && profileImageView.backgroundColor == .clear {
//                actionSheet.addAction(UIAlertAction(title: "Remove Photo", style: .destructive, handler: { [weak self] _ in
//                    self?.removeProfilePhoto()
//                }))
//            }
//            
//            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            
//            present(actionSheet, animated: true)
//        }
//    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
//            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
//                showAlert(message: "This source type is not available on your device")
//                return
//            }
//            
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = sourceType
//            imagePicker.allowsEditing = true
//            present(imagePicker, animated: true)
//        }
//        
//        @objc private func removePhotoButtonTapped() {
//            removeProfilePhoto()
//        }
//        
//        private func removeProfilePhoto() {
//            let alert = UIAlertController(title: "Remove Profile Photo",
//                                         message: "Are you sure you want to remove your profile photo?",
//                                         preferredStyle: .alert)
//            
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            
//            alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
//                self?.deleteProfileImageFromStorage()
//                self?.profileImageView.image = nil
//                self?.profileImageView.backgroundColor = UIColor.darkGray
//                self?.removePhotoButton.isHidden = true
//            })
//            
//            present(alert, animated: true)
//        }
//    
//    
//        
//       
//    
//    
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            picker.dismiss(animated: true)
//            
//            guard let userId = Auth.auth().currentUser?.uid else { return }
//            guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
//            
//            // Update UI immediately
//            profileImageView.backgroundColor = .clear
//            profileImageView.image = image
//            removePhotoButton.isHidden = false
//            
//            // Upload to Firebase Storage
//            uploadProfileImage(image: image, userId: userId)
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            picker.dismiss(animated: true)
//        }
//    
//    
//    
//    private func uploadProfileImage(image: UIImage, userId: String) {
//            guard let imageData = image.jpegData(compressionQuality: 0.75) else {
//                showAlert(message: "Could not prepare image for upload")
//                return
//            }
//            
//            // Show loading indicator or some UI feedback
//            
//            let imageRef = storage.child("profile_images/\(userId).jpg")
//            
//            imageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
//                guard metadata != nil else {
//                    self?.showAlert(message: "Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                // Get download URL
//                imageRef.downloadURL { url, error in
//                    guard let downloadURL = url else {
//                        self?.showAlert(message: "Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
//                        return
//                    }
//                    
//                    // Update user profile in Firestore
//                    self?.updateUserProfileImage(imageURL: downloadURL.absoluteString)
//                }
//            }
//        }
//        
//        private func deleteProfileImageFromStorage() {
//            guard let userId = Auth.auth().currentUser?.uid else { return }
//            
//            let imageRef = storage.child("profile_images/\(userId).jpg")
//            
//            imageRef.delete { [weak self] error in
//                if let error = error {
//                    print("Error deleting profile image: \(error.localizedDescription)")
//                }
//                
//                // Update user profile in Firestore to remove image URL
//                self?.updateUserProfileImage(imageURL: nil)
//            }
//        }
//        
//        private func updateUserProfileImage(imageURL: String?) {
//            guard let userId = Auth.auth().currentUser?.uid else { return }
//            
//            db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "")
//                .getDocuments { [weak self] (snapshot, error) in
//                    if let error = error {
//                        self?.showAlert(message: "Error finding user: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    guard let documents = snapshot?.documents, !documents.isEmpty else {
//                        self?.showAlert(message: "User document not found")
//                        return
//                    }
//                    
//                    let userDocRef = documents[0].reference
//                    
//                    userDocRef.updateData(["profileImageURL": imageURL as Any]) { error in
//                        if let error = error {
//                            self?.showAlert(message: "Error updating profile: \(error.localizedDescription)")
//                        }
//                    }
//                }
//        }
//        
//    
//    @objc private func modifyButtonTapped() {
//        // Navigate to the artist selection view controller
//        let artistSelectionVC = ArtistSelectionViewController()
//        navigationController?.pushViewController(artistSelectionVC, animated: true)
//    }
//    
//    private func createInfoLabel(icon: String, text: String, identifier: String) -> UIStackView {
//        let imageView = UIImageView(image: UIImage(systemName: icon))
//        imageView.tintColor = .white
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let label = UILabel()
//        label.text = text
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.accessibilityIdentifier = identifier
//        
//        let stack = UIStackView(arrangedSubviews: [imageView, label])
//        stack.axis = .horizontal
//        stack.spacing = 8
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }
//    
//    private func createSectionHeader(title: String) -> UILabel {
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.textColor = .white
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        return titleLabel
//    }
//    
//    private func createCollectionView() -> UICollectionView {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 8
//        layout.itemSize = CGSize(width: 120, height: 160)
//        
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: "WatchlistCell")
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        return collectionView
//    }
//    
//    
//    private func setupConstraints(
//        usernameLabel: UIStackView,
//       // contactLabel: UIStackView,
//        emailLabel: UIStackView,
//        watchlistLabel: UILabel,
//        favouritesLabel: UILabel,
//        favoriteArtistsLabel: UILabel,
//        modifyButton: UIButton,
//        favoriteGenresLabel: UILabel,
//            modifyGenresButton: UIButton
//    ) {
//        NSLayoutConstraint.activate([
//            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 165),
//            profileImageView.widthAnchor.constraint(equalToConstant: 80),
//            profileImageView.heightAnchor.constraint(equalToConstant: 80),
//            
//            
//            removePhotoButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
//                       removePhotoButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 0),
//                       removePhotoButton.widthAnchor.constraint(equalToConstant: 24),
//                       removePhotoButton.heightAnchor.constraint(equalToConstant: 24),
//            
//            onlineIndicator.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
//            onlineIndicator.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
//            onlineIndicator.widthAnchor.constraint(equalToConstant: 14),
//            onlineIndicator.heightAnchor.constraint(equalToConstant: 14),
//            
//            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30),
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 145),
//            
//            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
//            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 150),
//            
//            usernameLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 30),
//            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            
//            
//            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
//            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            
//            watchlistLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
//            watchlistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            
//            watchlistCollectionView.topAnchor.constraint(equalTo: watchlistLabel.bottomAnchor, constant: 8),
//            watchlistCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            watchlistCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            watchlistCollectionView.heightAnchor.constraint(equalToConstant: 160),
//            
//            favouritesLabel.topAnchor.constraint(equalTo: watchlistCollectionView.bottomAnchor, constant: 16),
//            favouritesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            
//            favouritesCollectionView.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor, constant: 8),
//            favouritesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            favouritesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            favouritesCollectionView.heightAnchor.constraint(equalToConstant: 160),
//            
//            favoriteArtistsLabel.topAnchor.constraint(equalTo: favouritesCollectionView.bottomAnchor, constant: 16),
//            favoriteArtistsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            
//            modifyButton.centerYAnchor.constraint(equalTo: favoriteArtistsLabel.centerYAnchor),
//            modifyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            
//            favoriteArtistsCollectionView.topAnchor.constraint(equalTo: favoriteArtistsLabel.bottomAnchor, constant: 8),
//            favoriteArtistsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            favoriteArtistsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            favoriteArtistsCollectionView.heightAnchor.constraint(equalToConstant: 160),
//            
//            favoriteGenresLabel.topAnchor.constraint(equalTo: favoriteArtistsCollectionView.bottomAnchor, constant: 16),
//                    favoriteGenresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//                    
//                    modifyGenresButton.centerYAnchor.constraint(equalTo: favoriteGenresLabel.centerYAnchor),
//                    modifyGenresButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//                    
//                    favoriteGenresCollectionView.topAnchor.constraint(equalTo: favoriteGenresLabel.bottomAnchor, constant: 8),
//                    favoriteGenresCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//                    favoriteGenresCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//                    favoriteGenresCollectionView.heightAnchor.constraint(equalToConstant: 50),
//            
//            
//            
//            contentView.bottomAnchor.constraint(equalTo: favoriteGenresCollectionView.bottomAnchor, constant: 32)
//        ])
//        
//    }
//    private func updateScrollViewContentSize() {
//        view.layoutIfNeeded()
//        
//        let bottomPadding: CGFloat = 32
//        if let lastView = favoriteGenresCollectionView {
//            scrollView.contentSize = CGSize(
//                width: scrollView.frame.width,
//                height: lastView.frame.maxY + bottomPadding
//            )
//        }
//    }
//    
//    
//    
//    // MARK: - UICollectionView DataSource
//    
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == watchlistCollectionView {
//            return watchlistMovies.count
//        } else if collectionView == favouritesCollectionView {
//            return favoriteMovies.count
//        } else if collectionView == favoriteArtistsCollectionView {
//            return favoriteArtists.count
//        } else {
//            return favoriteGenres.count
//        }
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == watchlistCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
//            let movie = watchlistMovies[indexPath.item]
//            cell.configureMovieCell(movie: movie, index: indexPath.item, isWatchlist: true, delegate: self)
//            return cell
//        } else if collectionView == favouritesCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
//            let movie = favoriteMovies[indexPath.item]
//            cell.configureMovieCell(movie: movie, index: indexPath.item, isWatchlist: false, delegate: self)
//            return cell
//        } else if collectionView == favoriteArtistsCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
//            let artist = favoriteArtists[indexPath.item]
//            cell.configureArtistCell(artist: artist, index: indexPath.item, delegate: self)
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as! GenreCell
//            let genre = favoriteGenres[indexPath.item]
//            cell.configure(genre: genre, index: indexPath.item, delegate: self)
//            return cell
//        }
//    }
//        
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == favoriteGenresCollectionView {
//            // For genres, we'll make the cells appropriately sized for the genre name
//            let genre = favoriteGenres[indexPath.item]
//            let width = min(max(genre.name.size(withAttributes: [.font: UIFont.systemFont(ofSize: 12)]).width + 40, 80), 160)
//            return CGSize(width: width, height: 40)
//        } else {
//            // For other collection views, use the default size
//            return CGSize(width: 120, height: 160)
//        }
//    }
//    
//    
//    class GenreCell: UICollectionViewCell {
//        private let containerView: UIView = {
//            let view = UIView()
//            view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
//            view.layer.cornerRadius = 8
//            view.translatesAutoresizingMaskIntoConstraints = false
//            return view
//        }()
//        
//        private let nameLabel: UILabel = {
//            let label = UILabel()
//            label.textColor = .white
//            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//            label.textAlignment = .center
//            label.numberOfLines = 1
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//        
//        private var removeButton: UIButton?
//        
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            setupUI()
//        }
//        
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//        
//        private func setupUI() {
//            contentView.addSubview(containerView)
//            containerView.addSubview(nameLabel)
//            
//            NSLayoutConstraint.activate([
//                containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
//                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//                
//                nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//                nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
//                nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
//            ])
//        }
//        
//        func configure(genre: Genre, index: Int, delegate: GenreCellDelegate) {
//            nameLabel.text = genre.name
//            configureRemoveButton(index: index, delegate: delegate)
//        }
//        
//        private func configureRemoveButton(index: Int, delegate: GenreCellDelegate) {
//            // Remove existing button if it exists
//            removeButton?.removeFromSuperview()
//            removeButton = nil
//            
//            // Create a new remove button
//            let button = UIButton(type: .system)
//            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//            button.tintColor = .white
//            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//            button.layer.cornerRadius = 10
//            button.translatesAutoresizingMaskIntoConstraints = false
//            
//            contentView.addSubview(button)
//            
//            NSLayoutConstraint.activate([
//                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
//                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
//                button.widthAnchor.constraint(equalToConstant: 22),
//                button.heightAnchor.constraint(equalToConstant: 22)
//            ])
//            
//            button.tag = index
//            button.addTarget(delegate, action: #selector(GenreCellDelegate.removeGenre(_:)), for: .touchUpInside)
//            
//            removeButton = button
//        }
//        
//        override func prepareForReuse() {
//            super.prepareForReuse()
//            removeButton?.removeFromSuperview()
//            removeButton = nil
//            nameLabel.text = ""
//        }
//    }
//    
//    
//    class WatchlistCell: UICollectionViewCell {
//        private let imageView: UIImageView = {
//            let imageView = UIImageView()
//            imageView.contentMode = .scaleAspectFill
//            imageView.clipsToBounds = true
//            imageView.layer.cornerRadius = 8
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            return imageView
//        }()
//        
//        private let nameLabel: UILabel = {
//            let label = UILabel()
//            label.textColor = .white
//            label.font = UIFont.systemFont(ofSize: 12)
//            label.textAlignment = .center
//            label.numberOfLines = 2
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//        
//        private var removeButton: UIButton?
//        
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            setupUI()
//        }
//        
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//        
//        private func setupUI() {
//            contentView.addSubview(imageView)
//            contentView.addSubview(nameLabel)
//            
//            NSLayoutConstraint.activate([
//                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//                imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
//                
//                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
//                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//                nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
//            ])
//        }
//        
//        func configureMovieCell(movie: Title, index: Int, isWatchlist: Bool, delegate: MediaCellDelegate) {
//                if let posterPath = movie.poster_path {
//                    let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
//                    imageView.sd_setImage(with: posterURL, placeholderImage: UIImage(systemName: "film"))
//                } else {
//                    imageView.image = UIImage(systemName: "film")
//                }
//                
//                // Set the movie title
//                nameLabel.text = movie.original_title ?? movie.original_name
//                
//                // Configure the remove button with the appropriate action based on collection type
//                configureRemoveButton(index: index, isWatchlist: isWatchlist, delegate: delegate)
//            }
//        
//        func configureArtistCell(artist: Artist, index: Int, delegate: ArtistCellDelegate) {
//            if let profilePath = artist.profilePath {
//                let profileURL = URL(string: "https://image.tmdb.org/t/p/w500\(profilePath)")
//                imageView.sd_setImage(with: profileURL, placeholderImage: UIImage(systemName: "person.fill"))
//            } else {
//                imageView.image = UIImage(systemName: "person.fill")
//            }
//            
//            // Set the artist name
//            nameLabel.text = artist.name
//            
//            // Configure the remove button
//            configureRemoveButton(index: index, isArtist: true, delegate: delegate)
//        }
//        
//        private func configureRemoveButton(index: Int, isWatchlist: Bool = false, isArtist: Bool = false, delegate: AnyObject?) {
//                // Remove existing button if it exists
//                removeButton?.removeFromSuperview()
//                removeButton = nil
//                
//                // Create a new remove button
//                let button = UIButton(type: .system)
//                button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//                button.tintColor = .white
//                button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//                button.layer.cornerRadius = 10
//                button.translatesAutoresizingMaskIntoConstraints = false
//                
//                contentView.addSubview(button)
//                
//                NSLayoutConstraint.activate([
//                    button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
//                    button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
//                    button.widthAnchor.constraint(equalToConstant: 22),
//                    button.heightAnchor.constraint(equalToConstant: 22)
//                ])
//                
//                button.tag = index
//                
//                // Set the target action based on the type
//                if isArtist, let delegate = delegate as? ArtistCellDelegate {
//                    button.addTarget(delegate, action: #selector(ArtistCellDelegate.removeArtist(_:)), for: .touchUpInside)
//                } else if let delegate = delegate as? MediaCellDelegate {
//                    if isWatchlist {
//                        button.addTarget(delegate, action: #selector(MediaCellDelegate.removeFromWatchlist(_:)), for: .touchUpInside)
//                    } else {
//                        button.addTarget(delegate, action: #selector(MediaCellDelegate.removeFromFavorites(_:)), for: .touchUpInside)
//                    }
//                }
//                
//                removeButton = button
//            }
//        
//        override func prepareForReuse() {
//            super.prepareForReuse()
//            // Clear the remove button and its target action
//            removeButton?.removeFromSuperview()
//            removeButton = nil
//            nameLabel.text = ""
//        }
//    }
//    
//}



























import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct UserProfile {
    let fullName: String
    let email: String
    let role: String
    let profileImageURL: String?
    
    init(data: [String: Any]) {
        self.fullName = data["Full Name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.role = data["role"] as? String ?? "Movie Enthusiast"
        self.profileImageURL = data["profileImageURL"] as? String
    }
}

class WatchlistManager {
    static let shared = WatchlistManager()
    
    private var watchlist: [Title] = []
    private let db = Firestore.firestore()
    private var documentIDs: [Int: String] = [:]
    
    private init() {}
    
    func addMovieToWatchlist(movie: Title) {
        if !watchlist.contains(where: { $0.id == movie.id }) {
            watchlist.append(movie)
            saveMovieToFirestore(movie: movie)
        }
    }
    
    func getWatchlist() -> [Title] {
        return watchlist
    }
    
    func removeMovie(movie: Title) {
        if let index = watchlist.firstIndex(where: { $0.id == movie.id }) {
            watchlist.remove(at: index)
            removeMovieFromFirestore(movie: movie)
        }
    }
    
    func setWatchlist(movies: [Title]) {
        watchlist = movies
    }
    
    private func saveMovieToFirestore(movie: Title) {
        print("Saving movie to Firestore: \(movie.original_title ?? movie.original_name ?? "Unknown")")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        // Check if this movie already exists in Firestore
        db.collection("watchlist")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("movieID", isEqualTo: movie.id)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking movie: \(error.localizedDescription)")
                    return
                }
                
                // If no documents found, then add the movie
                if let documents = snapshot?.documents, documents.isEmpty {
                    let movieData: [String: Any] = [
                        "userEmail": userEmail,
                        "movieID": movie.id,
                        "title": movie.original_title ?? movie.original_name ?? "Unknown",
                        "posterPath": movie.poster_path ?? "",
                        "mediaType": movie.media_type ?? "movie",
                        "addedDate": Date()
                    ]
                    
                    self?.db.collection("watchlist").addDocument(data: movieData) { error in
                        if let error = error {
                            print("Error saving movie to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Movie saved successfully to watchlist")
                        }
                    }
                } else {
                    print("Movie already exists in watchlist Firestore, skipping save")
                }
            }
    }
    
    func removeMovieFromFirestore(movie: Title) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        db.collection("watchlist")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("movieID", isEqualTo: movie.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching watchlist movie: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No watchlist movie found")
                    return
                }
                
                for document in documents {
                    document.reference.delete()
                }
            }
    }
    
    var listener: ListenerRegistration?
    
    func fetchWatchlistFromFirestore(completion: @escaping ([Title]) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            completion([])
            return
        }
        
        // Remove existing listener before adding a new one
        listener?.remove()
        
        // Clear existing data before fetching
        self.watchlist.removeAll()
        self.documentIDs.removeAll()
        
        listener = db.collection("watchlist")
            .whereField("userEmail", isEqualTo: userEmail)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching watchlist: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No watchlist movies found")
                    completion([])
                    return
                }
                
                var fetchedMovies: [Title] = []
                var processedMovieIDs = Set<Int>()
                
                for document in documents {
                    let data = document.data()
                    
                    if let id = data["movieID"] as? Int,
                       let title = data["title"] as? String {
                        // Skip if we've already processed this movie ID
                        if processedMovieIDs.contains(id) {
                            continue
                        }
                        
                        processedMovieIDs.insert(id)
                        let posterPath = data["posterPath"] as? String
                        let mediaType = data["mediaType"] as? String ?? "movie"
                        
                        let movie = Title(
                            id: id,
                            media_type: mediaType,
                            original_name: mediaType == "tv" ? title : nil,
                            original_title: mediaType == "movie" ? title : nil,
                            poster_path: posterPath,
                            overview: nil,
                            vote_count: 0,
                            release_date: nil,
                            first_air_date: nil,  // Add this parameter
                            vote_average: 0.0,
                            popularity: 0.0
                            
                        )
                        
                        fetchedMovies.append(movie)
                        
                        // Store document ID for later use
                        self?.documentIDs[id] = document.documentID
                    }
                }
                
                self?.watchlist = fetchedMovies
                completion(fetchedMovies)
            }
    }
    
    func cleanupListener() {
        listener?.remove()
        listener = nil
    }
}

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private var favorites: [Title] = []
    private let db = Firestore.firestore()
    private var documentIDs: [Int: String] = [:] // Store document IDs for each title
    
    private init() {}
    
    func addMovieToFavorites(movie: Title) {
        if !favorites.contains(where: { $0.id == movie.id }) {
            favorites.append(movie)
            saveMovieToFirestore(movie: movie)
        }
    }
    
    func getFavorites() -> [Title] {
        return favorites
    }
    
    func removeMovie(movie: Title) {
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites.remove(at: index)
            removeMovieFromFirestore(movie: movie)
        }
    }
    
    func setFavorites(movies: [Title]) {
        favorites = movies
    }
    
    private func saveMovieToFirestore(movie: Title) {
        print("Saving movie to Firestore favorites: \(movie.original_title ?? movie.original_name ?? "Unknown")")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        // Check if this movie already exists in Firestore
        db.collection("favorites")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("movieID", isEqualTo: movie.id)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking favorite movie: \(error.localizedDescription)")
                    return
                }
                
                // If no documents found, then add the movie
                if let documents = snapshot?.documents, documents.isEmpty {
                    let movieData: [String: Any] = [
                        "userEmail": userEmail,
                        "movieID": movie.id,
                        "title": movie.original_title ?? movie.original_name ?? "Unknown",
                        "posterPath": movie.poster_path ?? "",
                        "mediaType": movie.media_type ?? "movie",
                        "addedDate": Date()
                    ]
                    
                    self?.db.collection("favorites").addDocument(data: movieData) { error in
                        if let error = error {
                            print("Error saving movie to Firestore favorites: \(error.localizedDescription)")
                        } else {
                            print("Movie saved successfully to favorites")
                        }
                    }
                } else {
                    print("Movie already exists in favorites Firestore, skipping save")
                }
            }
    }
    
    func removeMovieFromFirestore(movie: Title) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        db.collection("favorites")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("movieID", isEqualTo: movie.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching favorite movie: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No favorite movie found")
                    return
                }
                
                for document in documents {
                    document.reference.delete()
                }
            }
    }
    
    var listener: ListenerRegistration?
    
    func fetchFavoritesFromFirestore(completion: @escaping ([Title]) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            completion([])
            return
        }
        
        // Remove existing listener before adding a new one
        listener?.remove()
        
        // Clear existing data before fetching
        self.favorites.removeAll()
        self.documentIDs.removeAll()
        
        listener = db.collection("favorites")
            .whereField("userEmail", isEqualTo: userEmail)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching favorites: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No favorite movies found")
                    completion([])
                    return
                }
                
                var fetchedMovies: [Title] = []
                var processedMovieIDs = Set<Int>()
                
                for document in documents {
                    let data = document.data()
                    
                    if let id = data["movieID"] as? Int,
                       let title = data["title"] as? String {
                        // Skip if we've already processed this movie ID
                        if processedMovieIDs.contains(id) {
                            continue
                        }
                        
                        processedMovieIDs.insert(id)
                        let posterPath = data["posterPath"] as? String
                        let mediaType = data["mediaType"] as? String ?? "movie"
                        
                        let movie = Title(
                            id: id,
                            media_type: mediaType,
                            original_name: mediaType == "tv" ? title : nil,
                            original_title: mediaType == "movie" ? title : nil,
                            poster_path: posterPath,
                            overview: nil,
                            vote_count: 0,
                            release_date: nil,
                            first_air_date: nil,  // Add this parameter
                            vote_average: 0.0,
                            popularity: 0.0
                        )
                        
                        fetchedMovies.append(movie)
                        
                        // Store document ID for later use
                        self?.documentIDs[id] = document.documentID
                    }
                }
                
                self?.favorites = fetchedMovies
                completion(fetchedMovies)
            }
    }
    
    func cleanupListener() {
        listener?.remove()
        listener = nil
    }
}



class FavoriteArtistsManager {
    static let shared = FavoriteArtistsManager()
    
    private var favoriteArtists: [Artist] = []
    private let db = Firestore.firestore()
    private var documentIDs: [Int: String] = [:] // Store document IDs for each artist
    
    private init() {}
    
    func addArtist(artist: Artist) {
        // Check if artist already exists by ID
        if !favoriteArtists.contains(where: { $0.id == artist.id }) {
            favoriteArtists.append(artist)
            saveArtistToFirestore(artist: artist)
        }
    }
    
    func getFavoriteArtists() -> [Artist] {
        return favoriteArtists
    }
    
    func removeArtist(artist: Artist) {
        // Make a local copy of the artist to ensure we have all needed data
        let artistToRemove = artist
        
        // First remove from local array
        if let index = favoriteArtists.firstIndex(where: { $0.id == artistToRemove.id }) {
            favoriteArtists.remove(at: index)
        }
        
        // Then remove from Firebase
        removeArtistFromFirestore(artist: artistToRemove)
    }
    
    func setFavoriteArtists(artists: [Artist]) {
        favoriteArtists = artists
    }
    
    private func saveArtistToFirestore(artist: Artist) {
        print("Saving artist to Firestore: \(artist.name)")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        // Check if this artist already exists in Firestore
        db.collection("artistFavorite")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("artistID", isEqualTo: artist.id)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking artist: \(error.localizedDescription)")
                    return
                }
                
                // If no documents found, then add the artist
                if let documents = snapshot?.documents, documents.isEmpty {
                    let artistData: [String: Any] = [
                        "userEmail": userEmail,
                        "artistID": artist.id,
                        "artistName": artist.name,
                        "profilePath": artist.profilePath ?? "",
                        "timestamp": FieldValue.serverTimestamp() // Add timestamp field
                    ]
                    
                    self?.db.collection("artistFavorite").addDocument(data: artistData) { error in
                        if let error = error {
                            print("Error saving artist to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Artist saved successfully")
                            // Refresh the list to ensure everything is in sync
                            self?.fetchFavoriteArtistsFromFirestore(completion: { _ in })
                        }
                    }
                } else {
                    print("Artist already exists in Firestore, skipping save")
                }
            }
    }
    
    func removeArtistFromFirestore(artist: Artist) {
        print("⬇️⬇️⬇️ STARTING REMOVAL PROCESS ⬇️⬇️⬇️")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        print("Attempting to remove artist: \(artist.name) with ID: \(artist.id)")
        
        // Use a direct query with no chaining to ensure it works consistently
        let query = db.collection("artistFavorite")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("artistID", isEqualTo: artist.id)
        
        query.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching favorite artist: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in the snapshot")
                return
            }
            
            if documents.isEmpty {
                print("No documents found for artist ID: \(artist.id)")
                return
            }
            
            print("Found \(documents.count) documents to delete for artist ID: \(artist.id)")
            
            for document in documents {
                print("Document data: \(document.data())")
                print("Deleting document with ID: \(document.documentID)")
                
                // Use a separate delete operation for each document
                self?.db.collection("artistFavorite").document(document.documentID).delete { error in
                    if let error = error {
                        print("❌ Error deleting document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully deleted document: \(document.documentID)")
                        // Remove from our document tracking
                        if let artistID = document.data()["artistID"] as? Int {
                            self?.documentIDs.removeValue(forKey: artistID)
                        }
                    }
                }
            }
            
            // Force a refetch after deletion to ensure everything is synced
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.fetchFavoriteArtistsFromFirestore(completion: { _ in
                    print("Refetched artists after deletion")
                })
            }
        }
        print("⬆️⬆️⬆️ REMOVAL PROCESS INITIATED ⬆️⬆️⬆️")
    }
    
    var listener: ListenerRegistration?
    
    func fetchFavoriteArtistsFromFirestore(completion: @escaping ([Artist]) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            completion([])
            return
        }
        
        // Remove existing listener before adding a new one
        listener?.remove()
        
        // Clear existing data before fetching
        self.favoriteArtists.removeAll()
        self.documentIDs.removeAll()
        
        print("Starting fetch of favorite artists for user: \(userEmail)")
        
        listener = db.collection("artistFavorite")
            .whereField("userEmail", isEqualTo: userEmail)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching favorite artists: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No favorite artists found")
                    completion([])
                    return
                }
                
                print("Fetched \(documents.count) favorite artist documents")
                
                var fetchedArtists: [Artist] = []
                var processedArtistIDs = Set<Int>()
                
                for document in documents {
                    let data = document.data()
                    print("Document data: \(data)")
                    
                    if let id = data["artistID"] as? Int,
                       let name = data["artistName"] as? String {
                        // Skip if we've already processed this artist ID
                        if processedArtistIDs.contains(id) {
                            continue
                        }
                        
                        processedArtistIDs.insert(id)
                        let profilePath = data["profilePath"] as? String
                        
                        let artist = Artist(id: id, name: name, profilePath: profilePath)
                        fetchedArtists.append(artist)
                        
                        // Store document ID for later use
                        self?.documentIDs[id] = document.documentID
                        print("Stored document ID \(document.documentID) for artist ID: \(id)")
                    }
                }
                
                print("Processed \(fetchedArtists.count) unique artists")
                self?.favoriteArtists = fetchedArtists
                completion(fetchedArtists)
            }
    }
    
    func cleanupListener() {
        listener?.remove()
        listener = nil
    }
}



class GenreFavoritesManager {
    static let shared = GenreFavoritesManager()
    
    private var favoriteGenres: [Genre] = []
    private let db = Firestore.firestore()
    private var documentIDs: [Int: String] = [:]
    
    private init() {}
    
    func addGenre(genre: Genre) {
        if !favoriteGenres.contains(where: { $0.id == genre.id }) {
            favoriteGenres.append(genre)
            saveGenreToFirestore(genre: genre)
        }
    }
    
    func getFavoriteGenres() -> [Genre] {
        return favoriteGenres
    }
    
    func removeGenre(genre: Genre) {
        if let index = favoriteGenres.firstIndex(where: { $0.id == genre.id }) {
            favoriteGenres.remove(at: index)
            removeGenreFromFirestore(genre: genre)
        }
    }
    
    func setFavoriteGenres(genres: [Genre]) {
        favoriteGenres = genres
    }
    
    private func saveGenreToFirestore(genre: Genre) {
        print("Saving genre to Firestore: \(genre.name)")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        // Check if this genre already exists in Firestore
        db.collection("genreFav")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("genreID", isEqualTo: genre.id)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking genre: \(error.localizedDescription)")
                    return
                }
                
                // If no documents found, then add the genre
                if let documents = snapshot?.documents, documents.isEmpty {
                    let genreData: [String: Any] = [
                        "userEmail": userEmail,
                        "genreID": genre.id,
                        "genreName": genre.name,
                        "timestamp": Date()
                    ]
                    
                    self?.db.collection("genreFav").addDocument(data: genreData) { error in
                        if let error = error {
                            print("Error saving genre to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Genre saved successfully")
                        }
                    }
                } else {
                    print("Genre already exists in Firestore, skipping save")
                }
            }
    }
    
    func removeGenreFromFirestore(genre: Genre) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        db.collection("genreFav")
            .whereField("userEmail", isEqualTo: userEmail)
            .whereField("genreID", isEqualTo: genre.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching favorite genre: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No favorite genre found")
                    return
                }
                
                // Make sure we're actually deleting documents here
                print("Deleting \(documents.count) genre document(s)")
                
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting genre document: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted genre document")
                        }
                    }
                }
            }
    }
    
    var listener: ListenerRegistration?
    
    func fetchFavoriteGenresFromFirestore(completion: @escaping ([Genre]) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            completion([])
            return
        }
        // Remove existing listener before adding a new one
        listener?.remove()
        
        // Clear existing data before fetching
        self.favoriteGenres.removeAll()
        self.documentIDs.removeAll()
        
        listener = db.collection("genreFav")
            .whereField("userEmail", isEqualTo: userEmail)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching favorite genres: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No favorite genres found")
                    completion([])
                    return
                }
                
                var fetchedGenres: [Genre] = []
                var processedGenreIDs = Set<Int>()
                
                for document in documents {
                    let data = document.data()
                    
                    if let id = data["genreID"] as? Int,
                       let name = data["genreName"] as? String {
                        // Skip if we've already processed this genre ID
                        if processedGenreIDs.contains(id) {
                            continue
                        }
                        
                        processedGenreIDs.insert(id)
                        
                        let genre = Genre(id: id, name: name, image: "")
                        fetchedGenres.append(genre)
                        
                        // Store document ID for later use
                        self?.documentIDs[id] = document.documentID
                    }
                }
                
                self?.favoriteGenres = fetchedGenres
                completion(fetchedGenres)
            }
    }
    
    func cleanupListener() {
        listener?.remove()
        listener = nil
    }
}

@objc protocol MediaCellDelegate {
    func removeArtist(_ sender: UIButton)
    func removeFromWatchlist(_ sender: UIButton)
    func removeFromFavorites(_ sender: UIButton)
}
 
@objc protocol ArtistCellDelegate {
    func removeArtist(_ sender: UIButton)
}
@objc protocol GenreCellDelegate {
    func removeGenre(_ sender: UIButton)
}
class DownloadsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ArtistCellDelegate, MediaCellDelegate, GenreCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func removeGenre(_ sender: UIButton) {
        let index = sender.tag
        guard index < favoriteGenres.count else { return }
        let genre = favoriteGenres[index]
        GenreFavoritesManager.shared.removeGenre(genre: genre)
        favoriteGenres.remove(at: index)
        favoriteGenresCollectionView.performBatchUpdates({
            self.favoriteGenresCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }) { [weak self] _ in
            self?.favoriteGenresCollectionView.reloadData()
            self?.updateScrollViewContentSize()
        }
    }
    func removeArtist(_ sender: UIButton) {
        let index = sender.tag
        guard index < favoriteArtists.count else { return }
        let artist = favoriteArtists[index]
        favoriteArtists.remove(at: index)
        FavoriteArtistsManager.shared.removeArtist(artist: artist)
        favoriteArtistsCollectionView.performBatchUpdates({
            self.favoriteArtistsCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }) { [weak self] _ in
            self?.favoriteArtistsCollectionView.reloadData()
        }
    }
    func removeFromWatchlist(_ sender: UIButton) {
        let index = sender.tag
                guard index < watchlistMovies.count else { return }
                let movie = watchlistMovies[index]
                // Remove movie from local array
                watchlistMovies.remove(at: index)
                // Remove movie from manager
                WatchlistManager.shared.removeMovie(movie: movie)
                // Animate the deletion
                watchlistCollectionView.performBatchUpdates({
                    self.watchlistCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }) { [weak self] _ in
                    // Reload to ensure indices are up to date
                    self?.watchlistCollectionView.reloadData()
                }
    }
    
    func removeFromFavorites(_ sender: UIButton) {
        let index = sender.tag
                guard index < favoriteMovies.count else { return }
                
                let movie = favoriteMovies[index]
                
                // Remove movie from local array
                favoriteMovies.remove(at: index)
                
                // Remove movie from manager
                FavoritesManager.shared.removeMovie(movie: movie)
                
                // Animate the deletion
                favouritesCollectionView.performBatchUpdates({
                    self.favouritesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }) { [weak self] _ in
                    // Reload to ensure indices are up to date
                    self?.favouritesCollectionView.reloadData()
                }
            }
    
    private var watchlistCollectionView: UICollectionView!
    private var favouritesCollectionView: UICollectionView!
    private var favoriteArtistsCollectionView: UICollectionView!
    private var watchlistMovies: [Title] = []
    private var favoriteMovies: [Title] = []
    private var favoriteArtists: [Artist] = []
    private var currentUser: UserProfile?
    private let db = Firestore.firestore()
    private var favoriteGenresCollectionView: UICollectionView!
    private var favoriteGenres: [Genre] = []
    
    private var tableView: UITableView!
    
    // Main scroll view to contain all content
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Content view inside scroll view to hold all subviews
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // UI Elements
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.darkGray
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    private lazy var removePhotoButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 12
            button.isHidden = true // Initially hidden
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(removePhotoButtonTapped), for: .touchUpInside)
            return button
        }()
    
    private lazy var editProfileButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 14
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
            return button
        }()
    
    @objc private func editProfileTapped() {
            let alertController = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.placeholder = "Full Name"
                textField.text = self.currentUser?.fullName
            }
            
            alertController.addTextField { textField in
                textField.placeholder = "Email"
                textField.text = self.currentUser?.email
                textField.keyboardType = .emailAddress
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let nameTextField = alertController.textFields?[0],
                      let emailTextField = alertController.textFields?[1],
                      let newName = nameTextField.text, !newName.isEmpty,
                      let newEmail = emailTextField.text, !newEmail.isEmpty else {
                    self?.showAlert(message: "Please fill in all fields")
                    return
                }
                
                self?.updateUserProfile(fullName: newName, email: newEmail)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
        }
        
        private func updateUserProfile(fullName: String, email: String) {
            guard let user = Auth.auth().currentUser else {
                showAlert(message: "User not logged in")
                return
            }
            
            // Skip Firebase Authentication email update to bypass verification
            // Only update Firestore with the new name and email
            updateFirestore(fullName: fullName, email: email, uid: user.uid)
            
            // Optionally, inform the user that their login email hasn't changed
            if email != user.email {
                showAlert(message: "Profile updated successfully! Note: Your login email is still \(user.email ?? ""). To change your login email, please use the 'Change Email' option in your account settings.")
            }
        }
        
        private func updateFirestore(fullName: String, email: String, uid: String) {
            let userDocRef = db.collection("users").document(uid)
            
            let updatedData: [String: Any] = [
                "Full Name": fullName,
                "email": email,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            userDocRef.setData(updatedData, merge: true) { [weak self] error in
                if let error = error {
                    self?.showAlert(message: "Error updating profile: \(error.localizedDescription)")
                } else {
                    self?.currentUser = UserProfile(data: [
                        "Full Name": fullName,
                        "email": email,
                        "role": self?.currentUser?.role ?? "Movie Enthusiast",
                        "profileImageURL": self?.currentUser?.profileImageURL ?? ""
                    ])
                    
                    DispatchQueue.main.async {
                        self?.updateUI()
                        if email == Auth.auth().currentUser?.email {
                            self?.showAlert(message: "Profile updated successfully!")
                        }
                    }
                }
            }
        }
        @objc private func profileImageTapped() {
            let actionSheet = UIAlertController(title: "Profile Picture",
                                                message: "Choose from Library",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            }))
            
            if profileImageView.image != nil && profileImageView.backgroundColor == .clear {
                actionSheet.addAction(UIAlertAction(title: "Remove Photo", style: .destructive, handler: { [weak self] _ in
                    self?.removeProfilePhoto()
                }))
            }
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(actionSheet, animated: true)
        }
        
        // Update setupConstraints to replace onlineIndicator with editProfileButton
        private func setupConstraints(
            // ... other parameters remain the same
            favoriteGenresLabel: UILabel,
            modifyGenresButton: UIButton
        ) {
            NSLayoutConstraint.activate([
                // ... existing constraints
                
                // Replace onlineIndicator constraints with editProfileButton
                editProfileButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
                editProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
                editProfileButton.widthAnchor.constraint(equalToConstant: 28),
                editProfileButton.heightAnchor.constraint(equalToConstant: 28),
                
                // ... rest of the constraints
            ])
        }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            setupUI()
            setupLogoutButton()
            fetchUserProfile()
            loadData()
        }
    private func setupLogoutButton() {
        let logoutButton = UIBarButtonItem(title: "Logout",
                                          style: .plain,
                                          target: self,
                                          action: #selector(logoutButtonTapped))
        logoutButton.tintColor = .white
        navigationItem.rightBarButtonItem = logoutButton
    }
    @objc private func logoutButtonTapped() {
        // Create an alert to confirm logout
        let alert = UIAlertController(title: "Logout",
                                     message: "Are you sure you want to logout?",
                                     preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            // Sign out from Firebase
            do {
                try Auth.auth().signOut()
                
                // Clean up any listeners or local data
                FavoriteArtistsManager.shared.cleanupListener()
                WatchlistManager.shared.cleanupListener()
                FavoritesManager.shared.cleanupListener()
                GenreFavoritesManager.shared.cleanupListener()
                
                // Navigate to LoginViewController
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController, animated: true)
            } catch {
                self?.showAlert(message: "Failed to log out: \(error.localizedDescription)")
            }
        })
        
        present(alert, animated: true)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Clean up listener when view disappears
        FavoriteArtistsManager.shared.cleanupListener()
        WatchlistManager.shared.cleanupListener()
        FavoritesManager.shared.cleanupListener()
        GenreFavoritesManager.shared.cleanupListener()
    }
    
    private func loadData() {
        // Load all data from Firebase
        fetchFavoriteArtists { [weak self] _ in
            self?.fetchWatchlist { [weak self] _ in
                self?.fetchFavorites { [weak self] _ in
                    self?.fetchFavoriteGenres { [weak self] _ in
                        self?.updateScrollViewContentSize()
                    }
                }
            }
        }
    }
    private func fetchWatchlist(completion: @escaping ([Title]) -> Void) {
        WatchlistManager.shared.fetchWatchlistFromFirestore { [weak self] movies in
            DispatchQueue.main.async {
                self?.watchlistMovies = movies
                self?.watchlistCollectionView.reloadData()
                completion(movies)
            }
        }
    }
    private func fetchFavoriteGenres(completion: @escaping ([Genre]) -> Void) {
        GenreFavoritesManager.shared.fetchFavoriteGenresFromFirestore { [weak self] genres in
            DispatchQueue.main.async {
                self?.favoriteGenres = genres
                self?.favoriteGenresCollectionView.reloadData()
                completion(genres)
            }
        }
    }
    
    private func fetchFavorites(completion: @escaping ([Title]) -> Void) {
        FavoritesManager.shared.fetchFavoritesFromFirestore { [weak self] movies in
            DispatchQueue.main.async {
                self?.favoriteMovies = movies
                self?.favouritesCollectionView.reloadData()
                completion(movies)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewContentSize()
    }
    
    
    private func fetchUserProfile() {
           guard let userEmail = Auth.auth().currentUser?.email else {
               print("No user is currently logged in")
               return
           }
           
           db.collection("users")
               .whereField("email", isEqualTo: userEmail)
               .getDocuments { [weak self] (snapshot, error) in
                   if let error = error {
                       print("Error fetching user data: \(error)")
                       return
                   }
                   
                   guard let documents = snapshot?.documents, !documents.isEmpty else {
                       print("No user document found")
                       return
                   }
                   
                   let userData = documents[0].data()
                   self?.currentUser = UserProfile(data: userData)
                   
                   // Load profile image if available
                   if let imageURLString = userData["profileImageURL"] as? String,
                      let imageURL = URL(string: imageURLString) {
                       self?.loadProfileImage(from: imageURL)
                   }
                   
                   DispatchQueue.main.async {
                       self?.updateUI()
                   }
               }
       }
       
       private func loadProfileImage(from url: URL) {
           // Using SDWebImage to load and cache the image
           DispatchQueue.main.async { [weak self] in
               self?.profileImageView.sd_setImage(with: url) { [weak self] (image, error, _, _) in
                   if let image = image {
                       self?.profileImageView.backgroundColor = .clear
                       self?.removePhotoButton.isHidden = false
                   } else if let error = error {
                       print("Error loading profile image: \(error.localizedDescription)")
                   }
               }
           }
       }
    
    private func fetchFavoriteArtists(completion: @escaping ([Artist]) -> Void) {
        FavoriteArtistsManager.shared.fetchFavoriteArtistsFromFirestore { [weak self] artists in
            DispatchQueue.main.async {
                self?.favoriteArtists = artists
                self?.favoriteArtistsCollectionView.reloadData()
                completion(artists)
            }
        }
    }
    
    private func loadWatchlist() {
        watchlistMovies = WatchlistManager.shared.getWatchlist()
        print("Watch List Loaded: ", watchlistMovies)
        watchlistCollectionView.reloadData()
    }
    
    private func loadFavorites() {
        favoriteMovies = FavoritesManager.shared.getFavorites()
        print("fav movie Loaded: ", favoriteMovies)
        favouritesCollectionView.reloadData()
    }
    
    private func updateUI() {
        guard let user = currentUser else { return }
        nameLabel.text = user.fullName
        roleLabel.text = user.role
        updateInfoLabels(fullName: user.fullName, email: user.email)
        //updateInfoLabels(fullName: user.fullName, email: user.email, phone: user.phoneNumber)
    }
    
    private func updateInfoLabels(fullName: String, email: String) {
   // private func updateInfoLabels(fullName: String, email: String, phone: String) {
        if let usernameStack = contentView.subviews.first(where: { ($0 as? UIStackView)?.arrangedSubviews.last?.accessibilityIdentifier == "usernameLabel" }) as? UIStackView,
           let usernameLabel = usernameStack.arrangedSubviews.last as? UILabel {
            usernameLabel.text = fullName
        }
        
        if let emailStack = contentView.subviews.first(where: { ($0 as? UIStackView)?.arrangedSubviews.last?.accessibilityIdentifier == "emailLabel" }) as? UIStackView,
           let emailLabel = emailStack.arrangedSubviews.last as? UILabel {
            emailLabel.text = email
        }
    }
 
    private func setupUI() {
        // Add scroll view to main view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup scroll view constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // This will be updated after adding all subviews
        ])
        
        // Add all UI elements to the content view
        contentView.addSubview(profileImageView)
        contentView.addSubview(removePhotoButton)
//        contentView.addSubview(onlineIndicator)
        contentView.addSubview(editProfileButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)
        
        let usernameLabel = createInfoLabel(icon: "person.circle", text: "", identifier: "usernameLabel")
        let emailLabel = createInfoLabel(icon: "envelope.circle", text: "", identifier: "emailLabel")
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(emailLabel)
        
        let watchlistLabel = createSectionHeader(title: "Watchlist")
        contentView.addSubview(watchlistLabel)
        
        watchlistCollectionView = createCollectionView()
        contentView.addSubview(watchlistCollectionView)
        
        let favouritesLabel = createSectionHeader(title: "My Favourites")
        contentView.addSubview(favouritesLabel)
        
        favouritesCollectionView = createCollectionView()
        contentView.addSubview(favouritesCollectionView)
        
        let favoriteArtistsLabel = createSectionHeader(title: "My Favorite Artists")
        contentView.addSubview(favoriteArtistsLabel)
        
        let modifyButton = UIButton(type: .system)
        modifyButton.setTitle("Modify", for: .normal)
        modifyButton.setTitleColor(.systemBlue, for: .normal)
        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
        modifyButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(modifyButton)
        
        favoriteArtistsCollectionView = createCollectionView()
        contentView.addSubview(favoriteArtistsCollectionView)
        
        let favoriteGenresLabel = createSectionHeader(title: "My Favorite Genres")
            contentView.addSubview(favoriteGenresLabel)
            
            let modifyGenresButton = UIButton(type: .system)
            modifyGenresButton.setTitle("Modify", for: .normal)
            modifyGenresButton.setTitleColor(.systemBlue, for: .normal)
            modifyGenresButton.addTarget(self, action: #selector(modifyGenresButtonTapped), for: .touchUpInside)
            modifyGenresButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(modifyGenresButton)
            
            favoriteGenresCollectionView = createCollectionView()
            contentView.addSubview(favoriteGenresCollectionView)
            
            favoriteArtistsCollectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: "WatchlistCell")
            favoriteGenresCollectionView.register(GenreCell.self, forCellWithReuseIdentifier: "GenreCell")
        
        setupConstraints(
            usernameLabel: usernameLabel,
            emailLabel: emailLabel,
            watchlistLabel: watchlistLabel,
            favouritesLabel: favouritesLabel,
            favoriteArtistsLabel: favoriteArtistsLabel,
            modifyButton: modifyButton,
            favoriteGenresLabel: favoriteGenresLabel,
            modifyGenresButton: modifyGenresButton
        )
    }
    @objc private func modifyGenresButtonTapped() {
        // Navigate to the genre selection view controller
        let genreSelectionVC = MovieGenreSelectionViewController()
        navigationController?.pushViewController(genreSelectionVC, animated: true)
    }
    /*
    @objc private func profileImageTapped() {
            let actionSheet = UIAlertController(title: "Profile Picture",
                                              message: "Choose an option",
                                              preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            }))
            
            if profileImageView.image != nil && profileImageView.backgroundColor == .clear {
                actionSheet.addAction(UIAlertAction(title: "Remove Photo", style: .destructive, handler: { [weak self] _ in
                    self?.removeProfilePhoto()
                }))
            }
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(actionSheet, animated: true)
        }*/
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                showAlert(message: "This source type is not available on your device")
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
        
        @objc private func removePhotoButtonTapped() {
            removeProfilePhoto()
        }
        
        private func removeProfilePhoto() {
            let alert = UIAlertController(title: "Remove Profile Photo",
                                         message: "Are you sure you want to remove your profile photo?",
                                         preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                self?.deleteProfileImageFromStorage()
                self?.profileImageView.image = nil
                self?.profileImageView.backgroundColor = UIColor.darkGray
                self?.removePhotoButton.isHidden = true
            })
            
            present(alert, animated: true)
        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
            
            // Update UI immediately
            profileImageView.backgroundColor = .clear
            profileImageView.image = image
            removePhotoButton.isHidden = false
            
            // Upload to Firebase Storage
            uploadProfileImage(image: image, userId: userId)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    
    
    
    private func uploadProfileImage(image: UIImage, userId: String) {
            guard let imageData = image.jpegData(compressionQuality: 0.75) else {
                showAlert(message: "Could not prepare image for upload")
                return
            }
            
            // Show loading indicator or some UI feedback
            
            let imageRef = storage.child("profile_images/\(userId).jpg")
            
            imageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
                guard metadata != nil else {
                    self?.showAlert(message: "Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Get download URL
                imageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        self?.showAlert(message: "Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Update user profile in Firestore
                    self?.updateUserProfileImage(imageURL: downloadURL.absoluteString)
                }
            }
        }
        
        private func deleteProfileImageFromStorage() {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let imageRef = storage.child("profile_images/\(userId).jpg")
            
            imageRef.delete { [weak self] error in
                if let error = error {
                    print("Error deleting profile image: \(error.localizedDescription)")
                }
                
                // Update user profile in Firestore to remove image URL
                self?.updateUserProfileImage(imageURL: nil)
            }
        }
        
        private func updateUserProfileImage(imageURL: String?) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "")
                .getDocuments { [weak self] (snapshot, error) in
                    if let error = error {
                        self?.showAlert(message: "Error finding user: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        self?.showAlert(message: "User document not found")
                        return
                    }
                    
                    let userDocRef = documents[0].reference
                    
                    userDocRef.updateData(["profileImageURL": imageURL as Any]) { error in
                        if let error = error {
                            self?.showAlert(message: "Error updating profile: \(error.localizedDescription)")
                        }
                    }
                }
        }
        
    
    @objc private func modifyButtonTapped() {
        // Navigate to the artist selection view controller
        let artistSelectionVC = ArtistSelectionViewController()
        navigationController?.pushViewController(artistSelectionVC, animated: true)
    }
    
    private func createInfoLabel(icon: String, text: String, identifier: String) -> UIStackView {
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.accessibilityIdentifier = identifier
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    private func createSectionHeader(title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 120, height: 160)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: "WatchlistCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    
    private func setupConstraints(
        usernameLabel: UIStackView,
       // contactLabel: UIStackView,
        emailLabel: UIStackView,
        watchlistLabel: UILabel,
        favouritesLabel: UILabel,
        favoriteArtistsLabel: UILabel,
        modifyButton: UIButton,
        favoriteGenresLabel: UILabel,
            modifyGenresButton: UIButton
    ) {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 165),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            
            removePhotoButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
                       removePhotoButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 0),
                       removePhotoButton.widthAnchor.constraint(equalToConstant: 24),
                       removePhotoButton.heightAnchor.constraint(equalToConstant: 24),
            
//            onlineIndicator.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
//            onlineIndicator.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
//            onlineIndicator.widthAnchor.constraint(equalToConstant: 14),
//            onlineIndicator.heightAnchor.constraint(equalToConstant: 14),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 145),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 150),
            
            usernameLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 30),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            watchlistLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            watchlistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            watchlistCollectionView.topAnchor.constraint(equalTo: watchlistLabel.bottomAnchor, constant: 8),
            watchlistCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            watchlistCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            watchlistCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            favouritesLabel.topAnchor.constraint(equalTo: watchlistCollectionView.bottomAnchor, constant: 16),
            favouritesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            favouritesCollectionView.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor, constant: 8),
            favouritesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            favouritesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favouritesCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            favoriteArtistsLabel.topAnchor.constraint(equalTo: favouritesCollectionView.bottomAnchor, constant: 16),
            favoriteArtistsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            modifyButton.centerYAnchor.constraint(equalTo: favoriteArtistsLabel.centerYAnchor),
            modifyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            favoriteArtistsCollectionView.topAnchor.constraint(equalTo: favoriteArtistsLabel.bottomAnchor, constant: 8),
            favoriteArtistsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            favoriteArtistsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteArtistsCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            favoriteGenresLabel.topAnchor.constraint(equalTo: favoriteArtistsCollectionView.bottomAnchor, constant: 16),
                    favoriteGenresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    
                    modifyGenresButton.centerYAnchor.constraint(equalTo: favoriteGenresLabel.centerYAnchor),
                    modifyGenresButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                    
                    favoriteGenresCollectionView.topAnchor.constraint(equalTo: favoriteGenresLabel.bottomAnchor, constant: 8),
                    favoriteGenresCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    favoriteGenresCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                    favoriteGenresCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            
            
            contentView.bottomAnchor.constraint(equalTo: favoriteGenresCollectionView.bottomAnchor, constant: 32)
        ])
        
    }
    private func updateScrollViewContentSize() {
        view.layoutIfNeeded()
        
        let bottomPadding: CGFloat = 32
        if let lastView = favoriteGenresCollectionView {
            scrollView.contentSize = CGSize(
                width: scrollView.frame.width,
                height: lastView.frame.maxY + bottomPadding
            )
        }
    }
    
    
    
    // MARK: - UICollectionView DataSource
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == watchlistCollectionView {
            return watchlistMovies.count
        } else if collectionView == favouritesCollectionView {
            return favoriteMovies.count
        } else if collectionView == favoriteArtistsCollectionView {
            return favoriteArtists.count
        } else {
            return favoriteGenres.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == watchlistCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
            let movie = watchlistMovies[indexPath.item]
            cell.configureMovieCell(movie: movie, index: indexPath.item, isWatchlist: true, delegate: self)
            return cell
        } else if collectionView == favouritesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
            let movie = favoriteMovies[indexPath.item]
            cell.configureMovieCell(movie: movie, index: indexPath.item, isWatchlist: false, delegate: self)
            return cell
        } else if collectionView == favoriteArtistsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
            let artist = favoriteArtists[indexPath.item]
            cell.configureArtistCell(artist: artist, index: indexPath.item, delegate: self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as! GenreCell
            let genre = favoriteGenres[indexPath.item]
            cell.configure(genre: genre, index: indexPath.item, delegate: self)
            return cell
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == favoriteGenresCollectionView {
            // For genres, we'll make the cells appropriately sized for the genre name
            let genre = favoriteGenres[indexPath.item]
            let width = min(max(genre.name.size(withAttributes: [.font: UIFont.systemFont(ofSize: 12)]).width + 40, 80), 160)
            return CGSize(width: width, height: 40)
        } else {
            // For other collection views, use the default size
            return CGSize(width: 120, height: 160)
        }
    }
    
    
    class GenreCell: UICollectionViewCell {
        private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            view.layer.cornerRadius = 8
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let nameLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textAlignment = .center
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private var removeButton: UIButton?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            contentView.addSubview(containerView)
            containerView.addSubview(nameLabel)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                
                nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
            ])
        }
        
        func configure(genre: Genre, index: Int, delegate: GenreCellDelegate) {
            nameLabel.text = genre.name
            configureRemoveButton(index: index, delegate: delegate)
        }
        
        private func configureRemoveButton(index: Int, delegate: GenreCellDelegate) {
            // Remove existing button if it exists
            removeButton?.removeFromSuperview()
            removeButton = nil
            
            // Create a new remove button
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 10
            button.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                button.widthAnchor.constraint(equalToConstant: 22),
                button.heightAnchor.constraint(equalToConstant: 22)
            ])
            
            button.tag = index
            button.addTarget(delegate, action: #selector(GenreCellDelegate.removeGenre(_:)), for: .touchUpInside)
            
            removeButton = button
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            removeButton?.removeFromSuperview()
            removeButton = nil
            nameLabel.text = ""
        }
    }
    
    
    class WatchlistCell: UICollectionViewCell {
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let nameLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private var removeButton: UIButton?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            contentView.addSubview(imageView)
            contentView.addSubview(nameLabel)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
                
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
            ])
        }
        
        func configureMovieCell(movie: Title, index: Int, isWatchlist: Bool, delegate: MediaCellDelegate) {
                if let posterPath = movie.poster_path {
                    let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
                    imageView.sd_setImage(with: posterURL, placeholderImage: UIImage(systemName: "film"))
                } else {
                    imageView.image = UIImage(systemName: "film")
                }
                
                // Set the movie title
                nameLabel.text = movie.original_title ?? movie.original_name
                
                // Configure the remove button with the appropriate action based on collection type
                configureRemoveButton(index: index, isWatchlist: isWatchlist, delegate: delegate)
            }
        
        func configureArtistCell(artist: Artist, index: Int, delegate: ArtistCellDelegate) {
            if let profilePath = artist.profilePath {
                let profileURL = URL(string: "https://image.tmdb.org/t/p/w500\(profilePath)")
                imageView.sd_setImage(with: profileURL, placeholderImage: UIImage(systemName: "person.fill"))
            } else {
                imageView.image = UIImage(systemName: "person.fill")
            }
            
            // Set the artist name
            nameLabel.text = artist.name
            
            // Configure the remove button
            configureRemoveButton(index: index, isArtist: true, delegate: delegate)
        }
        
        private func configureRemoveButton(index: Int, isWatchlist: Bool = false, isArtist: Bool = false, delegate: AnyObject?) {
                // Remove existing button if it exists
                removeButton?.removeFromSuperview()
                removeButton = nil
                
                // Create a new remove button
                let button = UIButton(type: .system)
                button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                button.tintColor = .white
                button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                button.layer.cornerRadius = 10
                button.translatesAutoresizingMaskIntoConstraints = false
                
                contentView.addSubview(button)
                
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                    button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                    button.widthAnchor.constraint(equalToConstant: 22),
                    button.heightAnchor.constraint(equalToConstant: 22)
                ])
                
                button.tag = index
                
                // Set the target action based on the type
                if isArtist, let delegate = delegate as? ArtistCellDelegate {
                    button.addTarget(delegate, action: #selector(ArtistCellDelegate.removeArtist(_:)), for: .touchUpInside)
                } else if let delegate = delegate as? MediaCellDelegate {
                    if isWatchlist {
                        button.addTarget(delegate, action: #selector(MediaCellDelegate.removeFromWatchlist(_:)), for: .touchUpInside)
                    } else {
                        button.addTarget(delegate, action: #selector(MediaCellDelegate.removeFromFavorites(_:)), for: .touchUpInside)
                    }
                }
                
                removeButton = button
            }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            // Clear the remove button and its target action
            removeButton?.removeFromSuperview()
            removeButton = nil
            nameLabel.text = ""
        }
    }
    
}





























