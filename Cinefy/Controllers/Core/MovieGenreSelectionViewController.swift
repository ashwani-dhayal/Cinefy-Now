
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Model for Genre data
struct MovieGenre: Codable {
    let id: Int
    let name: String
}

struct MovieGenreResponse: Codable {
    let genres: [MovieGenre]
}

class MovieGenreSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private var genres: [MovieGenre] = []
    private var selectedGenres: Set<Int> = [] // Store selected genre IDs
    private var isLoadingData = false
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        // Create attributed string for "Cinefy." with red C
        let fullText = "Cinefy"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set the "C" to red
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor.systemRed,
                                    range: NSRange(location: 0, length: 1))
        
        // Set the rest to white
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
        label.text = "Select your genres"
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(MovieGenreCell.self, forCellWithReuseIdentifier: "MovieGenreCell")
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
        button.isEnabled = false
        button.alpha = 0.6
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
        fetchMovieGenres()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(logoLabel)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(continueButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
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
    
    // MARK: - Custom Genre Image Mapping
    private func getCustomImageName(for genreName: String) -> String {
        let name = genreName.lowercased()
        
        switch name {
        case "action":
            return "action_genre"
        case "adventure":
            return "adv"
        case "animation":
            return "ani"
        case "comedy":
            return "comedy_genre"
        case "crime":
            return "crime"
        case "documentary":
            return "doc"
        case "drama":
            return "drama_genre"
        case "family":
            return "fam"
        case "fantasy":
            return "fan"
        case "history":
            return "his"
        case "horror":
            return "horror_genre"
        case "music":
            return "mus"
        case "mystery":
            return "mystery_genre"
        case "romance":
            return "rom"
        case "science fiction":
            return "scifi_genre"
        case "tv movie":
            return "tv"
        case "thriller":
            return "thriller_genre"
        case "war":
            return "war"
        case "western":
            return "wes"
        default:
            return "default_genre_img"
        }
    }
    
    // MARK: - Data Fetching
    private func fetchMovieGenres() {
        activityIndicator.startAnimating()
        isLoadingData = true
        
        guard let url = URL(string: "\(Constants.baseURL)/3/genre/movie/list?api_key=\(Constants.API_KEY)&language=en-US") else {
            activityIndicator.stopAnimating()
            isLoadingData = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.isLoadingData = false
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MovieGenreResponse.self, from: data)
                self.genres = response.genres
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.isLoadingData = false
                }
            } catch {
                print("Error decoding genre data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.isLoadingData = false
                }
            }
        }
        
        task.resume()
    }
    
    @objc private func continueButtonTapped() {
        saveSelectedGenres()
        
        // Create main tab bar controller
        let tabBarController = MainTabBarViewController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
   
    private func saveSelectedGenres() {
        let selectedGenresList = genres.filter { selectedGenres.contains($0.id) }
        
        do {
            let data = try JSONEncoder().encode(selectedGenresList)
            UserDefaults.standard.set(data, forKey: "SelectedGenres")
        } catch {
            print("Failed to save selected genres: \(error)")
        }
        saveGenresToFirestore(selectedGenresList)
    }
    
    private func saveGenresToFirestore(_ genres: [MovieGenre]) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        
        for genre in genres {
            // Create a document in the genreFav collection with a unique ID
            let genreDocRef = db.collection("genreFav").document()
            
            // Create the data to save
            let genreData: [String: Any] = [
                "genreID": genre.id,
                "genreName": genre.name,
                "timestamp": FieldValue.serverTimestamp(),
                "userEmail": userEmail
            ]
            
            // Save the data to Firestore
            genreDocRef.setData(genreData) { error in
                if let error = error {
                    print("Error saving genre to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully saved genre \(genre.name) to Firestore")
                }
            }
        }
    }
    
    private func updateContinueButtonState() {
        let isEnabled = !selectedGenres.isEmpty
        continueButton.isEnabled = isEnabled
        continueButton.alpha = isEnabled ? 1.0 : 0.6
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MovieGenreSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGenreCell", for: indexPath) as! MovieGenreCell
        let genre = genres[indexPath.item]
        
        // Get custom image name based on genre name
        let imageName = getCustomImageName(for: genre.name)
        
        // Check if selected
        let isSelected = selectedGenres.contains(genre.id)
        
        cell.configure(with: genre.name, imageName: imageName, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let genre = genres[indexPath.item]
        
        // Toggle selection
        if selectedGenres.contains(genre.id) {
            selectedGenres.remove(genre.id)
        } else {
            selectedGenres.insert(genre.id)
        }
        
        // Update UI to reflect selection state
        collectionView.reloadItems(at: [indexPath])
        updateContinueButtonState()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MovieGenreSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}

class MovieGenreCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        // Add a default background color while image loads
        iv.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return iv
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        // Adjust gradient to cover more of the image
        layer.locations = [0.3, 1.0]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        // Add shadow to make text more readable
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    private func setupCell() {
        contentView.addSubview(containerView)
        
        // Setup image view first
        containerView.addSubview(imageView)
        
        // Add gradient layer above image
        containerView.layer.addSublayer(gradientLayer)
        
        // Add other UI elements
        containerView.addSubview(titleLabel)
        containerView.addSubview(overlayView)
        containerView.addSubview(checkmarkImageView)
        
        // Enhanced shadow effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            overlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            checkmarkImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 32),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with title: String, imageName: String, isSelected: Bool) {
        titleLabel.text = title
        
        // Load and set the image with fade animation
        if let image = UIImage(named: imageName) {
            UIView.transition(with: imageView,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                self.imageView.image = image
            }, completion: nil)
        } else {
            // Set a gradient background if image is not found
            imageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            imageView.image = nil
            print("Warning: Image not found for genre: \(title), tried to load: \(imageName)")
        }
        
        // Enhanced selection animation
        UIView.animate(withDuration: 0.3, animations: {
            self.checkmarkImageView.isHidden = !isSelected
            self.overlayView.isHidden = !isSelected
            self.transform = isSelected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            self.containerView.layer.borderWidth = isSelected ? 2 : 0
            self.containerView.layer.borderColor = isSelected ? UIColor.systemGreen.cgColor : nil
        })
    }
}



































