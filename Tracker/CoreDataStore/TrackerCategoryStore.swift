import UIKit
import CoreData
final class TrackerCategoryStore: NSObject {
    //MARK: - Init
    override convenience init() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        let trackerCategoriesCD = try context.fetch(fetchRequest)
        for categoryCD in trackerCategoriesCD {
            var trackers: [Tracker] = []
            for trackerID in categoryCD.trackers as! [UUID] {
                let tracker = TrackerStore.shared.trackers.first(where: { $0.id == trackerID })!
                trackers.append(tracker)
            }
            let category = TrackerCategory(name: categoryCD.name!, trackers: trackers)
            categories.append(category)
        }
        
    }
    //MARK: - public properties
    static let shared = TrackerCategoryStore()
    var categories: [TrackerCategory] = []
    //MARK: - private properties
    private var context: NSManagedObjectContext
    //MARK: - override methods
    //MARK: - public methods
    func saveCategoryToCD (category: TrackerCategory, tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        let categories = try context.execute(fetchRequest) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        let idS = categories.finalResult as! [NSManagedObjectID]
        if idS.isEmpty {
            let categoryCoreData = TrackerCategoryCD(context: context)
            categoryCoreData.name = category.name
            var trackersIDs: [UUID] = []
            for tracker in category.trackers {
                trackersIDs.append(tracker.id)
            }
            categoryCoreData.trackers = trackersIDs as NSObject
            try context.save()
        } else {
            for id  in idS {
                let categoryById = context.object(with: id) as! TrackerCategoryCD
                if categoryById.name == category.name {
                    let oldTrackersIDs: [UUID] = categoryById.trackers as! [UUID]
                    var newTrackersIDs: [UUID] = oldTrackersIDs
                    newTrackersIDs.append(tracker.id)
                    categoryById.trackers = newTrackersIDs as NSObject
                    try context.save()
                } else {
                    let categoryCoreData = TrackerCategoryCD(context: context)
                    categoryCoreData.name = category.name
                    var trackersIDs: [UUID] = []
                    for tracker in category.trackers {
                        trackersIDs.append(tracker.id)
                    }
                    categoryCoreData.trackers = trackersIDs as NSObject
                    try context.save()
                }
            }
        }
    }
    //MARK: - private methods
    
    //MARK: - objc methods
    //MARK: - extensions
    
}
