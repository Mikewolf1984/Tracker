import Foundation

final class CategoriesViewModel {
    
    // MARK: - public properties
    var categoryListBinding: Binding<[CategoryViewModel]>?
    var selectedCategory: TrackerCategory?
    
    // MARK: - private properties
    private let categoryDataStore = TrackerCategoryStore.shared
    private(set) var categories: [CategoryViewModel] = [] {
        didSet {
            categoryListBinding?(categories)
        }
    }
    
    init(selectedCategory: TrackerCategory? = nil) {
        categories = getCategoriesFromStore()
        self.selectedCategory = selectedCategory
    }
    
    // MARK: - public methods
    func addCategory(_ newCategory: TrackerCategory) {
        categories.append(CategoryViewModel(categoryName: newCategory.name))
        selectedCategory = newCategory
    }
    
    func selectCategory(at index: Int) {
        let tappedCategory = categories[index].category
        if selectedCategory?.name == tappedCategory.name {
            selectedCategory = nil
        } else {
            selectedCategory = tappedCategory
        }
    }
    
    // MARK: - private methods
    private func getCategoriesFromStore() -> [CategoryViewModel] {
        let result = try? categoryDataStore.getCategories().map {
            CategoryViewModel(categoryName: $0.name)
        }
        return result ?? []
    }
}

// MARK: - extensions
