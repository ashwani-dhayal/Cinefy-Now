import UIKit

class SplashViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "inefy"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let redLetterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "C"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .red
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizer()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add and position the white logo label
        view.addSubview(logoLabel)
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add and position the red 'C' label
        view.addSubview(redLetterLabel)
        NSLayoutConstraint.activate([
            redLetterLabel.trailingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            redLetterLabel.centerYAnchor.constraint(equalTo: logoLabel.centerYAnchor)
        ])
        
        // Make the logo label clickable area larger
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isUserInteractionEnabled = true
        
        view.addSubview(containerView)
        containerView.addSubview(redLetterLabel)
        containerView.addSubview(logoLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func logoTapped() {
        let featuresVC = FeaturesIntroViewController()
        featuresVC.modalPresentationStyle = .fullScreen
        present(featuresVC, animated: true)
    }
    
   
}
