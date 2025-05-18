import Foundation
import Observation

@Observable
class ProductListManager {
    static let shared = ProductListManager()
    
    var productLists: [ProductList] = []
    var selectedProduct: Product?
    var selectedList: ProductList?
    
    var customLists: [ProductList] {
        Array(productLists.dropFirst(2))
    }
    
    var systemLists: [ProductList] {
        Array(productLists.prefix(2))
    }
    
    private init() {
        self.productLists = Self.loadProductLists()
    }
    
    private static func loadProductLists() -> [ProductList] {
        guard let data = UserDefaults.standard.data(forKey: "savedProductLists"),
              let decodedLists = try? JSONDecoder().decode([ProductList].self, from: data) else {
            // Return default lists if nothing is saved
            let defaultLists = [
                ProductList(name: .scanned),
                ProductList(name: .viewed)
            ]
            // Save default lists immediately
            if let encoded = try? JSONEncoder().encode(defaultLists) {
                UserDefaults.standard.set(encoded, forKey: "savedProductLists")
            }
            return defaultLists
        }
        return decodedLists
    }
    
    func saveProductLists() {
        if let encoded = try? JSONEncoder().encode(productLists) {
            UserDefaults.standard.set(encoded, forKey: "savedProductLists")
            // Force UserDefaults to save immediately
            UserDefaults.standard.synchronize()
        }
    }
    
    func addToList(_ product: Product, list: ProductList) -> Bool {
        // Check if product already exists
        if !list.products.contains(where: { $0.id == product.id }) {
            if let index = productLists.firstIndex(where: { $0.id == list.id }) {
                var updatedLists = productLists
                let updatedList = list
                updatedList.products.insert(product, at: 0)
                updatedLists[index] = updatedList
                productLists = updatedLists
                saveProductLists()
                return true
            }
        }
        return false
    }
    
    func removeFromList(_ product: Product, list: ProductList) -> Bool {
        if let index = productLists.firstIndex(where: { $0.id == list.id }) {
            var updatedLists = productLists
            let updatedList = list
            updatedList.products.removeAll { $0.id == product.id }
            updatedLists[index] = updatedList
            productLists = updatedLists
            saveProductLists()
            return true
        }
        return false
    }
    
    func moveList(from source: IndexSet, to destination: Int) {
        let lists = Array(productLists)
        let systemLists = Array(lists.prefix(2))
        var customLists = Array(lists.dropFirst(2))
        
        customLists.move(fromOffsets: source, toOffset: destination)
        productLists = systemLists + customLists
        
        saveProductLists()
    }
    
    func deleteList(at offsets: IndexSet) -> ProductList? {
        // Ensure we're only working with valid indices
        guard let firstOffset = offsets.first,
              firstOffset < productLists.count - 2 else {
            return nil
        }
        
        // Get the list that will be deleted
        let listToDelete = productLists[firstOffset + 2]
        
        // Remove from the main array
        productLists.remove(at: firstOffset + 2)
        saveProductLists()
        
        return listToDelete
    }
    
    // Sorting method
    func sortedProducts(from list: ProductList, by option: ProductListView.SortOption) -> [Product] {
        switch option {
        case .newest:
            return list.products.sorted {
                guard let date1 = $0.createdDate, let date2 = $1.createdDate else { return false }
                return date1 > date2
            }
        case .oldest:
            return list.products.sorted {
                guard let date1 = $0.createdDate, let date2 = $1.createdDate else { return false }
                return date1 < date2
            }
        case .name:
            return list.products.sorted { $0.productName < $1.productName }
        case .barcode:
            return list.products.sorted { $0._id < $1._id }
        }
    }
} 
