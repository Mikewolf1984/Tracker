import Foundation

protocol ScheduleControllerDelegate: AnyObject {
    func daysDidSelected(days: [DayOfWeek])
}
