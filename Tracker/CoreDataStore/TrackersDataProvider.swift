import Foundation
import CoreData

struct TrackerObject {
    let tracker: Tracker
    let isCompleted: Bool
    let daysCount: Int
}
protocol DataProviderDelegate: AnyObject {
    //TODO: func didUpdate(_ update: TrackerStoreUpdate)
}

protocol DataProviderProtocol {
    func numberOfSectionsByDay(day: DayOfWeek) -> Int
    func todayTrackersForSection (day: DayOfWeek, section: Int) -> [Tracker]
    func numberOfRowsInSection(day: DayOfWeek, section: Int) -> Int
    func object(at indexPath: IndexPath, day: DayOfWeek, currentDate: String) -> TrackerObject
    func addTracker(_ tracker: Tracker) throws
    //TODO: func deleteRecord(at indexPath: IndexPath) throws
}

final class TrackersDataProvider: NSObject {
    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    //MARK: public properties
    static let shared = TrackersDataProvider()
    //MARK: private properties
    private let context = DataBaseStore.shared.context
    private let trackersDataStore = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let categoryDataStore = TrackerCategoryStore.shared
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "name",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    //MARK: private methods
    
    func refreshStore()
    {
        try? fetchedResultsController.performFetch()
    }
}

// MARK: - DataProviderProtocol
extension TrackersDataProvider: DataProviderProtocol {
    func numberOfSectionsByDay(day: DayOfWeek)-> Int {
        var result :Int = 0
        let allSections = fetchedResultsController.sections?.count ?? 0
        for section in 0..<allSections {
            if todayTrackersForSection(day: day, section: section).count>0 {
                result += 1
            }
        }
        return result
    }
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    
    }
    
    func todayCategoriesToShow(day: DayOfWeek) -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        for section in 0..<numberOfSectionsByDay(day: day) {
            todayTrackersForSection(day: day, section: section)
        }
        return result
    }
    func todayTrackersForSection (day: DayOfWeek, section: Int) -> [Tracker] {
        var result: [Tracker] = []
        do
        {
            let trackerCatIDs = fetchedResultsController.object(at: IndexPath(row: 0, section: section) ).trackers as? [UUID] ?? []
            for trackerId in trackerCatIDs {
                guard let trackerCD = try trackersDataStore?.getTrackerById(trackerId) else {return []}
                guard let tracker = trackersDataStore?.cdToTracker(trackerCD) else {return []}
                if tracker.schedule.contains(day) {
                    result.append(tracker)
                }
            }
        } catch {
            print ("Error fetching data: \(error)")
        }
        return result
    }
    
    func numberOfRowsInSection(day: DayOfWeek, section: Int) -> Int {
        todayTrackersForSection(day: day, section: section).count
    }
    
    func object(at indexPath: IndexPath, day: DayOfWeek, currentDate: String) -> TrackerObject {
        let trackersToday = todayTrackersForSection(day: day, section: indexPath.section)
        let tracker = trackersToday[indexPath.row]
        let isCompleted = trackerRecordStore?.isCompletedInDate(for: tracker, date: currentDate) ?? false
        let daysCount = trackerRecordStore?.recordsCount(for: tracker) ?? 0
        return TrackerObject(tracker: tracker,
                             isCompleted: isCompleted, daysCount: daysCount)
    }
    
    func categoryName (section: Int) -> String {
        fetchedResultsController.object(at: IndexPath(item: 0, section: section)).name ?? ""
    }
    
    func addTracker(_ tracker: Tracker) throws {
        try trackersDataStore?.addNewTracker(tracker)
    }
    
    //TODO:    func deleteTracker(at indexPath: IndexPath) throws {
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
