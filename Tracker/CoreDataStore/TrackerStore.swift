import CoreData
import UIKit



final class TrackerStore: NSObject {
    //MARK: - Init
    convenience override init() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        self.trackers = []
        super.init()
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        let trackersCD = try context.fetch(fetchRequest)
        for trackerCD in trackersCD {
            let tracker = Tracker(
                id: trackerCD.id ?? UUID(),
                type: trackerCD.isHabit ? .habit : .irregularEvent,
                name: trackerCD.name ?? "",
                color: uiColorMarshalling.color(from: trackerCD.color ?? "#000000"),
                emoji: trackerCD.emoji ?? "",
                schedule: scheduleTransformer.schedule(from: trackerCD.schedule ?? ""),
                date: trackerCD.date
            )
            trackers.append(tracker)
        }
    }
    
    //MARK: - public properties
    static let shared = TrackerStore()
    var trackers: [Tracker]
    //MARK: - private properties
    
    private var context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleTransformer  = ScheduleTransformer()
   
    //MARK: - override methods
    //MARK: - public methods
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCD(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.isHabit = tracker.type == .habit
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = scheduleTransformer.hexString(from: tracker.schedule)
        trackerCoreData.date = tracker.date
        try context.save()
    }
    
    
    //MARK: - private methods
    
    
    //MARK: - objc methods
    //MARK: - extensions
    
}
