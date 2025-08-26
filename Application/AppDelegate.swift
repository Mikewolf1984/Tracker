import UIKit
import CoreData
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = StartScreenViewController()
        window?.makeKeyAndVisible()
        TrackerCategoryTransformer.register()
        if let configuration = AppMetricaConfiguration(apiKey: yandexAPIKey) { 
            AppMetrica.activate(with: configuration)
        }
        return true
    }
}

