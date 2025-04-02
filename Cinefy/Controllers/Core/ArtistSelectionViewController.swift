import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Model for Artist data
struct Artist: Codable {
    let id: Int
    let name: String
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
    }
}

struct ArtistResponse: Codable {
    let results: [Artist]
    let page: Int
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

class ArtistSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private var artists: [Artist] = []
    private var filteredArtists: [Artist] = []
    private var selectedArtists: Set<Int> = []
    private var currentPage = 1
    private var isSearching = false
    private var isLoadingMore = false
    private var totalPages = 1
    
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        let fullText = "Cinefy"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor.systemRed,
                                    range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor.white,
                                    range: NSRange(location: 1, length: fullText.count - 1))
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select your favourite artist"
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search artists..."
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.attributedPlaceholder = NSAttributedString(string: "Search artists...",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            textField.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        }
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(ArtistCell.self, forCellWithReuseIdentifier: "ArtistCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // Initially disabled until selection
        button.alpha = 0.6 // Visual indication that it's disabled
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        fetchPopularArtists()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(logoLabel)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(continueButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    // MARK: - Data Fetching
    private func fetchPopularArtists(page: Int = 1) {
        if page == 1 {
            activityIndicator.startAnimating()
        }
        isLoadingMore = true
        guard let url = URL(string: "\(Constants.baseURL)/3/person/popular?api_key=\(Constants.API_KEY)&language=en-US&page=\(page)") else {
            activityIndicator.stopAnimating()
            isLoadingMore = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.isLoadingMore = false
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ArtistResponse.self, from: data)
                if page == 1 {
                    self.artists = response.results
                } else {
                    self.artists.append(contentsOf: response.results)
                }
                self.totalPages = response.totalPages
                self.currentPage = page
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.isLoadingMore = false
                }
            } catch {
                print("Error decoding artist data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.isLoadingMore = false
                }
            }
        }
        task.resume()
    }
    
    private func searchArtists(query: String) {
        activityIndicator.startAnimating()
        isSearching = true
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL(string: "\(Constants.baseURL)/3/search/person?api_key=\(Constants.API_KEY)&language=en-US&query=\(encodedQuery)&page=1&include_adult=false") else {
            activityIndicator.stopAnimating()
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ArtistResponse.self, from: data)
                self.filteredArtists = response.results
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("Error searching artists: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        task.resume()
    }
    
    @objc private func continueButtonTapped() {
        saveSelectedArtists()
        // Navigate to next screen
        let movieGenreVC = MovieGenreSelectionViewController()
        movieGenreVC.modalPresentationStyle = .fullScreen
        present(movieGenreVC, animated: true)
    }
    
    private func saveSelectedArtists() {
        let selectedArtistsList = artists.filter { selectedArtists.contains($0.id) }
        
        // Save to UserDefaults
        do {
            let data = try JSONEncoder().encode(selectedArtistsList)
            UserDefaults.standard.set(data, forKey: "SelectedArtists")
        } catch {
            print("Failed to save selected artists: \(error)")
        }
        
        // Add selected artists to Firestore
        saveArtistsToFirestore(selectedArtistsList)
        
        // Also add searched artists if they're selected
        if isSearching {
            let selectedSearchArtists = filteredArtists.filter { selectedArtists.contains($0.id) }
            if !selectedSearchArtists.isEmpty {
                saveArtistsToFirestore(selectedSearchArtists)
            }
        }
        
        print("Saved \(selectedArtistsList.count) artists")
    }

    private func saveArtistsToFirestore(_ artists: [Artist]) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        
        for artist in artists {
            // Create a document in the artistFavorite collection with a unique ID
            let artistDocRef = db.collection("artistFavorite").document()
            
            // Create the data to save
            let artistData: [String: Any] = [
                "artistID": artist.id,
                "artistName": artist.name,
                "profilePath": artist.profilePath ?? "",
                "timestamp": FieldValue.serverTimestamp(),
                "userEmail": userEmail
            ]
            
            // Save the data to Firestore
            artistDocRef.setData(artistData) { error in
                if let error = error {
                    print("Error saving artist to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully saved artist \(artist.name) to Firestore")
                }
            }
        }
    }
    
    private func updateContinueButtonState() {
        let isEnabled = !selectedArtists.isEmpty
        continueButton.isEnabled = isEnabled
        continueButton.alpha = isEnabled ? 1.0 : 0.6
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ArtistSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredArtists.count : artists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! ArtistCell
        let artist = isSearching ? filteredArtists[indexPath.item] : artists[indexPath.item]
        
        // Configure with image URL instead of local image name
        let isSelected = selectedArtists.contains(artist.id)
        cell.configure(with: artist.name, profilePath: artist.profilePath, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artist = isSearching ? filteredArtists[indexPath.item] : artists[indexPath.item]
        
        // Toggle selection
        if selectedArtists.contains(artist.id) {
            selectedArtists.remove(artist.id)
        } else {
            selectedArtists.insert(artist.id)
        }
        
        // Update UI to reflect selection state
        collectionView.reloadItems(at: [indexPath])
        updateContinueButtonState()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ArtistSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}

// MARK: - UIScrollViewDelegate for pagination
extension ArtistSelectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Load more when we're 80% down the scroll view
        if offsetY > contentHeight - height * 1.2 && !isLoadingMore && !isSearching && currentPage < totalPages {
            fetchPopularArtists(page: currentPage + 1)
        }
    }
}

// MARK: - UISearchBarDelegate
extension ArtistSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            collectionView.reloadData()
        } else {
            // Debounce search requests
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch(_:)), object: searchText)
            perform(#selector(performSearch(_:)), with: searchText, afterDelay: 0.5)
        }
    }
    
    @objc private func performSearch(_ searchText: String) {
        guard !searchText.isEmpty else { return }
        searchArtists(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchArtists(query: searchText)
        }
    }
}

// MARK: - Artist Cell
class ArtistCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = (UIScreen.main.bounds.width - 56) / 4 // Make it perfectly circular
        iv.backgroundColor = .darkGray // Placeholder color
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.addSubview(overlayView)
        imageView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 50),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with title: String, profilePath: String?, isSelected: Bool) {
        titleLabel.text = title
        
        UIView.animate(withDuration: 0.2) {
            self.checkmarkImageView.isHidden = !isSelected
            self.overlayView.isHidden = !isSelected
            self.transform = isSelected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        }
        
        // Load image from URL
        if let profilePath = profilePath {
            let imageUrlString = "https://image.tmdb.org/t/p/w500\(profilePath)"
            if let imageUrl = URL(string: imageUrlString) {
                // Simple image loading - in a real app, use a proper image caching library
                URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                    guard let self = self, let data = data, error == nil,
                          let image = UIImage(data: data) else { return }
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }.resume()
            } else {
                imageView.backgroundColor = .darkGray
                imageView.image = nil
            }
        } else {
            imageView.backgroundColor = .darkGray
            imageView.image = nil
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.layer.cornerRadius = (UIScreen.main.bounds.width - 56) / 4
    }
}
