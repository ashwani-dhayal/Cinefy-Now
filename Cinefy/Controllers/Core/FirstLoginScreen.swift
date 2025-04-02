/*
import UIKit

class FirstLoginScreen: UIViewController {
    private var isLoggedIn: Bool = false
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let text = NSMutableAttributedString(string: "C", attributes: [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 40, weight: .bold)
        ])
        text.append(NSAttributedString(string: "inefy", attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 40, weight: .bold)
        ]))
        label.attributedText = text
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your Gateway to Cinematic Universes!"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.7 // Decreased visibility of image
        
        // Load background image from assets
        if let image = UIImage(named: "login_background") {
            imageView.image = image
        } else {
            // Fallback background color if image is not found
            imageView.backgroundColor = .darkGray
        }
        
        // Add gradient overlay
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,  // Increased opacity for better visibility
            UIColor.black.withAlphaComponent(0.8).cgColor   // Increased opacity for better visibility
        ]
        gradientLayer.locations = [0.0, 1.0]
        imageView.layer.addSublayer(gradientLayer)
        
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to Cinefy"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let manualSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log in", for: .normal) 
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        let googleImage = UIImage(systemName: "g.circle", withConfiguration: imageConfig)
        button.setImage(googleImage, for: .normal)
        button.tintColor = .black
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in with Apple", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        let appleImage = UIImage(systemName: "apple.logo", withConfiguration: imageConfig)
        button.setImage(appleImage, for: .normal)
        button.tintColor = .black
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = backgroundImageView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundImageView.bounds
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.isNavigationBarHidden = true
        
        // Add subviews
        view.addSubview(backgroundImageView)
        view.addSubview(logoLabel)
        view.addSubview(taglineLabel)
        view.addSubview(containerView)
        
        containerView.addSubview(welcomeLabel)
        containerView.addSubview(manualSignInButton)
        containerView.addSubview(googleLoginButton)
        containerView.addSubview(appleLoginButton)
        
        // Add button targets
        manualSignInButton.addTarget(self, action: #selector(manualSignInTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image - moved further down to show notification bar
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),             backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65),
            
            // Logo - positioned relative to safe area
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Tagline
            taglineLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Container
            containerView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            welcomeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            welcomeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Manual Sign In Button
            manualSignInButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 24),
            manualSignInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            manualSignInButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            manualSignInButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Google Login Button
            googleLoginButton.topAnchor.constraint(equalTo: manualSignInButton.bottomAnchor, constant: 16),
            googleLoginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            googleLoginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            googleLoginButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Apple Login Button
            appleLoginButton.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 16),
            appleLoginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            appleLoginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 54),
            appleLoginButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func manualSignInTapped() {
        // Handle manual sign in
        let loginViewController = LoginViewController()
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc private func googleLoginTapped() {
        // Handle Google sign in
        print("Google sign in tapped")
    }
    
    @objc private func appleLoginTapped() {
        // Handle Apple sign in
        print("Apple sign in tapped")
    }
}*/




