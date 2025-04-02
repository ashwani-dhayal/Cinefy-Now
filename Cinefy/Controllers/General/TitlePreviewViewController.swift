

import UIKit
import WebKit
import SDWebImage

class TitlePreviewViewController: UIViewController {
    private var movieTitle: Title?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let inTheUniverse: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("In the Universe", for: .normal)
        button.backgroundColor = UIColor.red
     
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 18)
        return button
    }()
    private let communityButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Community", for: .normal)
            button.backgroundColor = UIColor.red
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 25
            button.titleLabel?.font = .systemFont(ofSize: 18)
            return button
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(inTheUniverse)
        view.addSubview(communityButton)

        applyConstraints()
        setupActions()
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            inTheUniverse.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 20),
            inTheUniverse.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inTheUniverse.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inTheUniverse.heightAnchor.constraint(equalToConstant: 50),
            
            communityButton.topAnchor.constraint(equalTo: inTheUniverse.bottomAnchor, constant: 20),
                       communityButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                       communityButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                       communityButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func configure(with viewModel: TitlePreviewViewModel, title: Title) {
        self.movieTitle = title // Store the Title object
        titleLabel.text = viewModel.title
        overviewLabel.text = viewModel.titleOverview
        
        guard let url = URL(string: "https://www.youtube.com/embed/\(viewModel.youtubeView.id.videoId)") else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }

    private func setupActions() {
        inTheUniverse.addTarget(self, action: #selector(universeTapped), for: .touchUpInside)
        communityButton.addTarget(self, action: #selector(communityTapped), for: .touchUpInside)
    }

    @objc private func universeTapped() {
    
        let inTheUniverseViewController = InTheUniverseViewController(movieTitle: self.titleLabel.text ?? "")
           navigationController?.pushViewController(inTheUniverseViewController, animated: true)
           
        
        
        guard let movieTitle = titleLabel.text, !movieTitle.isEmpty else {
            print("❌ Movie title is empty")
            return
        }

        print("🎬 Fetching movies in same universe for: \(movieTitle)...")

        GeminiAPIManager.shared.fetchMoviesInSameUniverse(movieTitle: movieTitle) { movies in
            DispatchQueue.main.async {
                if let movies = movies {
                    print("✅ Movies Found: \(movies)")
                } else {
                    print("❌ No movies found in same universe.")
                }
            }
        }
    }
    
    @objc private func communityTapped() {
        guard let movieTitle = self.movieTitle else { // Use the renamed property
            print("Title is nil")
            return
        }
        
        // Initialize the MovieDiscussionViewController with the Title object
        let movieDiscussionVC = MovieDiscussionViewController(movie: movieTitle)
        
        // Push the MovieDiscussionViewController onto the navigation stack
        navigationController?.pushViewController(movieDiscussionVC, animated: true)
    }
    
}





