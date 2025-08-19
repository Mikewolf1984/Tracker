import UIKit

struct Statistics {
    let bestPeriod: Int
    let perfectDays: Int
    let trackersCompleted: Int
    let completedAverage: Int
}

final class StatisticsService {
    
    // MARK: - public methods
    var isEmpty: Bool {
        return ((trackerRecordStore?.records.isEmpty) != nil)
    }
    
    // MARK: - private properties
    private let trackerRecordStore = TrackerRecordStore.shared
    private let trackerStore = TrackerStore.shared
    
    // MARK: - init
     
    
    // MARK: - public methods
    func calculate() -> Statistics {
     return Statistics(bestPeriod: 0, perfectDays: 0, trackersCompleted: 0, completedAverage: 0)
    }
    
    // MARK: - private methods
    private func bestPeriod(from records: Set<TrackerRecord>, allTrackers: [Tracker]) -> Int {
        var maxPeriod: Int = 0
        return maxPeriod
    }
    
    private func perfectDays(from records: Set<TrackerRecord>, allTrackers: [Tracker]) -> Int {
        var countOfDays: Int = 0
        return countOfDays
    }
    
    private func trackersCompleted(from records: Set<TrackerRecord>) -> Int {
        var countOfCompletedTrackers: Int = 0
        return countOfCompletedTrackers
    }
    
    private func averageCompletionRate(from records: Set<TrackerRecord>) -> Int {
        return 0
    }
}
