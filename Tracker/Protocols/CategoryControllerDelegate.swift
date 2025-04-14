import Foundation

protocol CategoryControllerDelegate: AnyObject {
    func categoryDidSelected(category: TrackerCategory)
}
