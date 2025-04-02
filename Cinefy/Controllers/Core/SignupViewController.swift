//
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class SignupViewController: UIViewController, UITextFieldDelegate {
//    // MARK: - UI Components
//    private let logoLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        let text = NSMutableAttributedString(string: "C", attributes: [
//            .foregroundColor: UIColor.red,
//            .font: UIFont.systemFont(ofSize: 40, weight: .bold)
//        ])
//        text.append(NSAttributedString(string: "inefy", attributes: [
//            .foregroundColor: UIColor.white,
//            .font: UIFont.systemFont(ofSize: 40, weight: .bold)
//        ]))
//        label.attributedText = text
//        return label
//    }()
//    
//    private let backButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        button.tintColor = .white
//        return button
//    }()
//    
//    // Email Section
//    private let emailLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Email Address"
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        return label
//    }()
//    
//    private let emailContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
//        view.layer.cornerRadius = 8
//        return view
//    }()
//    
//    private let emailTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Enter your email"
//        textField.textColor = .white
//        textField.backgroundColor = .clear
//        textField.autocapitalizationType = .none
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.leftViewMode = .always
//        return textField
//    }()
//    
//    // Name Section
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Full Name"
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        return label
//    }()
//    
//    private let nameContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
//        view.layer.cornerRadius = 8
//        return view
//    }()
//    
//    private let nameTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Enter your full name"
//        textField.textColor = .white
//        textField.backgroundColor = .clear
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.leftViewMode = .always
//        return textField
//    }()
//    
//    // Password Section
//    private let passwordLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Password"
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        return label
//    }()
//    
//    private let passwordContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
//        view.layer.cornerRadius = 8
//        return view
//    }()
//    
//    private let passwordTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Enter your password"
//        textField.textColor = .white
//        textField.backgroundColor = .clear
//        textField.isSecureTextEntry = true
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.leftViewMode = .always
//        return textField
//    }()
//    
//    private let passwordShowButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
//        button.tintColor = .gray
//        return button
//    }()
//    
//    // Confirm Password Section
//    private let confirmPasswordLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Confirm Password"
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        return label
//    }()
//    
//    private let confirmPasswordContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
//        view.layer.cornerRadius = 8
//        return view
//    }()
//    
//    private let confirmPasswordTextField: UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Confirm your password"
//        textField.textColor = .white
//        textField.backgroundColor = .clear
//        textField.isSecureTextEntry = true
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.leftViewMode = .always
//        return textField
//    }()
//    
//    private let confirmPasswordShowButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
//        button.tintColor = .gray
//        return button
//    }()
//    
//    private let createAccountButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Create Account", for: .normal)
//        button.backgroundColor = .red
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 25
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        return button
//    }()
//
//    // MARK: - Lifecycle Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupConstraints()
//        setupActions()
//        setupTextFieldDelegates()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupUI() {
//        view.backgroundColor = .black
//        
//        // Add subviews
//        view.addSubview(backButton)
//        view.addSubview(logoLabel)
//        
//        // Email
//        view.addSubview(emailLabel)
//        view.addSubview(emailContainer)
//        emailContainer.addSubview(emailTextField)
//        
//        // Name
//        view.addSubview(nameLabel)
//        view.addSubview(nameContainer)
//        nameContainer.addSubview(nameTextField)
//        
//        // Password
//        view.addSubview(passwordLabel)
//        view.addSubview(passwordContainer)
//        passwordContainer.addSubview(passwordTextField)
//        passwordContainer.addSubview(passwordShowButton)
//        
//        // Confirm Password
//        view.addSubview(confirmPasswordLabel)
//        view.addSubview(confirmPasswordContainer)
//        confirmPasswordContainer.addSubview(confirmPasswordTextField)
//        confirmPasswordContainer.addSubview(confirmPasswordShowButton)
//        
//        view.addSubview(createAccountButton)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            backButton.widthAnchor.constraint(equalToConstant: 44),
//            backButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
//            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            // Email Label
//            emailLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 40),
//            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            // Email container
//            emailContainer.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
//            emailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            emailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            emailContainer.heightAnchor.constraint(equalToConstant: 50),
//            
//            emailTextField.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
//            emailTextField.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
//            emailTextField.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
//            
//            // Name Label
//            nameLabel.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 16),
//            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            // Name container
//            nameContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
//            nameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            nameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            nameContainer.heightAnchor.constraint(equalToConstant: 50),
//            
//            nameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 16),
//            nameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16),
//            nameTextField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
//            
//            // Password Label
//            passwordLabel.topAnchor.constraint(equalTo: nameContainer.bottomAnchor, constant: 16),
//            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            // Password container
//            passwordContainer.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
//            passwordContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            passwordContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            passwordContainer.heightAnchor.constraint(equalToConstant: 50),
//            
//            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor, constant: 16),
//            passwordTextField.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -50),
//            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
//            
//            passwordShowButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -16),
//            passwordShowButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
//            passwordShowButton.widthAnchor.constraint(equalToConstant: 24),
//            passwordShowButton.heightAnchor.constraint(equalToConstant: 24),
//            
//            // Confirm Password Label
//            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 16),
//            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            // Confirm Password container
//            confirmPasswordContainer.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
//            confirmPasswordContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            confirmPasswordContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            confirmPasswordContainer.heightAnchor.constraint(equalToConstant: 50),
//            
//            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor, constant: 16),
//            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -50),
//            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
//            
//            confirmPasswordShowButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -16),
//            confirmPasswordShowButton.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
//            confirmPasswordShowButton.widthAnchor.constraint(equalToConstant: 24),
//            confirmPasswordShowButton.heightAnchor.constraint(equalToConstant: 24),
//            
//            // Create Account button
//            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor, constant: 40),
//            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            createAccountButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//    
//    private func setupActions() {
//        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        
//        // Password show/hide toggle
//        passwordShowButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
//        confirmPasswordShowButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility(_:)), for: .touchUpInside)
//    }
//    
//    private func setupTextFieldDelegates() {
//        emailTextField.delegate = self
//        nameTextField.delegate = self
//        passwordTextField.delegate = self
//        confirmPasswordTextField.delegate = self
//    }
//    
//    @objc private func togglePasswordVisibility(_ sender: UIButton) {
//        passwordTextField.isSecureTextEntry.toggle()
//        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
//        passwordShowButton.setImage(UIImage(systemName: imageName), for: .normal)
//    }
//    
//    @objc private func toggleConfirmPasswordVisibility(_ sender: UIButton) {
//        confirmPasswordTextField.isSecureTextEntry.toggle()
//        let imageName = confirmPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
//        confirmPasswordShowButton.setImage(UIImage(systemName: imageName), for: .normal)
//    }
//    
//    // MARK: - Action Methods
//    @objc private func createAccountTapped() {
//        guard let email = emailTextField.text, !email.isEmpty,
//              let name = nameTextField.text, !name.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty,
//              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
//            showAlert(message: "Please fill in all fields")
//            return
//        }
//        
//        // Validate email format
//        if !isValidEmail(email) {
//            showAlert(message: "Please enter a valid email address")
//            return
//        }
//        
//        // Validate password match
//        guard password == confirmPassword else {
//            showAlert(message: "Passwords do not match")
//            return
//        }
//        
//        // Validate password strength
//        if !isValidPassword(password) {
//            showAlert(message: "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number")
//            return
//        }
//        
//        // Create account logic
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                print("Error creating account: \(error.localizedDescription)")
//                self.showAlert(message: "Error creating account. Please try again later.")
//                return
//            }
//            else {
//                let db = Firestore.firestore()
//                db.collection("users").addDocument(data: ["Full Name": name, "email": email]) { error in
//                    if let error = error {
//                        print("Error adding user: \(error)")
//                    }
//                    else {
//                        print("User added successfully")
//                    }
//                }
//                print("Account created successfully! with email: \(email), name: \(name)")
//            }
//            
//            // Show loading indicator
//            let loadingIndicator = UIActivityIndicatorView(style: .medium)
//            loadingIndicator.color = .white
//            self.createAccountButton.setTitle("", for: .normal)
//            self.createAccountButton.addSubview(loadingIndicator)
//            loadingIndicator.center = self.createAccountButton.center
//            loadingIndicator.startAnimating()
//            
//            // Simulate network request
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
//                loadingIndicator.removeFromSuperview()
//                self?.createAccountButton.setTitle("Create Account", for: .normal)
//                
//                // Show success and dismiss
//                self?.showAlert(message: "Account created successfully!", completion: {
//                    self?.dismiss(animated: true)
//                })
//            }
//        }
//    }
//    
//    @objc private func backButtonTapped() {
//        dismiss(animated: true)
//    }
//    
//    // MARK: - Helper Methods
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//    
//    private func isValidPassword(_ password: String) -> Bool {
//        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
//        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
//        return passwordPred.evaluate(with: password)
//    }
//    
//    private func showAlert(message: String, completion: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//            completion?()
//        })
//        present(alert, animated: true)
//    }
//    
//    // MARK: - UITextFieldDelegate
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField {
//        case emailTextField:
//            nameTextField.becomeFirstResponder()
//        case nameTextField:
//            passwordTextField.becomeFirstResponder()
//        case passwordTextField:
//            confirmPasswordTextField.becomeFirstResponder()
//        case confirmPasswordTextField:
//            textField.resignFirstResponder()
//            createAccountTapped()
//        default:
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//}















import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController, UITextFieldDelegate {
    // MARK: - UI Components
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
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    // Email Section
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Email Address"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let emailContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your email"
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.autocapitalizationType = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    // Name Section
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Full Name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let nameContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your full name"
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    // Password Section
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Password"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let passwordContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your password"
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.isSecureTextEntry = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let passwordShowButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    // Confirm Password Section
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Confirm Password"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let confirmPasswordContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Confirm your password"
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.isSecureTextEntry = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let confirmPasswordShowButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return button
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupTextFieldDelegates()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add subviews
        view.addSubview(backButton)
        view.addSubview(logoLabel)
        
        // Email
        view.addSubview(emailLabel)
        view.addSubview(emailContainer)
        emailContainer.addSubview(emailTextField)
        
        // Name
        view.addSubview(nameLabel)
        view.addSubview(nameContainer)
        nameContainer.addSubview(nameTextField)
        
        // Password
        view.addSubview(passwordLabel)
        view.addSubview(passwordContainer)
        passwordContainer.addSubview(passwordTextField)
        passwordContainer.addSubview(passwordShowButton)
        
        // Confirm Password
        view.addSubview(confirmPasswordLabel)
        view.addSubview(confirmPasswordContainer)
        confirmPasswordContainer.addSubview(confirmPasswordTextField)
        confirmPasswordContainer.addSubview(confirmPasswordShowButton)
        
        view.addSubview(createAccountButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 40),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Email container
            emailContainer.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailContainer.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Name container
            nameContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameContainer.heightAnchor.constraint(equalToConstant: 50),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16),
            nameTextField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
            
            // Password Label
            passwordLabel.topAnchor.constraint(equalTo: nameContainer.bottomAnchor, constant: 16),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Password container
            passwordContainer.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordContainer.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -50),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            
            passwordShowButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -16),
            passwordShowButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            passwordShowButton.widthAnchor.constraint(equalToConstant: 24),
            passwordShowButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Confirm Password Label
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 16),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Confirm Password container
            confirmPasswordContainer.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmPasswordContainer.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -50),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            
            confirmPasswordShowButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -16),
            confirmPasswordShowButton.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            confirmPasswordShowButton.widthAnchor.constraint(equalToConstant: 24),
            confirmPasswordShowButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Create Account button
            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor, constant: 40),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Password show/hide toggle
        passwordShowButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        confirmPasswordShowButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility(_:)), for: .touchUpInside)
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.delegate = self
        nameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordShowButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let imageName = confirmPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        confirmPasswordShowButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // MARK: - Action Methods
    @objc private func createAccountTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address")
            return
        }
        
        // Validate password match
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match")
            return
        }
        
        // Create account logic
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error creating account: \(error.localizedDescription)")
                self.showAlert(message: "Error creating account. Please try again later.")
                return
            }
            else {
                let db = Firestore.firestore()
                db.collection("users").addDocument(data: ["Full Name": name, "email": email]) { error in
                    if let error = error {
                        print("Error adding user: \(error)")
                    }
                    else {
                        print("User added successfully")
                    }
                }
                print("Account created successfully! with email: \(email), name: \(name)")
            }
            
            // Show loading indicator
            let loadingIndicator = UIActivityIndicatorView(style: .medium)
            loadingIndicator.color = .white
            self.createAccountButton.setTitle("", for: .normal)
            self.createAccountButton.addSubview(loadingIndicator)
            loadingIndicator.center = self.createAccountButton.center
            loadingIndicator.startAnimating()
            
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                loadingIndicator.removeFromSuperview()
                self?.createAccountButton.setTitle("Create Account", for: .normal)
                
                // Show success and dismiss
                self?.showAlert(message: "Account created successfully!", completion: {
                    self?.dismiss(animated: true)
                })
            }
        }
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            nameTextField.becomeFirstResponder()
        case nameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            createAccountTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
