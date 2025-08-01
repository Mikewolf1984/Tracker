import Foundation
import UIKit
import CoreData

struct TrackerObject {
    var tracker: Tracker
    var isCompleted: Bool
    var daysCount: Int
}
protocol DataProviderDelegate: AnyObject {
    // func didUpdate(_ update: TrackerStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
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
    
    //MARK: private properties
    
    private let context = AppDelegate.shared.persistentContainer.viewContext
    private let trackersDataStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let categoryDataStore = TrackerCategoryStore()
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
}

// MARK: - DataProviderProtocol
extension TrackersDataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func todayTrackersForSection (day: DayOfWeek, section: Int) -> [Tracker] {
        var result: [Tracker] = []
        do
        {
            let trackerCatIDs = fetchedResultsController.object(at: IndexPath(row: 0, section: section) ).trackers as! [UUID]
            for trackerId in trackerCatIDs {
                let tracker = try TrackerStore.shared.cdToTracker(TrackerStore.shared.getTrackerById(trackerId)!)
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
        let tracker1: Tracker = .init(
            id: UUID(),
            type: .habit,
            name: "Заглушка",
            color: YPColors.ypColor1,
            emoji: "🐈",
            schedule: [.monday],
            date: ""
        )
        let trackerStub = TrackerObject(tracker: tracker1, isCompleted: false, daysCount: 0)
        
        let trackersToday = todayTrackersForSection(day: day, section: indexPath.section)
        let tracker = trackersToday[indexPath.row]
        let isCompleted = TrackerRecordStore.shared.isCompletedInDate(for: tracker, date: currentDate)
        let daysCount = TrackerRecordStore.shared.recordsCount(for: tracker)
        return TrackerObject(tracker: tracker,
                             isCompleted: isCompleted, daysCount: daysCount)
        
    }
    
    func categoryName (section: Int) -> String {
        fetchedResultsController.object(at: IndexPath(item: 0, section: section)).name ?? ""
    }
    
    func addTracker(_ tracker: Tracker) throws {
        try? trackersDataStore.addNewTracker(tracker)
    }
    
    //TODO:    func deleteTracker(at indexPath: IndexPath) throws {
    //        let tracker = fetchedResultsController.object(at: indexPath)
    //        try? dataStore.delete(tracker)
    //    }
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
