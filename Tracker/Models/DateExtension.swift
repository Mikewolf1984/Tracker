import Foundation
extension Date {
    func toInt() -> UInt {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return UInt(components.year! * 10000 + components.month! * 100 + components.day!)
    }
}
