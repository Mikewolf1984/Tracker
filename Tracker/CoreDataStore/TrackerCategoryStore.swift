import UIKit
import CoreData
final class TrackerCategoryStore {
   //MARK: - Init
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
init(context: NSManagedObjectContext) {
        self.context = context
    }
    //MARK: - public properties
    //MARK: - private properties
    private let context: NSManagedObjectContext
    //MARK: - override methods
    //MARK: - public methods
    //MARK: - private methods
    //MARK: - objc methods
    //MARK: - extensions

}
