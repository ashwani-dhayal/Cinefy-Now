import UIKit

class FeaturesIntroViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let logoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = -2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "inefy"
        label.font = .systemFont(ofSize: 52, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let redLetterLabel: UILabel = {
        let label = UILabel()
        label.text = "C"
        label.font = .systemFont(ofSize: 52, weight: .bold)
        label.textColor = .red
        return label
    }()
    
    private lazy var featureViews: [FeatureView] = {
        let features = [
            FeatureInfo(icon: "square.grid.2x2.fill", text: "Tailor your watchlist with\npersonalized movie\nrecommendations."),
            FeatureInfo(icon: "person.3.fill", text: "Connect with fans, share\ntheories, and dive into live\ndiscussions."),
            FeatureInfo(icon: "star.circle.fill", text: "Rate, poll, and explore a\ncommunity driven by\ncinematic passion.")
        ]
        return features.map { FeatureView(info: $0) }
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .red
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
        
        
        logoStackView.addArrangedSubview(redLetterLabel)
        logoStackView.addArrangedSubview(logoLabel)
        
        
        view.addSubview(logoStackView)
        view.addSubview(stackView)
        view.addSubview(continueButton)
        
        
        featureViews.forEach { stackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            
            logoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            // Feature stack view
            stackView.topAnchor.constraint(equalTo: logoStackView.bottomAnchor, constant: 100), 
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Continue button
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add target to continue button
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        // Navigate to FirstLoginScreen
       // let firstLoginVC = FirstLoginScreen()
        let loginVC = LoginViewController()
       // let navController = UINavigationController(rootViewController: firstLoginVC)
        let navController = UINavigationController(rootViewController: loginVC)

        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// Feature view model
struct FeatureInfo {
    let icon: String
    let text: String
}

// Feature view class for displaying individual feature information
class FeatureView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(info: FeatureInfo) {
        super.init(frame: .zero)
        setupView(with: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(with info: FeatureInfo) {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(label)
        
        iconImageView.image = UIImage(systemName: info.icon)
        label.text = info.text
        
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            // Icon - increased size
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 35), // Increased size
            iconImageView.heightAnchor.constraint(equalToConstant: 35), // Increased size
            
            // Label
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}

