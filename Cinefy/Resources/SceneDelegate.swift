import UIKit
import FirebaseAuth
import FirebaseCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check authentication state
        if Auth.auth().currentUser != nil {
            // User is logged in, go to Welcome screen
            let mainVC = MainTabBarViewController()
            mainVC.modalPresentationStyle = .fullScreen
            window?.rootViewController = mainVC
        } else {
            // No user logged in, go to Login screen
            let splashVC=SplashViewController()
            splashVC.modalPresentationStyle = .fullScreen
            window?.rootViewController=splashVC
        }
        
        window?.makeKeyAndVisible()
    }
}
