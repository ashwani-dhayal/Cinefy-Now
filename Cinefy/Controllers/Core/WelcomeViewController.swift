import UIKit

class WelcomeViewController: UIViewController {
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "getstarted")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        // Add dark overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        iv.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: iv.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: iv.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: iv.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: iv.bottomAnchor)
        ])
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
   
        label.text = """
        Discover, share, and celebrate your love for movies. 
        Dive into curated lists and connect 
        with fellow fans.
        """
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
      //  label.textAlignment = .center
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Your movie journey begins now!"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(logoLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(taglineLabel)
        view.addSubview(getStartedButton)
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 500), // Adjust height as needed
            
            
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            taglineLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
    }
    
    @objc private func getStartedTapped() {
        let artistSelectionVC = ArtistSelectionViewController()
        artistSelectionVC.modalPresentationStyle = .fullScreen
        present(artistSelectionVC, animated: true)
    }
}
