import UIKit

struct Tracker {
    let  id: UUID
    let type: TrackerType
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
    let date: String?
}
