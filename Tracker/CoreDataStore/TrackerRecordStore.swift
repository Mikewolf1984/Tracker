import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    //MARK: - Init
    override convenience init() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        let trackerRecordsCD = try context.fetch(fetchRequest) as [TrackerRecordCD]
        if trackerRecordsCD.isEmpty { return }
        for record in trackerRecordsCD {
            guard let id = record.id else { return }
            guard let date = record.date else { return }
            records.insert(TrackerRecord(id: id, date: date))
        }
    }
    //MARK: - public properties
    static let shared = TrackerRecordStore()
    var records: Set<TrackerRecord> = []
    //MARK: - private properties
    private var context: NSManagedObjectContext
    //MARK: - override methods
    //MARK: - public methods
    func addRecord(_ record: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCD(context: context)
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.id = record.id
        try context.save()
    }
    func removeRecord(_ record: TrackerRecord) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        let records = try context.execute(fetchRequest) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        let idS = records.finalResult as! [NSManagedObjectID]
        if idS.isEmpty { return }
        for id in idS {
            let recordCD = context.object(with: id) as! TrackerRecordCD
            if (recordCD.id == record.id) && (recordCD.date == record.date) {
                context.delete(recordCD)
            }
        }
        try context.save()
    }
    func recordsCount(for tracker: Tracker) -> Int {
        let fetchRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "%K == \(TrackersViewController.shared.currentDate)", #keyPath(TrackerRecordCD.date))
        let records = try! context.execute(fetchRequest) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        return records.finalResult?.count ?? 0
    }
    //MARK: - private methods
    //MARK: - objc methods
    //MARK: - extensions
    
}
