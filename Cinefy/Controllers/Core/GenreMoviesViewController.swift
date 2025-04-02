import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

// MARK: - MoviePosterCell
class MoviePosterCell: UICollectionViewCell {
    static let identifier = "MoviePosterCell"
    
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        layer.locations = [0.6, 1.0]
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        contentView.layer.addSublayer(gradientLayer)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: ratingLabel.topAnchor, constant: -4),
            
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            ratingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
    
    func configure(with movie: Title) {
        titleLabel.text = movie.original_title
        
        // Fix: Remove optional binding for vote_average since it's not optional
        let rating = movie.vote_average
        ratingLabel.text = "★ \(String(format: "%.1f", rating))"
        
        if let posterPath = movie.poster_path {
            let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            posterImageView.sd_setImage(
                with: posterURL,
                placeholderImage: UIImage(systemName: "film"),
                options: .continueInBackground,
                completed: nil
            )
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.tintColor = .gray
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
    }
}


// MARK: - GenreMovieViewController
class GenreMovieViewController: UIViewController {
    
    
    private var genreName: String
    private var genreId: Int
    private var movies: [Title] = []
    private var searchResults: [Title] = []
    private var isSearching: Bool = false
    private let db = Firestore.firestore()
    
    // Polling Data
    private var pollingMovies: [Title] = []
    private var pollingResults: [Int: Int] = [:]
    private var votedPairs: Set<Set<Int>> = []
    private var currentPollId = UUID()
    
    // MARK: - UI Components
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No movies found"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search movies"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        searchBar.barTintColor = UIColor(white: 0.2, alpha: 1.0)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
            
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search movies",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
            
            if let leftView = textField.leftView as? UIImageView {
                leftView.tintColor = .gray
            }
        }
        
        searchBar.delegate = self
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let pollingSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Vote for Your Favorite"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let pollingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializer
    init(genreName: String, genreId: Int) {
        self.genreName = genreName
        self.genreId = genreId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMoviesByGenre()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        // Configure navigation bar
        navigationItem.title = genreName
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(pollingSectionLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(pollingStackView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        // Set up collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: MoviePosterCell.identifier)
        
        // Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            pollingSectionLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            pollingSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pollingSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: pollingSectionLabel.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            pollingStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            pollingStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            pollingStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            pollingStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            pollingStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    private func fetchMoviesByGenre() {
        loadingIndicator.startAnimating()
        
        let urlString = "\(Constants.baseURL)/3/discover/movie?api_key=\(Constants.API_KEY)&with_genres=\(genreId)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            if let error = error {
                print("Error fetching movies: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.movies = results.results
                    self.emptyStateLabel.isHidden = !self.movies.isEmpty
                    self.collectionView.reloadData()
                    self.setupPolling()
                }
            } catch {
                print("Error decoding: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: - Polling Setup
    private func setupPolling() {
        guard movies.count >= 2 else { return }
        selectNewPollingMovies()
    }
    
    private func selectNewPollingMovies() {
        var availableMovies = movies
        var selectedPair: [Title] = []
        
        while selectedPair.count < 2 && availableMovies.count >= 2 {
            let shuffledMovies = availableMovies.shuffled()
            let potentialPair = Array(shuffledMovies.prefix(2))
            let pairSet = Set([potentialPair[0].id, potentialPair[1].id])
            
            if !votedPairs.contains(pairSet) {
                selectedPair = potentialPair
                break
            }
            
            availableMovies.removeAll { $0.id == potentialPair[0].id }
        }
        
        if selectedPair.count < 2 {
            votedPairs.removeAll()
            selectedPair = Array(movies.shuffled().prefix(2))
        }
        
        pollingMovies = selectedPair
        currentPollId = UUID()
        updatePollingUI()
    }
    
    private func updatePollingUI() {
        pollingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for movie in pollingMovies {
            let pollView = createPollView(for: movie)
            pollingStackView.addArrangedSubview(pollView)
        }
    }
    private func updateVoteCountInFirestore(movie: Title) {
        let movieRef = db.collection("movieVotes").document("\(movie.id)")
        
        // Use a transaction to safely update the vote count
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let movieDocument = try transaction.getDocument(movieRef)
                
                // Get current vote count or initialize to 0 if document doesn't exist
                let currentVotes = movieDocument.exists ? (movieDocument.data()?["voteCount"] as? Int ?? 0) : 0
                
                // Update the document
                if movieDocument.exists {
                    transaction.updateData(["voteCount": currentVotes + 1], forDocument: movieRef)
                } else {
                    let newData: [String: Any] = [
                        "movieId": movie.id,
                        "movieTitle": movie.original_title ?? "Unknown title",
                        "voteCount": 1,
                        "lastVoted": FieldValue.serverTimestamp()
                    ]
                    transaction.setData(newData, forDocument: movieRef)
                }
                
                return nil
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
        }) { (object, error) in
            if let error = error {
                print("Error updating movie vote count: \(error)")
            } else {
                print("Movie vote count successfully updated")
            }
        }
    }
    private func saveVoteToFirestore(movie: Title) {
        // Get current user information if available
        let userEmail = Auth.auth().currentUser?.email ?? "anonymous@user.com"
        let userId = Auth.auth().currentUser?.uid ?? "anonymous-user"
        
        // Create a dictionary with vote data
        let voteData: [String: Any] = [
            "movieId": movie.id,
            "movieTitle": movie.original_title ?? "Unknown title",
            "genreId": self.genreId,
            "genreName": self.genreName,
            "timestamp": FieldValue.serverTimestamp(),
          //  "userId": userId,
            "userEmail": userEmail
        ]
        
        // Add the vote to the "votes" collection
        db.collection("votes").addDocument(data: voteData) { error in
            if let error = error {
                print("Error saving vote to Firestore: \(error)")
            } else {
                print("Vote successfully saved to Firestore")
                
                // Update vote count in a separate collection for aggregation
                self.updateVoteCountInFirestore(movie: movie)
            }
        }
    }
   
    
    private func createPollView(for movie: Title) -> UIView {
        let pollView = UIView()
        pollView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        pollView.layer.cornerRadius = 8
        pollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Movie Name Label
        let movieNameLabel = UILabel()
        movieNameLabel.text = movie.original_title
        movieNameLabel.textColor = .white
        movieNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        movieNameLabel.numberOfLines = 0
        movieNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Vote Count Label
        let voteCountLabel = UILabel()
        voteCountLabel.text = "Votes: \(pollingResults[movie.id] ?? 0)"
        voteCountLabel.textColor = .systemYellow
        voteCountLabel.font = .systemFont(ofSize: 14, weight: .regular)
        voteCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Vote Button
        let voteButton = UIButton(type: .system)
        voteButton.setTitle("Vote", for: .normal)
        voteButton.backgroundColor = .systemBlue
        voteButton.setTitleColor(.white, for: .normal)
        voteButton.layer.cornerRadius = 4
        voteButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        pollView.addSubview(movieNameLabel)
        pollView.addSubview(voteCountLabel)
        pollView.addSubview(voteButton)
        
        // Store movie ID and current poll ID
        voteButton.tag = movie.id
        voteButton.accessibilityIdentifier = currentPollId.uuidString
        voteButton.addTarget(self, action: #selector(handleVote(_:)), for: .touchUpInside)
        
        // Constraints
        NSLayoutConstraint.activate([
            movieNameLabel.leadingAnchor.constraint(equalTo: pollView.leadingAnchor, constant: 16),
            movieNameLabel.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -8),
            movieNameLabel.topAnchor.constraint(equalTo: pollView.topAnchor, constant: 8),
            
            voteCountLabel.leadingAnchor.constraint(equalTo: pollView.leadingAnchor, constant: 16),
            voteCountLabel.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -8),
            voteCountLabel.topAnchor.constraint(equalTo: movieNameLabel.bottomAnchor, constant: 4),
            voteCountLabel.bottomAnchor.constraint(equalTo: pollView.bottomAnchor, constant: -8),
            
            voteButton.trailingAnchor.constraint(equalTo: pollView.trailingAnchor, constant: -16),
            voteButton.centerYAnchor.constraint(equalTo: pollView.centerYAnchor),
            voteButton.widthAnchor.constraint(equalToConstant: 80),
            voteButton.heightAnchor.constraint(equalToConstant: 36),
            
            pollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        return pollView
    }
    @objc private func handleVote(_ sender: UIButton) {
        guard let pollId = sender.accessibilityIdentifier,
              pollId == currentPollId.uuidString else {
            return
        }
        
        let votedMovieId = sender.tag
        
        // Find the voted movie
        guard let votedMovie = pollingMovies.first(where: { $0.id == votedMovieId }) else {
            return
        }
        
        // Record this pair as voted
        let currentPairSet = Set(pollingMovies.map { $0.id })
        votedPairs.insert(currentPairSet)
        
        // Increment vote count
        pollingResults[votedMovieId] = (pollingResults[votedMovieId] ?? 0) + 1
        
        // Store vote in Firestore
        saveVoteToFirestore(movie: votedMovie)
        
        // Update the vote count label in the poll view
        for case let pollView as UIView in pollingStackView.arrangedSubviews {
            if let movieNameLabel = pollView.subviews.first(where: { $0 is UILabel }) as? UILabel,
               let voteCountLabel = pollView.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.starts(with: "Votes:") ?? false }),
               let voteButton = pollView.subviews.first(where: { $0 is UIButton }) as? UIButton,
               voteButton.tag == votedMovieId {
                voteCountLabel.text = "Votes: \(pollingResults[votedMovieId] ?? 0)"
                break
            }
        }
        
        // Show vote confirmation
        showVoteConfirmation(for: votedMovie.original_title ?? "Movie")
        
        // Select new movies after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.selectNewPollingMovies()
        }
    }
   
    
    private func showVoteConfirmation(for movieTitle: String) {
        let alert = UIAlertController(
            title: "Vote Recorded!",
            message: "You voted for '\(movieTitle)'. New movies will appear shortly.",
            preferredStyle: .alert
        )
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension GenreMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? searchResults.count : movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCell.identifier, for: indexPath) as? MoviePosterCell else {
            return UICollectionViewCell()
        }
        
        let movie = isSearching ? searchResults[indexPath.item] : movies[indexPath.item]
        cell.configure(with: movie)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
            let movie = isSearching ? searchResults[indexPath.item] : movies[indexPath.item]
            
            // Open MovieDiscussionViewController
            let discussionVC = MovieDiscussionViewController(movie: movie)
            navigationController?.pushViewController(discussionVC, animated: true)
        }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GenreMovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Landscape aspect ratio (16:9)
        let width = collectionView.bounds.width
        let height = width * 9 / 16 // Adjust the multiplier for your desired aspect ratio
        return CGSize(width: width, height: height)
    }
}

// MARK: - UISearchBarDelegate
extension GenreMovieViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            collectionView.reloadData()
        } else {
            isSearching = true
            searchResults = movies.filter {
                $0.original_title?.lowercased().contains(searchText.lowercased()) ?? false
            }
            collectionView.reloadData()
        }
        
        emptyStateLabel.isHidden = !(isSearching && searchResults.isEmpty)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}








































