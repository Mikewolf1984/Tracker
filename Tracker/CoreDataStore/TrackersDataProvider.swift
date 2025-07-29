import Foundation
import UIKit
import CoreData

struct TrackerObject {
    var tracker: Tracker
    var isComleted: Bool
    var daysCount: Int
}
protocol DataProviderDelegate: AnyObject {
   // func didUpdate(_ update: TrackerStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) throws -> TrackerObject
    func addTracker(_ tracker: Tracker) throws
    //TODO: func deleteRecord(at indexPath: IndexPath) throws
}

// MARK: - DataProvider
final class TrackersDataProvider: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    //weak var delegate: DataProviderDelegate?
    
    private let context = AppDelegate.shared.persistentContainer.viewContext
    private let dataStore = TrackerStore()
    
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {

        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
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
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerObject {
        let object = fetchedResultsController.object(at: indexPath)
        let tracker = TrackerStore.shared.cdToTracker(object)
        let isCompleted = object.trackerToRecordRS?.date == TrackersViewController.shared.currentDate
        let daysCount = TrackerRecordStore.shared.recordsCount(for: tracker)
        return TrackerObject(tracker: tracker,
                             isComleted: isCompleted, daysCount: daysCount)
        
    }

    func addTracker(_ tracker: Tracker) throws {
        try? dataStore.addNewTracker(tracker)
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
