import UIKit

final class ScheduleTransformer {
    func hexString(from schedule: [DayOfWeek]) -> String {
        var hexString = ""
        for day in schedule {
            hexString.append(String(day.rawValue))
        }
        return hexString
    }
    
    func schedule(from hex: String) -> [DayOfWeek] {
        var schedule: [DayOfWeek] = []
        for char in hex {
            guard let dayOfWeek = DayOfWeek(rawValue: Int(String(char)) ?? 0) else { continue }
            schedule.append(dayOfWeek)
        }
        return schedule
    }
}
