import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    //MARK: - Init
    
    private override init() {
        context = DataBaseStore.shared.context
        super.init()
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        do {
            let trackerRecordsCD = try context.fetch(fetchRequest) as [TrackerRecordCD]
            if trackerRecordsCD.isEmpty { return }
            for record in trackerRecordsCD {
                guard let id = record.id, let date = record.date else { return }
                records.insert(TrackerRecord(id: id, date: date))
            }
        } catch {print(error)}
    }
    //MARK: - public properties
    static let shared = TrackerRecordStore()
    var records =  Set<TrackerRecord>()
    //MARK: - private properties
    private var context: NSManagedObjectContext
    //MARK: - override methods
    //MARK: - public methods
    func updateRecords() throws {
        records.removeAll()
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
     
        let trackerRecordsCD = try context.fetch(fetchRequest) as [TrackerRecordCD]
        if trackerRecordsCD.isEmpty { return }
        for record in trackerRecordsCD {
            guard let id = record.id, let date = record.date else { return }
            records.insert(TrackerRecord(id: id, date: date))
        }
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCD(context: context)
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.id = record.id
        try context.save()
        try updateRecords()
        NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
        
    }
    
    
    func removeRecord(_ record: TrackerRecord) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        let recordsResult = try context.execute(fetchRequest) as? NSAsynchronousFetchResult<NSFetchRequestResult> ?? nil
        let idS = recordsResult?.finalResult as? [NSManagedObjectID] ?? []
        if idS.isEmpty { return }
        for id in idS {
            guard let recordCD = context.object(with: id) as? TrackerRecordCD else {return}
            if (recordCD.id == record.id) && (recordCD.date == record.date) {
                context.delete(recordCD)
            }
        }
        try context.save()
        try updateRecords()
        NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
        
    }
    
    func deleteAllRecords(for tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.resultType = .managedObjectIDResultType
        let recordsResult = try context.fetch(fetchRequest) as? NSAsynchronousFetchResult<NSFetchRequestResult> ?? nil
        let idS = recordsResult?.finalResult as? [NSManagedObjectID] ?? []
        if idS.isEmpty { return }
        for id in idS {
            guard let recordCD = context.object(with: id) as? TrackerRecordCD else {return}
            if (recordCD.id == tracker.id){
                context.delete(recordCD)
            }
        }
        try context.save()
        try updateRecords()
        NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
    }
    
    
    func recordsCount(for tracker: Tracker) -> Int {
        let fetchRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        fetchRequest.resultType = .managedObjectIDResultType
        fetchRequest.predicate = NSPredicate(format: "%K == %@", (\TrackerRecordCD.id)._kvcKeyPathString ?? "", tracker.id as CVarArg)
        do
        { let records = try context.fetch(fetchRequest)
            
            return records.count
        } catch {return 0}
    }
    
    
    
    func isCompletedInDate(for tracker: Tracker, date: String) -> Bool {
        let fetchRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@",(\TrackerRecordCD.id)._kvcKeyPathString ?? "", tracker.id as CVarArg, #keyPath(TrackerRecordCD.date), date as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            return !result.isEmpty
        } catch {return false}
    }
    
    
    //MARK: - private methods
    //MARK: - objc methods
    //MARK: - extensions
    
}

extension Notification.Name {
    static let trackerRecordsDidChange = Notification.Name("trackerRecordsDidChange")
}

