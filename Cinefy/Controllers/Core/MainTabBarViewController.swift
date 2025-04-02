import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
       
        let vc2 = UINavigationController(rootViewController: SearchViewController())
        let vc3 = UINavigationController(rootViewController: GenreViewController())
        let vc4 = UINavigationController(rootViewController: DownloadsViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        
        vc2.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        vc3.tabBarItem.image = UIImage(systemName: "person.3")
        vc4.tabBarItem.image = UIImage(systemName: "person")

        vc1.title = "Home"
        vc2.title = "Explore"
        vc3.title = "Community"
        vc4.title = "Profile"

        // Change tab bar background color to black
        tabBar.barTintColor = .black
        tabBar.backgroundColor = .black

        // Change selected tab color to red
        tabBar.tintColor = .red

        // Change unselected tab color to white
        tabBar.unselectedItemTintColor = .white

        setViewControllers([vc1, vc2, vc3, vc4], animated: true)
    }
}
