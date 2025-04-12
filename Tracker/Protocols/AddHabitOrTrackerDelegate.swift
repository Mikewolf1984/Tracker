import Foundation

protocol AddHabitOrTrackerDelegate: AnyObject {
    func trackerDidCreated(tracker: Tracker, category: TrackerCategory)
    func trackerDidCanceled()
}
