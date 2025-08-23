import CoreData
import Foundation

protocol TrackerDataStore {
    var context: NSManagedObjectContext { get }
    func addNewTracker(_ tracker: Tracker) throws
}

final class TrackerStore: NSObject {
    //MARK: - Init
    private override init() {
        context = DataBaseStore.shared.context
        self.trackers = []
        super.init()
    }
    
    //MARK: - public properties
    static let shared = TrackerStore()
    var trackers = [Tracker]()
    
    //MARK: - private properties
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleTransformer  = ScheduleTransformer()
    private let context: NSManagedObjectContext
    
    //MARK: - override methods
    //MARK: - public methods
    func addNewTracker(_ tracker: Tracker, category: TrackerCategoryCD ) throws {
        let trackerCoreData = TrackerCD(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.isHabit = tracker.type == .habit
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = scheduleTransformer.hexString(from: tracker.schedule)
        trackerCoreData.date = tracker.date
        trackerCoreData.categoryRS  = category
        try context.save()
    }
    
    func editTracker(_ tracker: Tracker, category: TrackerCategoryCD ) throws {
        guard let trackerCoreData = try getTrackerById(tracker.id) else {return}
        trackerCoreData.id = tracker.id
        trackerCoreData.isHabit = tracker.type == .habit
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = scheduleTransformer.hexString(from: tracker.schedule)
        trackerCoreData.date = tracker.date
        trackerCoreData.categoryRS  = category
        try context.save()
        updateTrackersStore()
    }
    
    func cdToTracker(_ cd: TrackerCD) -> Tracker {
        return Tracker(id: cd.id ?? UUID(),
                       type: cd.isHabit ? TrackerType.habit : TrackerType.irregularEvent,
                       name: cd.name ?? "Имя не найдено",
                       color: uiColorMarshalling.color(from: cd.color ?? "#FFFFFF"),
                       emoji: cd.emoji ?? "",
                       schedule: scheduleTransformer.schedule(from: cd.schedule ?? ""),
                       date: cd.date ?? ""
        )
    }
    
    func getTrackerById(_ id: UUID) throws -> TrackerCD? {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        request.fetchLimit  = 1
        let result = try context.fetch(request).first as TrackerCD?
        return result
        
    }
    
    func getAllTrackers() throws -> [TrackerCD?] {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let result = try context.fetch(fetchRequest)
        
        return result
    }
    func updateTrackersStore() {
        trackers = []
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        do {
            let trackersCD = try context.fetch(fetchRequest)
            for trackerCD in trackersCD {
                let tracker = Tracker(
                    id: trackerCD.id ?? UUID(),
                    type: trackerCD.isHabit ? .habit : .irregularEvent,
                    name: trackerCD.name ?? "",
                    color: uiColorMarshalling.color(from: trackerCD.color ?? "#000000"),
                    emoji: trackerCD.emoji ?? "",
                    schedule: scheduleTransformer.schedule(from: trackerCD.schedule ?? ""),
                    date: trackerCD.date ?? ""
                )
                trackers.append(tracker)
            }
        } catch {print ("Error fetching data")}
    }
    //MARK: - private methods
    //MARK: - objc methods
    //MARK: - extensions
}
