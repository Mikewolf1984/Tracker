import Foundation

final class CategoryViewModel: Identifiable {
    
    // MARK: - public properties
    let categoryStore = TrackerCategoryStore.shared
    let category: TrackerCategory
    var categoryName: String {
        return category.name
    }
    var categoryNameBinding: Binding<String>? {
        didSet {
            categoryNameBinding?(categoryName)
        }
    }
    
    // MARK: - init
    init(categoryName: String) {
        do {
            guard let category = try categoryStore?.getCategoryByName(categoryName) else {
                category = TrackerCategory(name: categoryName, trackers: [])
                return
            }
            self.category = category
        } catch {
            print("Error while fetching category: \(error)")
            self.category = TrackerCategory(name: categoryName, trackers: [])
        }
    }
}
