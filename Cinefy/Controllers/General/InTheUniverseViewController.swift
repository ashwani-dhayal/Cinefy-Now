import UIKit

class InTheUniverseViewController: UIViewController {
    
    // MARK: - Properties
    private var movieTitle: String
    private var universeTitles: [String] = []
    private var universeMovies: [Title] = []
    private let spinner = UIActivityIndicatorView(style: .large)
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24 // Increased spacing to accommodate title and year
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        collectionView.register(EnhancedTitleCollectionViewCell.self, forCellWithReuseIdentifier: "EnhancedTitleCollectionViewCell")
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No universe movies found"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "film.stack")
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    // MARK: - Init
    init(movieTitle: String) {
        self.movieTitle = movieTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        setupCollectionView()
        fetchMoviesInSameUniverse()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .black
        
        // Add spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        // Add title and subtitle
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        // Add collection view
        view.addSubview(collectionView)
        
        // Setup empty state view
        emptyStateView.addSubview(emptyStateImage)
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(emptyStateView)
        
        // Title label
        titleLabel.text = "\"\(movieTitle)\" Universe"
        
        // Subtitle label
        subtitleLabel.text = "Movies in the same cinematic universe"
        
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle label constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Collection view constraints
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Spinner constraints
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty state view constraints
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            // Empty state image constraints
            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImage.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImage.heightAnchor.constraint(equalToConstant: 80),
            
            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Cinematic Universe"
        
        // Add a back button
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Data Fetching
    private func fetchMoviesInSameUniverse() {
        spinner.startAnimating()
        
        // First, get movie titles in the same universe from Gemini
        GeminiAPIManager.shared.fetchMoviesInSameUniverse(movieTitle: movieTitle) { [weak self] movieTitles in
            guard let self = self, let movieTitles = movieTitles, !movieTitles.isEmpty else {
                DispatchQueue.main.async {
                    self?.handleEmptyState()
                }
                return
            }
            
            self.universeTitles = movieTitles
            
            // Create a dispatch group to manage multiple API requests
            let dispatchGroup = DispatchGroup()
            var allMovies: [Title] = []
            
            // Loop through each movie title and fetch details from TMDB
            for title in movieTitles {
                dispatchGroup.enter()
                
                APICaller.shared.search(with: title) { result in
                    defer { dispatchGroup.leave() }
                    
                    switch result {
                    case .success(let titles):
                        if let firstMovie = titles.first {
                            allMovies.append(firstMovie)
                        }
                    case .failure(let error):
                        print("Failed to fetch movie \(title): \(error.localizedDescription)")
                    }
                }
            }
            
            // When all requests complete, update UI
            dispatchGroup.notify(queue: .main) {
                // Sort movies based on the order of titles from the API response
                self.universeMovies = self.sortMoviesInChronologicalOrder(movies: allMovies)
                
                if self.universeMovies.isEmpty {
                    self.handleEmptyState()
                } else {
                    self.updateUI()
                }
            }
        }
    }
    
    private func sortMoviesInChronologicalOrder(movies: [Title]) -> [Title] {
        // Create a dictionary to match movie titles with their index in the API response
        let titleOrderDict = Dictionary(uniqueKeysWithValues: universeTitles.enumerated().map { ($0.element, $0.offset) })
        
        // Sort movies according to the order in universeTitles
        return movies.sorted { (movie1, movie2) -> Bool in
            let title1 = movie1.original_title ?? movie1.original_name ?? ""
            let title2 = movie2.original_title ?? movie2.original_name ?? ""
            
            let index1 = titleOrderDict[title1] ?? Int.max
            let index2 = titleOrderDict[title2] ?? Int.max
            
            return index1 < index2
        }
    }
    
    private func updateUI() {
        spinner.stopAnimating()
        emptyStateView.isHidden = true
        collectionView.reloadData()
        
        // Update subtitle with count
        subtitleLabel.text = "Found \(universeMovies.count) movies in this universe"
    }
    
    private func handleEmptyState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.spinner.stopAnimating()
            self.emptyStateView.isHidden = false
            self.emptyStateLabel.text = "No movies found in the \"\(self.movieTitle)\" universe"
        }
    }
}

// MARK: - UICollectionViewDataSource
extension InTheUniverseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return universeMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnhancedTitleCollectionViewCell", for: indexPath) as? EnhancedTitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movie = universeMovies[indexPath.item]
        let title = movie.original_title ?? movie.original_name ?? "Unknown"
        let year = extractReleaseYear(from: movie.release_date ?? "")
        
        if let posterPath = movie.poster_path {
            let urlString = "https://image.tmdb.org/t/p/w500/\(posterPath)"
            cell.configure(with: urlString, title: title, year: year)
        } else {
            cell.configure(with: nil, title: title, year: year)
        }
        
        return cell
    }
    
    private func extractReleaseYear(from dateString: String) -> String {
        // Date format is expected to be "YYYY-MM-DD"
        let components = dateString.split(separator: "-")
        if !components.isEmpty, let year = components.first {
            return String(year)
        }
        return "Unknown"
    }
}

// MARK: - UICollectionViewDelegate
extension InTheUniverseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let movie = universeMovies[indexPath.item]
        
        // Fetch the YouTube trailer for the selected movie
        APICaller.shared.getMovie(with: movie.original_title! + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                // Create the TitlePreviewViewModel
                let viewModel = TitlePreviewViewModel(
                    title: movie.original_title!,
                    youtubeView: videoElement,
                    titleOverview: movie.overview!
                )
                
                DispatchQueue.main.async {
                    let detailVC = TitlePreviewViewController()
                    detailVC.configure(with: viewModel, title: movie) // Pass the Title object
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                }
                
            case .failure(let error):
                print("Failed to get movie trailer: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension InTheUniverseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: width * 1.8) // Increased height to accommodate title and year
    }
}

// MARK: - Enhanced Cell with Title and Year Labels
class EnhancedTitleCollectionViewCell: UICollectionViewCell {
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "film")
        imageView.tintColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        // Add placeholder view for when image is nil
        contentView.addSubview(placeholderView)
        placeholderView.addSubview(placeholderIcon)
        
        // Add the image view and labels
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        
        NSLayoutConstraint.activate([
            // Placeholder constraints
            placeholderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeholderView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            placeholderIcon.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderIcon.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            placeholderIcon.widthAnchor.constraint(equalToConstant: 40),
            placeholderIcon.heightAnchor.constraint(equalToConstant: 40),
            
            // Poster image constraints
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            // Year label constraints
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            yearLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with urlString: String?, title: String, year: String) {
        titleLabel.text = title
        yearLabel.text = year
        
        if let urlString = urlString, let url = URL(string: urlString) {
            // Use URLSession to download the image
            placeholderView.isHidden = false
            posterImageView.isHidden = true
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.posterImageView.image = image
                        self.posterImageView.isHidden = false
                        self.placeholderView.isHidden = true
                    }
                }
            }.resume()
        } else {
            // No image URL, show placeholder
            posterImageView.image = nil
            posterImageView.isHidden = true
            placeholderView.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        yearLabel.text = nil
    }
}
