import UIKit
import FirebaseFirestore

// MARK: - Enums
enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTv = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
    case BestForYou = 5
    static let baseSectionsCount = 6
}

// MARK: - HomeViewController
class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var favoriteArtists: [Artist] = []
    private var favoriteGenres: [Genre] = []
    private var artistMovies: [Int: [Title]] = [:]
    private var favoriteGenreMovies: [Int: [Title]] = [:]
    private var intersectionMovies: [Title] = []
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    private var sectionTitles: [String] = []
    
   // private var genreFavoritesListener: Any?
    private var artistFavoritesListener: Any?
    private var genreFavoritesListener: Any?
    
    // MARK: - UI Components
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.backgroundColor = .black
        return table
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTableView()
        configureNavbar()
        setupHeaderView()
        configureSelectedContent()
       // fetchFavoriteGenres()
        fetchFavoriteArtists()
        fetchFavoriteGenres()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  fetchFavoriteGenres()
        fetchFavoriteArtists()
        fetchFavoriteGenres()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // GenreFavoritesManager.shared.cleanupListener()
        FavoriteArtistsManager.shared.cleanupListener()
        GenreFavoritesManager.shared.cleanupListener()
    }
}

// MARK: - UI Setup
extension HomeViewController {
    private func configureUI() {
        view.backgroundColor = .black
        view.addSubview(homeFeedTable)
    }
    
    private func setupTableView() {
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
    }
    
    private func configureNavbar() {
        let titleLabel = UILabel()
        let welcomeText = "Welcome to "
        let cinefyText = "Cinefy"
        let fullText = welcomeText + cinefyText
        let attributedText = NSMutableAttributedString(string: fullText)
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: welcomeText.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: welcomeText.count, length: 1))
        attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: welcomeText.count + 1, length: cinefyText.count - 1))
        
        titleLabel.attributedText = attributedText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupHeaderView() {
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
        configureHeroHeaderView()
    }
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result {
            case .success(let titles):
                let selectedTitle = titles.randomElement()
                self?.randomTrendingMovie = selectedTitle
                
                let releaseYear = selectedTitle?.release_date?.prefix(4) ?? "N/A"
                let movieType = selectedTitle?.media_type == "movie" ? "Movie" : "TV Show"
                
                self?.headerView?.configure(with: TitleViewModel(
                    titleName: selectedTitle?.original_title ?? "",
                    posterURL: selectedTitle?.poster_path ?? "",
                    releaseYear: String(releaseYear),
                    overview: selectedTitle?.overview ?? "",
                    movieType: movieType
                ))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Content Management
extension HomeViewController {
    private func configureSelectedContent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchIntersectionMovies()
        }
    }
    
    private func fetchFavoriteArtists() {
        FavoriteArtistsManager.shared.fetchFavoriteArtistsFromFirestore { [weak self] artists in
            self?.favoriteArtists = artists
            DispatchQueue.main.async {
                self?.updateSectionTitles()
                self?.fetchMoviesForArtists()
                self?.fetchIntersectionMovies()
            }
        }
    }
    
    private func fetchFavoriteGenres() {
        GenreFavoritesManager.shared.fetchFavoriteGenresFromFirestore { [weak self] genres in
            self?.favoriteGenres = genres
            DispatchQueue.main.async {
                self?.updateSectionTitles()
                self?.fetchMoviesForFavoriteGenres()
            }
        }
    }
    
    private func updateSectionTitles() {
        var newSectionTitles: [String] = []
        
      
        
        // ✅ Add artists next
        favoriteArtists.forEach { artist in
            newSectionTitles.append("Movies from \(artist.name)")
        }
        
        // ✅ Add genres first
        favoriteGenres.forEach { genre in
            newSectionTitles.append("\(genre.name) Movies")
        }
        
        // ✅ Add base sections at the end
        newSectionTitles.append(contentsOf: [
            "Best For You",
            "Trending Movies",
            "Trending Tv",
            "Popular",
            "Upcoming Movies",
            "Top rated"
        ])
        
        sectionTitles = newSectionTitles
        homeFeedTable.reloadData()
    }
    
    // ✅ Fixed missing methods
    private func fetchIntersectionMovies() {
        intersectionMovies = [] // Clear existing data
        intersectionMovies = artistMovies.values.flatMap { $0 }
        homeFeedTable.reloadData()
    }
    
    private func fetchMoviesForArtists() {
        favoriteArtists.forEach { artist in
            APICaller.shared.getMoviesForArtist(with: artist.id) { [weak self] result in
                switch result {
                case .success(let titles):
                    self?.artistMovies[artist.id] = titles
                    self?.homeFeedTable.reloadData()
                case .failure(let error):
                    print("Failed to fetch movies for artist \(artist.name): \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchMoviesForFavoriteGenres() {
        favoriteGenres.forEach { genre in
            APICaller.shared.getMoviesForGenre(with: genre.id) { [weak self] result in
                switch result {
                case .success(let titles):
                    self?.favoriteGenreMovies[genre.id] = titles
                    self?.homeFeedTable.reloadData()
                case .failure(let error):
                    print("Failed to fetch movies for genre \(genre.name): \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    // ✅ Number of sections based on sectionTitles count
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // ✅ Number of rows per section (always 1 since it's a horizontal scroll section)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // ✅ Cell for row at indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.backgroundColor = .black
        
        
        if indexPath.section < favoriteArtists.count {
            // 🎯 Genre Sections
            let artist = favoriteArtists[indexPath.section]
            if let movies = artistMovies[artist.id] {
                cell.configure(with: movies)
            }
        } else if indexPath.section < favoriteGenres.count + favoriteArtists.count {
            // 🎯 Artist Sections
            let genreIndex = indexPath.section - favoriteArtists.count
            let genre = favoriteGenreMovies[genreIndex]
      
        } else {
            // 🎯 Base Sections
            let baseSectionIndex = indexPath.section - (favoriteGenres.count + favoriteArtists.count)
            switch baseSectionIndex {
            case Sections.BestForYou.rawValue:
                cell.configure(with: intersectionMovies)
            case Sections.TrendingMovies.rawValue:
                APICaller.shared.getTrendingMovies { result in
                    switch result {
                    case .success(let titles):
                        cell.configure(with: titles)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case Sections.TrendingTv.rawValue:
                APICaller.shared.getTrendingTvs { result in
                    switch result {
                    case .success(let titles):
                        cell.configure(with: titles)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case Sections.Popular.rawValue:
                APICaller.shared.getPopular { result in
                    switch result {
                    case .success(let titles):
                        cell.configure(with: titles)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case Sections.Upcoming.rawValue:
                APICaller.shared.getUpcomingMovies { result in
                    switch result {
                    case .success(let titles):
                        cell.configure(with: titles)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case Sections.TopRated.rawValue:
                APICaller.shared.getTopRated { result in
                    switch result {
                    case .success(let titles):
                        cell.configure(with: titles)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            default:
                break
            }
        }
        
        return cell
    }
    
    // ✅ Title for section header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    // ✅ Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // ✅ Height for section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // ✅ Header styling
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .white
        header.tintColor = .black
    }
    
    // ✅ Smooth scrolling and navbar adjustment
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}


// MARK: - CollectionViewTableViewCellDelegate
extension HomeViewController: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel, title: Title) {
        let vc = TitlePreviewViewController()
        vc.configure(with: viewModel, title: title)
        navigationController?.pushViewController(vc, animated: true)
    }
}

















