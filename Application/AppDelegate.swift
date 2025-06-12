import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    static let shared = AppDelegate()
    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = TabBarViewController()
        window?.makeKeyAndVisible()
        TrackerCategoryTransformer.register()
        return true
    }
}
