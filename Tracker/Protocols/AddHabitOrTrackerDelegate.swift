import Foundation

protocol AddHabitOrTrackerDelegate: AnyObject {
    func trackerDidCreated(tracker: Tracker, category: TrackerCategory)
    func trackerDidCanceled()
}

protocol EditHabitOrTrackerDelegate: AnyObject {
    func trackerDidEdited(tracker: Tracker, category: TrackerCategory)
    func trackerDidCanceled()
}
