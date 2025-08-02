import Foundation
import CoreData

final class TrackerCategoryStore: NSObject {
    //MARK: - Init
    
    private init(context: NSManagedObjectContext) throws {
        self.context = DataBaseStore.shared.context
        super.init()
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        let trackerCategoriesCD = try context.fetch(fetchRequest)
        for categoryCD in trackerCategoriesCD {
            var trackers: [Tracker] = []
            for trackerID in categoryCD.trackers as? [UUID] ?? [] {
                if let tracker = TrackerStore.shared?.trackers.first(where: { $0.id == trackerID }) {
                    trackers.append(tracker)
                } else { continue }
            }
            let category = TrackerCategory(name: categoryCD.name ?? "", trackers: trackers)
            categories.append(category)
        }
    }
    //MARK: - public properties
    var categories: [TrackerCategory] = []
    static let shared = try? TrackerCategoryStore(context: DataBaseStore.shared.context)
    //MARK: - private properties
    private var context: NSManagedObjectContext
    //MARK: - override methods
    //MARK: - public methods
    func saveCategoryToCD (category: TrackerCategory, tracker: Tracker?) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        let categories = try context.execute(fetchRequest) as? NSAsynchronousFetchResult<NSFetchRequestResult> ?? nil
        let idS = categories?.finalResult  as? [NSManagedObjectID] ?? []
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
                guard let categoryById = context.object(with: id) as? TrackerCategoryCD else {return}
                if categoryById.name == category.name {
                    let oldTrackersIDs: [UUID] = categoryById.trackers as? [UUID] ?? []
                    var newTrackersIDs: [UUID] = oldTrackersIDs
                    if let tracker = tracker { newTrackersIDs.append(tracker.id) }
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
