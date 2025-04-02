import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MovieDiscussionViewController: UIViewController {
    // MARK: - Properties
    private var movie: Title
    private var discussions: [Discussion] = []
    private var fanTheories: [FanTheory] = []
    private var selectedDiscussionIndex: Int?
    private var selectedTheoryIndex: Int?
    private var currentUsername: String = "@User"
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        //here
        label.textAlignment = .left
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
 
    
    private lazy var addToWatchlistButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Add to Watchlist", for: .normal)
            button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            button.tintColor = .white
        button.backgroundColor = .systemRed
            button.layer.cornerRadius = 22 // Half of height for pill shape
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
            
            // Add subtle shadow for depth
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.shadowOpacity = 0.3
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(addToWatchlistTapped), for: .touchUpInside)
            return button
        }()
    private lazy var addToFavoritesButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Add to Favorites", for: .normal)
            button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            button.tintColor = .white
        button.backgroundColor = .systemRed
            button.layer.cornerRadius = 22
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.shadowOpacity = 0.3
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(addToFavoritesTapped), for: .touchUpInside)
            return button
        }()
    
    private let discussionHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let discussionLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending Discussion"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addDiscussionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addDiscussionTapped), for: .touchUpInside)
        return button
    }()
    
    private let discussionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let fanTheoriesHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let fanTheoriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Fan Theories"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addTheoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTheoryTapped), for: .touchUpInside)
        return button
    }()
    
    private let fanTheoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var discussionInputContainerView: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private lazy var discussionInputTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Share your thoughts..."
            textField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            textField.textColor = .white
            textField.layer.cornerRadius = 8
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            textField.leftViewMode = .always
            textField.rightView = discussionSendButton
            textField.rightViewMode = .always
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
        
        private lazy var discussionSendButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
            button.tintColor = .systemBlue
            button.addTarget(self, action: #selector(discussionSendButtonTapped), for: .touchUpInside)
            return button
        }()
        
        private lazy var theoryInputContainerView: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private lazy var theoryInputTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Share your theory..."
            textField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            textField.textColor = .white
            textField.layer.cornerRadius = 8
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            textField.leftViewMode = .always
            textField.rightView = theorySendButton
            textField.rightViewMode = .always
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
        
        private lazy var theorySendButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
            button.tintColor = .systemBlue
            button.addTarget(self, action: #selector(theorySendButtonTapped), for: .touchUpInside)
            return button
        }()
    // MARK: - Initialization
    init(movie: Title) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
        fetchCurrentUsername { [weak self] in
               guard let self = self else { return }
               self.configureWithData()
               self.fetchMovieDetails()
               self.setupKeyboardHandling()
           }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        view.addSubview(addToWatchlistButton)
        
                scrollView.addSubview(contentView)
                view.addSubview(discussionInputContainerView)
                view.addSubview(theoryInputContainerView)
                
                discussionHeaderView.addSubview(discussionLabel)
                discussionHeaderView.addSubview(addDiscussionButton)
                
                fanTheoriesHeaderView.addSubview(fanTheoriesLabel)
                fanTheoriesHeaderView.addSubview(addTheoryButton)
                
                discussionInputContainerView.addSubview(discussionInputTextField)
                theoryInputContainerView.addSubview(theoryInputTextField)
                
        [backButton, titleLabel, posterImageView, discussionHeaderView, addToWatchlistButton, addToFavoritesButton,discussionHeaderView,
                 discussionStackView, fanTheoriesHeaderView, fanTheoriesStackView].forEach { contentView.addSubview($0) }
                
                // Hide both input containers initially
                discussionInputContainerView.isHidden = true
                theoryInputContainerView.isHidden = true
                
                setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            
            addToWatchlistButton.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 24),
            addToWatchlistButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                        addToWatchlistButton.heightAnchor.constraint(equalToConstant: 44),
                        addToWatchlistButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            addToFavoritesButton.topAnchor.constraint(equalTo: addToWatchlistButton.bottomAnchor, constant: 16),
                        addToFavoritesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                        addToFavoritesButton.heightAnchor.constraint(equalToConstant: 44),
                        addToFavoritesButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),

            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
       
            
            posterImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            posterImageView.heightAnchor.constraint(equalToConstant: 200),
            
            
           // discussionHeaderView.topAnchor.constraint(equalTo: addToWatchlistButton.bottomAnchor, constant: 32),
            discussionHeaderView.topAnchor.constraint(equalTo: addToFavoritesButton.bottomAnchor, constant: 32),
          //  discussionHeaderView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            discussionHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            discussionHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            discussionHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            discussionLabel.centerYAnchor.constraint(equalTo: discussionHeaderView.centerYAnchor),
            discussionLabel.leadingAnchor.constraint(equalTo: discussionHeaderView.leadingAnchor, constant: 20),
            
            addDiscussionButton.centerYAnchor.constraint(equalTo: discussionHeaderView.centerYAnchor),
            addDiscussionButton.trailingAnchor.constraint(equalTo: discussionHeaderView.trailingAnchor, constant: -20),
            addDiscussionButton.widthAnchor.constraint(equalToConstant: 44),
            addDiscussionButton.heightAnchor.constraint(equalToConstant: 44),
            
            discussionStackView.topAnchor.constraint(equalTo: discussionHeaderView.bottomAnchor, constant: 16),
            discussionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            discussionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            fanTheoriesHeaderView.topAnchor.constraint(equalTo: discussionStackView.bottomAnchor, constant: 20),
            fanTheoriesHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            fanTheoriesHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            fanTheoriesHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            fanTheoriesLabel.centerYAnchor.constraint(equalTo: fanTheoriesHeaderView.centerYAnchor),
            fanTheoriesLabel.leadingAnchor.constraint(equalTo: fanTheoriesHeaderView.leadingAnchor, constant: 20),
            
            addTheoryButton.centerYAnchor.constraint(equalTo: fanTheoriesHeaderView.centerYAnchor),
            addTheoryButton.trailingAnchor.constraint(equalTo: fanTheoriesHeaderView.trailingAnchor, constant: -20),
            addTheoryButton.widthAnchor.constraint(equalToConstant: 44),
            addTheoryButton.heightAnchor.constraint(equalToConstant: 44),
            
            fanTheoriesStackView.topAnchor.constraint(equalTo: fanTheoriesHeaderView.bottomAnchor, constant: 16),
            fanTheoriesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fanTheoriesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fanTheoriesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            
            discussionInputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        discussionInputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        discussionInputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                        
                        discussionInputTextField.topAnchor.constraint(equalTo: discussionInputContainerView.topAnchor, constant: 8),
                        discussionInputTextField.leadingAnchor.constraint(equalTo: discussionInputContainerView.leadingAnchor, constant: 20),
                        discussionInputTextField.trailingAnchor.constraint(equalTo: discussionInputContainerView.trailingAnchor, constant: -20),
                        discussionInputTextField.bottomAnchor.constraint(equalTo: discussionInputContainerView.bottomAnchor, constant: -8),
                        discussionInputTextField.heightAnchor.constraint(equalToConstant: 44),
                        
                        // Theory Input Container
                        theoryInputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        theoryInputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        theoryInputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                        
                        theoryInputTextField.topAnchor.constraint(equalTo: theoryInputContainerView.topAnchor, constant: 8),
                        theoryInputTextField.leadingAnchor.constraint(equalTo: theoryInputContainerView.leadingAnchor, constant: 20),
                        theoryInputTextField.trailingAnchor.constraint(equalTo: theoryInputContainerView.trailingAnchor, constant: -20),
                        theoryInputTextField.bottomAnchor.constraint(equalTo: theoryInputContainerView.bottomAnchor, constant: -8),
                        theoryInputTextField.heightAnchor.constraint(equalToConstant: 44)
   
        ])
    }
    
    private func configureWithData() {
        titleLabel.text = movie.original_title
        
        if let posterPath = movie.poster_path, !posterPath.isEmpty {
            let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            posterImageView.sd_setImage(with: posterURL, placeholderImage: UIImage(systemName: "film"))
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.tintColor = .gray
        }
    }
    private func fetchMovieDetails() {
        let db = Firestore.firestore()
   
        
        // Get discussions for this movie
        db.collection("movies").document(String(movie.id)).collection("discussions")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching discussions: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.discussions = []
                
                for document in documents {
                    let data = document.data()
                    guard let username = data["username"] as? String,
                          let comment = data["comment"] as? String else { continue }
                    
                   // var discussion = Discussion(username: username, comment: comment, replies: [])
                    var discussion = Discussion(id: document.documentID, username: username, comment: comment, replies: [])
                    
                    // Fetch replies for this discussion
                    self.fetchReplies(for: document.documentID) { replies in
                        discussion.replies = replies
                        self.discussions.append(discussion)
                        
                        // Once all discussions processed, update UI
                        if self.discussions.count == documents.count {
                            DispatchQueue.main.async {
                                self.updateDiscussionStackView()
                            }
                        }
                    }
                }
            }
        
        // Get fan theories for this movie
        db.collection("movies").document(String(movie.id)).collection("theories")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching theories: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.fanTheories = []
                
                for document in documents {
                    let data = document.data()
                    guard let username = data["username"] as? String,
                          let theory = data["theory"] as? String else { continue }
                    
                    //var fanTheory = FanTheory(username: username, theory: theory, comments: [])
                    var fanTheory = FanTheory(id: document.documentID, username: username, theory: theory, comments: [])
                    
                    // Fetch comments for this theory
                    self.fetchTheoryComments(for: document.documentID) { comments in
                        fanTheory.comments = comments
                        self.fanTheories.append(fanTheory)
                        
                        // Once all theories processed, update UI
                        if self.fanTheories.count == documents.count {
                            DispatchQueue.main.async {
                                self.updateFanTheoriesStackView()
                            }
                        }
                    }
                }
            }
    }
    
    
    private func fetchCurrentUsername(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            currentUsername = "@User"
            completion()
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let data = snapshot?.data(), let username = data["username"] as? String {
                self.currentUsername = username.hasPrefix("@") ? username : "@\(username)"
            } else {
                // Fallback to display name if no username in Firestore
                if let displayName = user.displayName, !displayName.isEmpty {
                    self.currentUsername = "@\(displayName)"
                } else {
                    // Fallback to email if no display name
                    let emailName = user.email?.components(separatedBy: "@").first ?? "User"
                    self.currentUsername = "@\(emailName)"
                }
            }
            
            print("Current username set to: \(self.currentUsername)")
            completion()
        }
    }
   
    private func getDiscussionID(for index: Int) -> String? {
        guard index < discussions.count else { return nil }
        return discussions[index].id
    }

    private func getTheoryID(for index: Int) -> String? {
        guard index < fanTheories.count else { return nil }
        return fanTheories[index].id
    }
    private func fetchReplies(for discussionID: String, completion: @escaping ([Reply]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("movies").document(String(movie.id))
          .collection("discussions").document(discussionID)
          .collection("replies")
          .order(by: "timestamp", descending: false)
          .getDocuments { snapshot, error in
              
              if let error = error {
                  print("Error fetching replies: \(error)")
                  completion([])
                  return
              }
              
              guard let documents = snapshot?.documents else {
                  completion([])
                  return
              }
              
              var replies: [Reply] = []
              
              for document in documents {
                  let data = document.data()
                  guard let username = data["username"] as? String,
                        let comment = data["comment"] as? String else { continue }
                  
                  let reply = Reply(username: username, comment: comment)
                  replies.append(reply)
              }
              
              completion(replies)
          }
    }
    private func fetchTheoryComments(for theoryID: String, completion: @escaping ([Reply]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("movies").document(String(movie.id))
          .collection("theories").document(theoryID)
          .collection("comments")
          .order(by: "timestamp", descending: false)
          .getDocuments { snapshot, error in
              
              if let error = error {
                  print("Error fetching theory comments: \(error)")
                  completion([])
                  return
              }
              
              guard let documents = snapshot?.documents else {
                  completion([])
                  return
              }
              
              var comments: [Reply] = []
              
              for document in documents {
                  let data = document.data()
                  guard let username = data["username"] as? String,
                        let commentText = data["comment"] as? String else { continue }  // Changed variable name
                  
                  let reply = Reply(username: username, comment: commentText)  // Changed variable name
                  comments.append(reply)  // Changed to 'reply'
              }
              
              completion(comments)
          }
    }
    

  
    
    private func updateDiscussionStackView() {
        discussionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, discussion) in discussions.enumerated() {
            let discussionView = createDiscussionView(discussion: discussion, index: index)
            discussionStackView.addArrangedSubview(discussionView)
        }
    }
    
    private func updateFanTheoriesStackView() {
        fanTheoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, theory) in fanTheories.enumerated() {
            let theoryView = createFanTheoryView(theory: theory, index: index)
            fanTheoriesStackView.addArrangedSubview(theoryView)
        }
    }
    
    private func createDiscussionView(discussion: Discussion, index: Int) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let usernameLabel = UILabel()
        usernameLabel.text = discussion.username
        usernameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        usernameLabel.textColor = .white
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let commentLabel = UILabel()
        commentLabel.text = discussion.comment
        commentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        commentLabel.textColor = .white
        commentLabel.numberOfLines = 0
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let replyButton = UIButton(type: .system)
        replyButton.setTitle("Reply", for: .normal)
        replyButton.tintColor = .systemBlue
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        replyButton.tag = index
        replyButton.addTarget(self, action: #selector(replyButtonTapped(_:)), for: .touchUpInside)
        
        let repliesStackView = UIStackView()
        repliesStackView.axis = .vertical
        repliesStackView.spacing = 8
        repliesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for reply in discussion.replies {
            let replyView = createReplyView(reply: reply)
            repliesStackView.addArrangedSubview(replyView)
        }
        
        view.addSubview(usernameLabel)
        view.addSubview(commentLabel)
        view.addSubview(replyButton)
        view.addSubview(repliesStackView)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            commentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            replyButton.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 8),
            replyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            replyButton.bottomAnchor.constraint(equalTo: repliesStackView.topAnchor, constant: -8),
            
            repliesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            repliesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            repliesStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        return view
    }
    
    private func createFanTheoryView(theory: FanTheory, index: Int) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let usernameLabel = UILabel()
        usernameLabel.text = theory.username
        usernameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        usernameLabel.textColor = .white
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let theoryLabel = UILabel()
        theoryLabel.text = theory.theory
        theoryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        theoryLabel.textColor = .white
        theoryLabel.numberOfLines = 0
        theoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let commentButton = UIButton(type: .system)
        commentButton.setTitle("Comment", for: .normal)
        commentButton.tintColor = .systemBlue
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.tag = index
        commentButton.addTarget(self, action: #selector(commentButtonTapped(_:)), for: .touchUpInside)
        
        let commentsStackView = UIStackView()
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 8
        commentsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for comment in theory.comments {
            let commentView = createReplyView(reply: comment)
            commentsStackView.addArrangedSubview(commentView)
        }
        
        view.addSubview(usernameLabel)
        view.addSubview(theoryLabel)
        view.addSubview(commentButton)
        view.addSubview(commentsStackView)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            theoryLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            theoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            theoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            commentButton.topAnchor.constraint(equalTo: theoryLabel.bottomAnchor, constant: 8),
            commentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            commentButton.bottomAnchor.constraint(equalTo: commentsStackView.topAnchor, constant: -8),
            
            commentsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            commentsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        return view
    }
    
    private func createReplyView(reply: Reply) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let usernameLabel = UILabel()
        usernameLabel.text = reply.username
        usernameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        usernameLabel.textColor = .white
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let commentLabel = UILabel()
        commentLabel.text = reply.comment
        commentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        commentLabel.textColor = .white
        commentLabel.numberOfLines = 0
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(usernameLabel)
        view.addSubview(commentLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            commentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            commentLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        ])
        
        return view
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func addToWatchlistTapped() {
        // Animation remains the same
        UIView.animate(withDuration: 0.1, animations: {
            self.addToWatchlistButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.addToWatchlistButton.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addToWatchlistButton.transform = .identity
                self.addToWatchlistButton.alpha = 1.0
            }
        }

        // Get current user's email
        guard let userEmail = Auth.auth().currentUser?.email else {
            let alert = UIAlertController(title: "Error",
                                        message: "Please login to add movies to watchlist",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Reference to Firestore
        let db = Firestore.firestore()
        
        // Create watchlist data
        let watchlistData: [String: Any] = [
            "movieTitle": movie.original_title,
            "userEmail": userEmail,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Add to Firestore in movieWatchlist collection
        db.collection("movieWatchlist").addDocument(data: watchlistData) { error in
            if let error = error {
                print("Error adding to watchlist: \(error)")
                let alert = UIAlertController(title: "Error",
                                            message: "Failed to add movie to watchlist",
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                // Show success alert
                let alert = UIAlertController(title: "Added to Watchlist",
                                            message: "\(self.movie.original_title) has been added to your watchlist.",
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                // Keep existing WatchlistManager functionality
                WatchlistManager.shared.addMovieToWatchlist(movie: self.movie)
            }
        }
    }
    
    
    
    
    @objc private func addToFavoritesTapped() {
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.addToFavoritesButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.addToFavoritesButton.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addToFavoritesButton.transform = .identity
                self.addToFavoritesButton.alpha = 1.0
            }
        }
        
        // Get current user's email
        guard let userEmail = Auth.auth().currentUser?.email else {
            let alert = UIAlertController(title: "Error",
                                        message: "Please login to add movies to favorites",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Reference to Firestore
        let db = Firestore.firestore()
        
        // Create favorites data
        let favoritesData: [String: Any] = [
            "movieTitle": movie.original_title,
            "userEmail": userEmail,
            "timestamp": FieldValue.serverTimestamp(),
            "movieId": movie.id,
            "posterPath": movie.poster_path ?? ""  // Store poster path for future reference
        ]
        
        // Add to Firestore in movieFavorites collection
        db.collection("movieFavorites").addDocument(data: favoritesData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error adding to favorites: \(error)")
                let alert = UIAlertController(title: "Error",
                                            message: "Failed to add movie to favorites",
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                // Keep existing FavoritesManager functionality
                FavoritesManager.shared.addMovieToFavorites(movie: self.movie)
                
                // Show success alert
                let alert = UIAlertController(title: "Added to Favorites",
                                            message: "\(self.movie.original_title) has been added to your favorites.",
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
   
    
    
    @objc private func addDiscussionTapped() {
        selectedDiscussionIndex = nil
                selectedTheoryIndex = nil
                discussionInputTextField.placeholder = "Start a new discussion..."
                showDiscussionInput()
    }
    
    @objc private func addTheoryTapped() {
        selectedDiscussionIndex = nil
                selectedTheoryIndex = nil
                theoryInputTextField.placeholder = "Share your fan theory..."
                showTheoryInput()
    }
    
    @objc private func replyButtonTapped(_ sender: UIButton) {
        selectedDiscussionIndex = sender.tag
                selectedTheoryIndex = nil
                discussionInputTextField.placeholder = "Reply to \(discussions[sender.tag].username)..."
                showDiscussionInput()
    }
    
    @objc private func commentButtonTapped(_ sender: UIButton) {
        selectedDiscussionIndex = nil
                selectedTheoryIndex = sender.tag
                theoryInputTextField.placeholder = "Comment on \(fanTheories[sender.tag].username)'s theory..."
                showTheoryInput()
    }
    @objc private func discussionSendButtonTapped() {
        guard let text = discussionInputTextField.text, !text.isEmpty else { return }
        let db = Firestore.firestore()
        
        if let discussionIndex = selectedDiscussionIndex {
            // Add reply to existing discussion
            let discussion = discussions[discussionIndex]
            
            // Find the document ID for this discussion (you'll need to store this when fetching)
            guard let discussionID = getDiscussionID(for: discussionIndex) else { return }
            
            // Add to Firestore
            let replyData: [String: Any] = [
                "username": currentUsername,
                "comment": text,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            db.collection("movies").document(String(movie.id))
              .collection("discussions").document(discussionID)
              .collection("replies").addDocument(data: replyData) { error in
                  if let error = error {
                      print("Error adding reply: \(error)")
                      return
                  }
                  
                  // Update local data
                  let reply = Reply(username: self.currentUsername, comment: text)
                  self.discussions[discussionIndex].replies.append(reply)
                  
                  DispatchQueue.main.async {
                      self.updateDiscussionStackView()
                  }
              }
            
        } else {
            // Add new discussion
            let discussionData: [String: Any] = [
                "username": currentUsername,
                "comment": text,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            db.collection("movies").document(String(movie.id))
              .collection("discussions").addDocument(data: discussionData) { [weak self] error in
                  guard let self = self else { return }
                  
                  if let error = error {
                      print("Error adding discussion: \(error)")
                      return
                  }
                  
                  // Update local data
                  let discussion = Discussion(username: self.currentUsername, comment: text, replies: [])
                  self.discussions.append(discussion)
                  
                  DispatchQueue.main.async {
                      self.updateDiscussionStackView()
                  }
              }
        }
        
        discussionInputTextField.text = nil
        hideInputContainers()
    }

    @objc private func theorySendButtonTapped() {
        guard let text = theoryInputTextField.text, !text.isEmpty else { return }
        let db = Firestore.firestore()
        
        if let theoryIndex = selectedTheoryIndex {
            // Add comment to fan theory
            guard let theoryID = getTheoryID(for: theoryIndex) else { return }
            
            // Add to Firestore
            let commentData: [String: Any] = [
                "username": currentUsername,
                "comment": text,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            db.collection("movies").document(String(movie.id))
              .collection("theories").document(theoryID)
              .collection("comments").addDocument(data: commentData) { error in
                  if let error = error {
                      print("Error adding theory comment: \(error)")
                      return
                  }
                  
                  // Update local data
                  let comment = Reply(username: self.currentUsername, comment: text)
                  self.fanTheories[theoryIndex].comments.append(comment)
                  
                  DispatchQueue.main.async {
                      self.updateFanTheoriesStackView()
                  }
              }
            
        } else {
            // Add new fan theory
            let theoryData: [String: Any] = [
                "username": currentUsername,
                "theory": text,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            db.collection("movies").document(String(movie.id))
              .collection("theories").addDocument(data: theoryData) { [weak self] error in
                  guard let self = self else { return }
                  
                  if let error = error {
                      print("Error adding theory: \(error)")
                      return
                  }
                  
                  // Update local data
                  let theory = FanTheory(username: self.currentUsername, theory: text, comments: [])
                  self.fanTheories.append(theory)
                  
                  DispatchQueue.main.async {
                      self.updateFanTheoriesStackView()
                  }
              }
        }
        
        theoryInputTextField.text = nil
        hideInputContainers()
    }
   
        
        private func showDiscussionInput() {
            theoryInputContainerView.isHidden = true
            discussionInputContainerView.isHidden = false
            discussionInputTextField.becomeFirstResponder()
        }
        
        private func showTheoryInput() {
            discussionInputContainerView.isHidden = true
            theoryInputContainerView.isHidden = false
            theoryInputTextField.becomeFirstResponder()
        }
        
        private func hideInputContainers() {
            discussionInputContainerView.isHidden = true
            theoryInputContainerView.isHidden = true
            discussionInputTextField.resignFirstResponder()
            theoryInputTextField.resignFirstResponder()
        }

    
    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       
       @objc private func keyboardWillShow(_ notification: Notification) {
           guard let userInfo = notification.userInfo,
                 let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
           
           let keyboardHeight = keyboardFrame.height
           discussionInputContainerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
           theoryInputContainerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
       }
       
       @objc private func keyboardWillHide(_ notification: Notification) {
           discussionInputContainerView.transform = .identity
           theoryInputContainerView.transform = .identity
       }
}























































