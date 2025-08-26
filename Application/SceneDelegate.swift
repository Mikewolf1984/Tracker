import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        window = UIWindow(windowScene: scene)
        let startScreenViewController = StartScreenViewController()
        window?.rootViewController = startScreenViewController
        window?.makeKeyAndVisible()
    }
}

