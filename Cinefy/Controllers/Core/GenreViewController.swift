import UIKit
import Foundation
import SDWebImage

class MovieSearchResultCell: UITableViewCell {
    static let identifier = "MovieSearchResultCell"
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none
        
        // Add "FEATURE FILM" tag like in your reference image
        let featureFilmLabel = UILabel()
        featureFilmLabel.text = "FEATURE FILM"
        featureFilmLabel.textColor = UIColor(red: 0.95, green: 0.7, blue: 0.1, alpha: 1.0) // Golden yellow
        featureFilmLabel.font = .systemFont(ofSize: 12, weight: .bold)
        featureFilmLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(featureFilmLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            posterImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            yearLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            featureFilmLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            featureFilmLabel.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with movie: Title) {
        titleLabel.text = movie.original_title
        
        // Extract year from release_date if available
        if let releaseDate = movie.release_date, releaseDate.count >= 4 {
            let yearSubstring = String(releaseDate.prefix(4))
            yearLabel.text = "(\(yearSubstring))"
        } else {
            yearLabel.text = "(Unknown year)"
        }
        
        if let posterPath = movie.poster_path {
            let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            posterImageView.sd_setImage(with: posterURL, placeholderImage: UIImage(systemName: "film"))
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.tintColor = .gray
        }
    }
}

// MARK: - Genre Data Source
class GenreDataSource {
    static let shared = GenreDataSource()
    
    var genres: [Genre] = []
    
    private init() {
        fetchGenresFromTMDB()
    }
    
    func fetchGenresFromTMDB() {
        let urlString = "\(Constants.baseURL)/3/genre/movie/list?api_key=\(Constants.API_KEY)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching genres: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let genreResponse = try decoder.decode(GenreResponse.self, from: data)
                
                self.genres = genreResponse.genres.map { tmdbGenre in
                    let imageName = self.getGenreImageName(for: tmdbGenre.name)
                    return Genre(id: tmdbGenre.id, name: tmdbGenre.name, image: imageName)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("GenresFetched"), object: nil)
                }
            } catch {
                print("Error decoding genres: \(error)")
            }
        }
        task.resume()
    }
    
    private func getGenreImageName(for genreName: String) -> String {
        let genreImageMapping: [String: String] = [
            "Action": "action_genre",
            "Adventure": "adv",
            "Animation": "ani",
            "Crime": "crime",
            "Comedy": "comedy_genre",
            "Documentary": "doc",
            "Drama": "drama_genre",
            "Family": "fam",
            "Fantasy": "fan",
            "History": "his",
            "Horror": "horror_genre",
            "Music": "mus",
            "Romance": "rom",
            "TV Movie": "tv",
            "Thriller": "thriller_genre",
            "Mystery": "mystery_genre",
            "Science Fiction": "scifi_genre",
            "War": "war",
            "Western": "wes",
        ]
        return genreImageMapping[genreName] ?? "genre_placeholder"
    }
}

// MARK: - TMDB Genre Response Model

// MARK: - Genre Cell
class GenreCell: UICollectionViewCell {
    static let identifier = "GenreCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        layer.cornerRadius = 16
        clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with genre: Genre) {
        titleLabel.text = genre.name
        imageView.image = UIImage(named: genre.image)
    }
    func configure(with movie: Title) {
            titleLabel.text = movie.original_title
            
            if let posterPath = movie.poster_path {
                let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
                imageView.sd_setImage(with: posterURL, placeholderImage: UIImage(systemName: "film"))
            } else {
                imageView.image = UIImage(systemName: "film")
                imageView.tintColor = .gray
            }
        }
    }
    
    
    
    
    
// MARK: - Genre View Controller
class GenreViewController: UIViewController {
    
    private var genres: [Genre] = []
    private var searchResults: [Title] = [] // To store search results
        private var isSearching = false // To track if user is searching
        
        private lazy var searchBar: UISearchBar = {
            let searchBar = UISearchBar()
            searchBar.placeholder = "Search movies..."
            searchBar.delegate = self
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            searchBar.barTintColor = .black
            searchBar.backgroundColor = .black
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                        textField.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // Dark gray
                        textField.textColor = .white
                        textField.attributedPlaceholder = NSAttributedString(
                            string: "Search movies...",
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                        )
                    }
                    
                    // Set search icon color
                    if let glassIconView = searchBar.searchTextField.leftView as? UIImageView {
                        glassIconView.tintColor = .lightGray
                    }
                    
                    // Customize clear button
                    if let clearButton = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
                        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                        clearButton.tintColor = .lightGray
                    }

            return searchBar
        }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let itemWidth = UIScreen.main.bounds.width - 32
        layout.itemSize = CGSize(width: itemWidth, height: 200)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.identifier)
        collectionView.backgroundColor = .black // Changed to black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
            let table = UITableView()
            table.register(MovieSearchResultCell.self, forCellReuseIdentifier: MovieSearchResultCell.identifier)
            table.backgroundColor = .black
            table.separatorStyle = .singleLine
            table.separatorColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark gray separator
            table.rowHeight = 136 // Height for movie cells
            table.showsVerticalScrollIndicator = false
            table.translatesAutoresizingMaskIntoConstraints = false
            table.isHidden = true // Initially hidden
            return table
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchGenres()
        
        NotificationCenter.default.addObserver(self, selector: #selector(genresFetched), name: NSNotification.Name("GenresFetched"), object: nil)
    }
    
    private func setupUI() {
        // Set view background to black
        view.backgroundColor = .black

        title = "Community"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        // Set navigation bar appearance for dark theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .black
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(tableView)
     //   collectionView.delegate = self
    //    collectionView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    private func searchMovies(query: String) {
            let urlString = "\(Constants.baseURL)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching search results: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(TitleResponse.self, from: data)
                    
                    self.searchResults = searchResponse.results
                    
                    DispatchQueue.main.async {
                        self.isSearching = true
                        self.updateSearchResultsView()
                    }
                } catch {
                    print("Error decoding search results: \(error)")
                }
            }
            task.resume()
        }
    private func updateSearchResultsView() {
            if isSearching {
                collectionView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            } else {
                collectionView.isHidden = false
                tableView.isHidden = true
                collectionView.reloadData()
            }
        }
        
    
    private func fetchGenres() {
        GenreDataSource.shared.fetchGenresFromTMDB()
    }
    
    @objc private func genresFetched() {
        DispatchQueue.main.async {
            self.genres = GenreDataSource.shared.genres
            self.collectionView.reloadData()
        }
    }
}

extension GenreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.identifier, for: indexPath) as? GenreCell else {
            return UICollectionViewCell()
        }
        
            let genre = genres[indexPath.row]
            cell.configure(with: genre)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
            let genre = genres[indexPath.row]
            let vc = GenreMovieViewController(genreName: genre.name, genreId: genre.id)
                    navigationController?.pushViewController(vc, animated: true)
            
        }
    }


extension GenreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieSearchResultCell.identifier, for: indexPath) as? MovieSearchResultCell else {
            return UITableViewCell()
        }
        
        let movie = searchResults[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = searchResults[indexPath.row]
        let vc = MovieDiscussionViewController(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension GenreViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            updateSearchResultsView()
        } else {
            searchMovies(query: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        updateSearchResultsView()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}











