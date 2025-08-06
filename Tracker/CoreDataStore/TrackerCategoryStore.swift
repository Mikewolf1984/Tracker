import Foundation
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store( _ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    //MARK: - Init
    weak var delegate: TrackerCategoryStoreDelegate?
    private init(context: NSManagedObjectContext) throws {
        self.context = DataBaseStore.shared.context
        super.init()
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        let trackerCategoriesCD = try context.fetch(fetchRequest)
        self.categories = try self.getCategories()
    }
    
    //MARK: - public properties
    var categories: [TrackerCategory] = []
    static let shared = try? TrackerCategoryStore(context: DataBaseStore.shared.context)
    //MARK: - private properties
    private var context: NSManagedObjectContext
    //MARK: - override methods
    //MARK: - public methods
    func createCategory(name: String) throws -> TrackerCategory {
        let newCategory = TrackerCategory(name: name, trackers: [])
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        let categoryCoreData = TrackerCategoryCD(context: context)
        categoryCoreData.name = name
        categoryCoreData.trackers = [] as NSObject
        try context.save()
        return newCategory
    }
    
    func getCategories() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let result = try context.fetch(fetchRequest)
        for categoryCD in result {
            var trackers: [Tracker] = []
            for trackerID in categoryCD.trackers as? [UUID] ?? [] {
                guard let trackerCD = try TrackerStore.shared?.getTrackerById(trackerID) else { return []}
                guard let tracker = TrackerStore.shared?.cdToTracker(trackerCD) else {return []}
                trackers.append(tracker)
            }
            let category = TrackerCategory(name: categoryCD.name ?? "", trackers: trackers)
            categories.append(category)
        }
        return categories
    }
    
    func getCategoryByName(_ name: String) throws -> TrackerCategory? {
        try getCategories().first { $0.name == name }
        
    }
    
    func addTrackerToCategory(_ tracker: Tracker, categoryName: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        let categories = try context.execute(fetchRequest) as? NSAsynchronousFetchResult<NSFetchRequestResult> ?? nil
        let idS = categories?.finalResult  as? [NSManagedObjectID] ?? []
        guard let id = idS.first else {return}
        guard let categoryById = context.object(with: id) as? TrackerCategoryCD else {return}
        let oldTrackersIDs: [UUID] = categoryById.trackers as? [UUID] ?? []
        var newTrackersIDs: [UUID] = oldTrackersIDs
        newTrackersIDs.append(tracker.id)
        categoryById.trackers = newTrackersIDs as NSObject
        try context.save()
        
    }
    
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
