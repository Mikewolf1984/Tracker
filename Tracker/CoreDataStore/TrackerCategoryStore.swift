import Foundation
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store( _ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    //MARK: - Init
    weak var delegate: TrackerCategoryStoreDelegate?
    private override init() {
        
        super.init()
        
    }
    
    //MARK: - public properties
    var categories: [TrackerCategory] = []
    static let shared = TrackerCategoryStore()
    //MARK: - private properties
    private let context = DataBaseStore.shared.context
    //MARK: - override methods
    //MARK: - public methods
    func createCategory(name: String) throws -> TrackerCategory {
        let newCategory = TrackerCategory(name: name, trackers: [])
        let categoryCoreData = TrackerCategoryCD(context: DataBaseStore.shared.context)
        categoryCoreData.name = name
        categoryCoreData.trackers = [] as NSObject
        DataBaseStore.shared.saveContext()
        return newCategory
    }
    
    func updateCategoryStore () {
        do {
            categories = try getCategories()
        } catch { print ("Error in updateCategoryStore")}
    }
    func getCategories() throws -> [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let result = try context.fetch(fetchRequest)
        for categoryCD in result {
            var trackers: [Tracker] = []
            for trackerID in categoryCD.trackers as? [UUID] ?? [] {
                if let trackerCD = try TrackerStore.shared.getTrackerById(trackerID)  {
                    let tracker = TrackerStore.shared.cdToTracker(trackerCD)
                    trackers.append(tracker)
                }
            }
            let category = TrackerCategory(name: categoryCD.name ?? "", trackers: trackers)
            categories.append(category)
        }
        return categories
    }
    
    func getCategoryByName(_ name: String) throws -> TrackerCategory? {
        try getCategories().first { $0.name == name }
        
    }
    
    func getCategoryCDByName(_ name: String) throws -> TrackerCategoryCD? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        let result = try context.fetch(fetchRequest)
        return result.first
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
    
    
    func deleteCategoryFromCD(category: TrackerCategory) throws {
        /* let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
         guard let category = try context.fetch(fetchRequest).first else { return }
         context.delete(category)
         */
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
                }
                try context.save()
            }
            
        }
    }
    
    //MARK: - private methods
    
    //MARK: - objc methods
    //MARK: - extensions
}
