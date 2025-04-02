
import UIKit
import CoreData

extension PersistenceController{
    
    func addMovieToWatchlist(title: String){
        let movie = Watchlist(context: context)
        movie.movieTitle = title
        movie.id = UUID()
        
        saveContext()
        print("Added movie \(title) to yout watchlist...")
    }
    
    func fetchMoviesFromWatchlist() -> [Watchlist]{
        let fetchRequest: NSFetchRequest<Watchlist> = Watchlist.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetching error: \(error)")
        }
    }
    
}
