import Foundation

@objc(TrackerCategoryTransformer)
final class TrackerCategoryTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let trackerIDs = value as? [UUID] else { return nil }
        return try? JSONEncoder().encode(trackerIDs)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([UUID].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            TrackerCategoryTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: TrackerCategoryTransformer.self))
        )
    }
}
